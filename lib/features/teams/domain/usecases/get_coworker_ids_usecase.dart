import 'package:dartz/dartz.dart';
import 'package:team_flow/core/error/failures.dart';
import 'package:team_flow/features/tasks/domain/repositories/task_repository.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';

/// UseCase responsible for identifying unique coworker IDs for a given user.
///
/// Coworkers are defined as any user who shares at least one team or task
/// with the target user (excluding the target user themselves).
class GetCoworkerIdsUseCase {
  final TeamsRepository teamsRepository;
  final TasksRepository tasksRepository;

  GetCoworkerIdsUseCase({
    required this.teamsRepository,
    required this.tasksRepository,
  });

  /// Executes the logic to fetch and compute coworker IDs based on current
  /// team memberships and task assignments.
  ///
  /// Returns a [Set] of unique user IDs.
  Future<Either<Failure, Set<String>>> call(String currentUserId) async {
    try {
      final Set<String> coworkerIds = {};

      // 1. Fetch user's teams to collect all team members
      // We take the first emission from the stream to get the current snapshot
      final teams = await teamsRepository.getMyTeams(currentUserId).first;
      for (final team in teams) {
        coworkerIds.addAll(team.membersIds);
      }

      // 2. Fetch user's tasks to collect assignees and team collaborators
      final tasks = await tasksRepository.getTasksForUser(currentUserId).first;
      for (final task in tasks) {
        // Collect everyone assigned to the same task
        coworkerIds.addAll(task.assigneeIds);
        // Collect the creator of the task as a collaborator
        coworkerIds.add(task.creatorId);
      }

      // 3. Clean up the set
      // Remove the user themselves from the "coworker" list
      coworkerIds.remove(currentUserId);
      // Ensure we don't include any empty strings if they exist
      coworkerIds.removeWhere((id) => id.trim().isEmpty);

      return Right(coworkerIds);
    } catch (e) {
      // If something goes wrong with the streams (e.g. permission error),
      // we wrap it in a Failure.
      return Left(ServerFailure(e.toString()));
    }
  }
}
