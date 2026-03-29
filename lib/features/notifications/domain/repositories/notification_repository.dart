import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Stream<List<NotificationEntity>> getNotificationsForUser(String userId);

  Future<Either<Failure, Unit>> markAsRead(String notificationId);

  Future<Either<Failure, Unit>> markAllAsRead(String userId);

  Future<Either<Failure, Unit>> createNotification(
    NotificationEntity notification,
  );
}
