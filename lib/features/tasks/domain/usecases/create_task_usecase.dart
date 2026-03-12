import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TasksRepository repository;

  CreateTaskUseCase(this.repository);

  Future<Either<Failure, String>> call(TaskEntity task) {
    return repository.createTask(task);
  }
}
