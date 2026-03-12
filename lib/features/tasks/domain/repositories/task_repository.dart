import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TasksRepository {
  Future<Either<Failure, String>> createTask(TaskEntity task);
  Future<Either<Failure, Unit>> updateTask(String taskId, TaskEntity task);
  Future<Either<Failure, Unit>> deleteTask(String taskId);
  Stream<List<TaskEntity>> getTasksForUser(String userId);
  Stream<List<TaskEntity>> getTasksForTeam(String teamId);
  Stream<List<TaskEntity>> getTasksForTeams(List<String> teamIds);
  Future<Either<Failure, Unit>> addComment(
    String taskId,
    TaskCommentEntity comment,
  );
}
