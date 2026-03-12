import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TasksRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> createTask(TaskEntity task) async {
    try {
      final model = TaskModel(
        id: '',
        title: task.title,
        description: task.description,
        teamId: task.teamId,
        teamName: task.teamName,
        assigneeIds: task.assigneeIds,
        creatorId: task.creatorId,
        priority: task.priority,
        status: task.status,
        startDate: task.startDate,
        dueDate: task.dueDate,
        isRecurring: task.isRecurring,
        isDraft: task.isDraft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await remoteDataSource.createTask(model);
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTask(
    String taskId,
    TaskEntity task,
  ) async {
    try {
      final model = TaskModel(
        id: taskId,
        title: task.title,
        description: task.description,
        teamId: task.teamId,
        teamName: task.teamName,
        assigneeIds: task.assigneeIds,
        creatorId: task.creatorId,
        priority: task.priority,
        status: task.status,
        startDate: task.startDate,
        dueDate: task.dueDate,
        isRecurring: task.isRecurring,
        isDraft: task.isDraft,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
      );
      await remoteDataSource.updateTask(taskId, model);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String taskId) async {
    try {
      await remoteDataSource.deleteTask(taskId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<TaskEntity>> getTasksForUser(String userId) {
    return remoteDataSource.getTasksForUser(userId);
  }

  @override
  Stream<List<TaskEntity>> getTasksForTeam(String teamId) {
    return remoteDataSource.getTasksForTeam(teamId);
  }

  @override
  Stream<List<TaskEntity>> getTasksForTeams(List<String> teamIds) {
    return remoteDataSource.getTasksForTeams(teamIds);
  }

  @override
  Future<Either<Failure, Unit>> addComment(
    String taskId,
    TaskCommentEntity comment,
  ) async {
    try {
      final model = TaskCommentModel(
        id: '',
        authorId: comment.authorId,
        text: comment.text,
        createdAt: DateTime.now(),
      );
      await remoteDataSource.addComment(taskId, model);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
