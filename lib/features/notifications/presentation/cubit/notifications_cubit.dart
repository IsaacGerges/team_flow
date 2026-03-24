import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

  StreamSubscription? _notificationsSubscription;
  NotificationFilter _currentFilter = NotificationFilter.all;

  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.markAllNotificationsReadUseCase,
    required this.markNotificationReadUseCase,
  }) : super(NotificationsInitial());

  void loadNotifications(String userId) {
    emit(NotificationsLoading());
    _notificationsSubscription?.cancel();
    _notificationsSubscription = getNotificationsUseCase(userId).listen(
      (notifications) {
        emit(NotificationsLoaded(notifications, _currentFilter));
      },
      onError: (error) {
        emit(NotificationsError(error.toString()));
      },
    );
  }

  void setFilter(NotificationFilter filter) {
    _currentFilter = filter;
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      emit(NotificationsLoaded(currentState.notifications, _currentFilter));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await markNotificationReadUseCase(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await markAllNotificationsReadUseCase(userId);
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
