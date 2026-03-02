import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_for_team_usecase.dart';
import '../../domain/usecases/get_tasks_for_user_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final GetTasksForUserUseCase getTasksForUserUseCase;
  final GetTasksForTeamUseCase getTasksForTeamUseCase;
  final AddCommentUseCase addCommentUseCase;

  StreamSubscription? _tasksSubscription;

  TasksCubit({
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getTasksForUserUseCase,
    required this.getTasksForTeamUseCase,
    required this.addCommentUseCase,
  }) : super(TasksInitial());

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

  Future<void> createTask(TaskEntity task) async {
    emit(TasksLoading());
    final result = await createTaskUseCase(task);
    result.fold((failure) => emit(TasksError(_mapFailureToMessage(failure))), (
      taskId,
    ) {
      if (task.isDraft) {
        emit(TaskDraftSaved());
      } else {
        emit(TaskCreatedSuccess(taskId));
      }
    });
  }

  Future<void> updateTask(String taskId, TaskEntity task) async {
    final result = await updateTaskUseCase(taskId, task);
    result.fold(
      (failure) => emit(TasksError(_mapFailureToMessage(failure))),
      (_) => emit(TaskUpdatedSuccess()),
    );
  }

  Future<void> updateTaskStatus(
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
    await updateTask(taskId, updatedTask);
  }

  Future<void> deleteTask(String taskId) async {
    final result = await deleteTaskUseCase(taskId);
    result.fold(
      (failure) => emit(TasksError(_mapFailureToMessage(failure))),
      (_) => emit(TaskDeletedSuccess()),
    );
  }

  Future<void> addComment(String taskId, TaskCommentEntity comment) async {
    final result = await addCommentUseCase(taskId, comment);
    result.fold(
      (failure) => emit(TasksError(_mapFailureToMessage(failure))),
      (_) => emit(TaskCommentAdded()),
    );
  }

  String _mapFailureToMessage(dynamic failure) {
    // In a real app, match against failure types
    return failure.toString();
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
