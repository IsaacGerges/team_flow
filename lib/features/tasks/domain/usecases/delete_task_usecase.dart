import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TasksRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String taskId) {
    return repository.deleteTask(taskId);
  }
}
