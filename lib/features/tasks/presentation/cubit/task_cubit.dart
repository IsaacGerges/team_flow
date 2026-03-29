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
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/domain/usecases/create_notification_usecase.dart';
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
  final CreateNotificationUseCase createNotificationUseCase;

  StreamSubscription? _tasksSubscription;

  TasksCubit({
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getTasksForUserUseCase,
    required this.getTasksForTeamUseCase,
    required this.getTasksForTeamsUseCase,
    required this.addCommentUseCase,
    required this.createNotificationUseCase,
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

  /// Loads tasks for multiple teams in a viewer-aware fashion:
  /// - All published tasks for [teamIds].
  /// - Only the [viewerId]'s own drafts from those teams.
  void loadTasksForTeams(
    List<String> teamIds, {
    required String viewerId,
  }) {
    if (teamIds.isEmpty) {
      emit(const TasksLoaded([]));
      return;
    }

    emit(TasksLoading());
    _tasksSubscription?.cancel();
    _tasksSubscription = getTasksForTeamsUseCase(
      teamIds,
      viewerId: viewerId,
    ).listen(
      (tasks) => emit(TasksLoaded(tasks)),
      onError: (error) => emit(TasksError(error.toString())),
    );
  }

  // ----------------------------------------------------------
  // Mutations
  // ----------------------------------------------------------

  /// Creates a task. Notifications are skipped when [task.isDraft] is true.
  Future<String?> createTask(TaskEntity task) async {
    final result = await createTaskUseCase(task);
    return result.fold(
      (failure) {
        emit(TasksError(_mapFailureToMessage(failure)));
        return null;
      },
      (taskId) {
        if (!task.isDraft) {
          _sendCreationNotifications(taskId, task);
        }
        return taskId;
      },
    );
  }

  Future<bool> updateTask(String taskId, TaskEntity task) async {
    final result = await updateTaskUseCase(taskId, task);
    return result.fold((failure) {
      emit(TasksError(_mapFailureToMessage(failure)));
      return false;
    }, (_) => true);
  }

  /// Publishes an existing draft by setting [isDraft] to false and
  /// sending the same notifications used for a freshly created task.
  Future<bool> publishDraft(String taskId, TaskEntity publishedTask) async {
    final taskToPublish = TaskEntity(
      id: taskId,
      title: publishedTask.title,
      description: publishedTask.description,
      teamId: publishedTask.teamId,
      teamName: publishedTask.teamName,
      assigneeIds: publishedTask.assigneeIds,
      creatorId: publishedTask.creatorId,
      priority: publishedTask.priority,
      status: publishedTask.status,
      startDate: publishedTask.startDate,
      dueDate: publishedTask.dueDate,
      isRecurring: publishedTask.isRecurring,
      isDraft: false,
      createdAt: publishedTask.createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await updateTaskUseCase(taskId, taskToPublish);
    return result.fold((failure) {
      emit(TasksError(_mapFailureToMessage(failure)));
      return false;
    }, (_) {
      _sendCreationNotifications(taskId, taskToPublish);
      return true;
    });
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
    return result.fold(
      (failure) {
        emit(TasksError(_mapFailureToMessage(failure)));
        return false;
      },
      (_) => true,
    );
  }

  // ----------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------

  /// Fans out assignment and creator notifications after a task is published.
  void _sendCreationNotifications(String taskId, TaskEntity task) {
    Future.wait([
      ...task.assigneeIds
          .where((id) => id != task.creatorId)
          .map(
            (assigneeId) => createNotificationUseCase(
              NotificationEntity(
                id: '',
                userId: assigneeId,
                type: NotificationType.assignment,
                title: 'New Task Assignment',
                body: 'You were assigned to: ${task.title}',
                targetId: taskId,
                targetName: task.title,
                senderName: 'Team Member',
                isRead: false,
                createdAt: DateTime.now(),
              ),
            ),
          ),
      createNotificationUseCase(
        NotificationEntity(
          id: '',
          userId: task.creatorId,
          type: NotificationType.taskAlert,
          title: 'Task Created',
          body: 'You created: ${task.title}',
          targetId: taskId,
          targetName: task.title,
          senderName: 'System',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      ),
    ]);
  }

  String _mapFailureToMessage(dynamic failure) => failure.toString();

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
