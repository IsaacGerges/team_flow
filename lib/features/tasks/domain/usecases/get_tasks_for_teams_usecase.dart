import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/features/tasks/domain/repositories/task_repository.dart';

class GetTasksForTeamsUseCase {
  final TasksRepository repository;

  GetTasksForTeamsUseCase(this.repository);

  Stream<List<TaskEntity>> call(List<String> teamIds) {
    return repository.getTasksForTeams(teamIds);
  }
}
