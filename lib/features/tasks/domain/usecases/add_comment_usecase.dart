import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class AddCommentUseCase {
  final TasksRepository repository;

  AddCommentUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String taskId, TaskCommentEntity comment) {
    return repository.addComment(taskId, comment);
  }
}
