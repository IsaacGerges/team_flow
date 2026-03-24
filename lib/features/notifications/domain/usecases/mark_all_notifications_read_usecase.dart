import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationsRepository repository;

  MarkAllNotificationsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.markAllAsRead(userId);
  }
}
