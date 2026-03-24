import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository repository;

  MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
