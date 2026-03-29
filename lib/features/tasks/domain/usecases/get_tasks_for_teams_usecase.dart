import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/features/tasks/domain/repositories/task_repository.dart';

/// Returns a viewer-aware stream of tasks across multiple teams.
///
/// The stream combines:
/// - All published tasks for the given teams.
/// - Only drafts whose [creatorId] matches [viewerId].
class GetTasksForTeamsUseCase {
  final TasksRepository repository;

  GetTasksForTeamsUseCase(this.repository);

  Stream<List<TaskEntity>> call(
    List<String> teamIds, {
    required String viewerId,
  }) {
    return repository.getTasksForTeams(teamIds, viewerId: viewerId);
  }
}
