import '../../features/tasks/domain/entities/task_entity.dart';

class ProgressHelper {
  /// Returns progress weight for a task status.
  /// Mapping:
  /// - todo: 0%
  /// - inProgress: 25%
  /// - review: 75%
  /// - done: 100%
  static double getTaskStatusWeight(TaskStatus status) {
    return switch (status) {
      TaskStatus.todo => 0.0,
      TaskStatus.inProgress => 0.25,
      TaskStatus.review => 0.75,
      TaskStatus.done => 1.0,
    };
  }

  /// Calculates overall progress [0.0 - 1.0] across a list of tasks.
  static double calculateTasksProgress(List<TaskEntity> tasks) {
    if (tasks.isEmpty) return 0.0;
    final totalWeight = tasks.fold<double>(
      0.0,
      (sum, task) => sum + getTaskStatusWeight(task.status),
    );
    return totalWeight / tasks.length;
  }
}
