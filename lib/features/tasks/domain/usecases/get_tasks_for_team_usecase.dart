import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksForTeamUseCase {
  final TasksRepository repository;

  GetTasksForTeamUseCase(this.repository);

  Stream<List<TaskEntity>> call(String teamId) {
    return repository.getTasksForTeam(teamId);
  }
}
