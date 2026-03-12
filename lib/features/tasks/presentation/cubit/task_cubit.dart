import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_for_team_usecase.dart';
import '../../domain/usecases/get_tasks_for_teams_usecase.dart';
import '../../domain/usecases/get_tasks_for_user_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_state.dart';

/// Manages the state for tasks across the application.
///
/// Uses Firestore streams as the single source of truth. After every
/// mutation (create / update / delete / comment) the cubit re-subscribes
/// to the stream so the UI always shows fresh data.
class TasksCubit extends Cubit<TasksState> {
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final GetTasksForUserUseCase getTasksForUserUseCase;
  final GetTasksForTeamUseCase getTasksForTeamUseCase;
  final GetTasksForTeamsUseCase getTasksForTeamsUseCase;
  final AddCommentUseCase addCommentUseCase;

  StreamSubscription? _tasksSubscription;

  TasksCubit({
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getTasksForUserUseCase,
    required this.getTasksForTeamUseCase,
    required this.getTasksForTeamsUseCase,
    required this.addCommentUseCase,
  }) : super(TasksInitial());

  // ----------------------------------------------------------
  // Stream subscriptions
  // ----------------------------------------------------------

  void loadMyTasks(String userId) {
    emit(TasksLoading());
    _tasksSubscription?.cancel();
    _tasksSubscription = getTasksForUserUseCase(userId).listen(
      (tasks) => emit(TasksLoaded(tasks)),
      onError: (error) => emit(TasksError(error.toString())),
    );
  }

  void loadTeamTasks(String teamId) {
    emit(TasksLoading());
    _tasksSubscription?.cancel();
    _tasksSubscription = getTasksForTeamUseCase(teamId).listen(
      (tasks) => emit(TasksLoaded(tasks)),
      onError: (error) => emit(TasksError(error.toString())),
    );
  }

  void loadTasksForTeams(List<String> teamIds) {
    if (teamIds.isEmpty) {
      emit(const TasksLoaded([]));
      return;
    }

    emit(TasksLoading());
    _tasksSubscription?.cancel();
    _tasksSubscription = getTasksForTeamsUseCase(teamIds).listen(
      (tasks) => emit(TasksLoaded(tasks)),
      onError: (error) => emit(TasksError(error.toString())),
    );
  }

  // ----------------------------------------------------------
  // Mutations
  // ----------------------------------------------------------

  Future<String?> createTask(TaskEntity task) async {
    final result = await createTaskUseCase(task);
    return result.fold((failure) {
      emit(TasksError(_mapFailureToMessage(failure)));
      return null;
    }, (taskId) => taskId);
  }

  Future<bool> updateTask(String taskId, TaskEntity task) async {
    final result = await updateTaskUseCase(taskId, task);
    return result.fold((failure) {
      emit(TasksError(_mapFailureToMessage(failure)));
      return false;
    }, (_) => true);
  }

  Future<bool> updateTaskStatus(
    String taskId,
    TaskStatus status,
    TaskEntity currentTask,
  ) async {
    final updatedTask = TaskEntity(
      id: currentTask.id,
      title: currentTask.title,
      description: currentTask.description,
      teamId: currentTask.teamId,
      teamName: currentTask.teamName,
      assigneeIds: currentTask.assigneeIds,
      creatorId: currentTask.creatorId,
      priority: currentTask.priority,
      status: status,
      startDate: currentTask.startDate,
      dueDate: currentTask.dueDate,
      isRecurring: currentTask.isRecurring,
      isDraft: currentTask.isDraft,
      createdAt: currentTask.createdAt,
      updatedAt: DateTime.now(),
    );
    return await updateTask(taskId, updatedTask);
  }

  Future<bool> deleteTask(String taskId) async {
    final result = await deleteTaskUseCase(taskId);
    return result.fold((failure) {
      emit(TasksError(_mapFailureToMessage(failure)));
      return false;
    }, (_) => true);
  }

  Future<bool> addComment(String taskId, TaskCommentEntity comment) async {
    final result = await addCommentUseCase(taskId, comment);
    return result.fold((failure) {
      emit(TasksError(_mapFailureToMessage(failure)));
      return false;
    }, (_) => true);
  }

  // ----------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------

  String _mapFailureToMessage(dynamic failure) {
    return failure.toString();
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
