import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class CreateNotificationUseCase {
  final NotificationsRepository repository;

  CreateNotificationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(NotificationEntity notification) {
    return repository.createNotification(notification);
  }
}
