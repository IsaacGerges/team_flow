import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TasksRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String taskId, TaskEntity task) {
    return repository.updateTask(taskId, task);
  }
}
