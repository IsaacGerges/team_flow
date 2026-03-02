import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksForUserUseCase {
  final TasksRepository repository;

  GetTasksForUserUseCase(this.repository);

  Stream<List<TaskEntity>> call(String userId) {
    return repository.getTasksForUser(userId);
  }
}
