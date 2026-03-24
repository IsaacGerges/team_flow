import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Stream<List<NotificationEntity>> getNotificationsForUser(String userId) {
    return remoteDataSource.getNotificationsForUser(userId);
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead(String userId) async {
    try {
      await remoteDataSource.markAllAsRead(userId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> createNotification(
    NotificationEntity notification,
  ) async {
    try {
      final model = NotificationModel(
        id: notification.id,
        userId: notification.userId,
        type: notification.type,
        title: notification.title,
        body: notification.body,
        targetId: notification.targetId,
        targetName: notification.targetName,
        senderName: notification.senderName,
        senderPhotoUrl: notification.senderPhotoUrl,
        teamInitials: notification.teamInitials,
        isRead: notification.isRead,
        createdAt: notification.createdAt,
      );
      await remoteDataSource.createNotification(model);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
