import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

enum NotificationFilter { all, unread, teams, tasks, mentions }

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

final class NotificationsInitial extends NotificationsState {}

final class NotificationsLoading extends NotificationsState {}

final class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final NotificationFilter activeFilter;

  const NotificationsLoaded(this.notifications, this.activeFilter);

  @override
  List<Object?> get props => [notifications, activeFilter];
}

final class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
