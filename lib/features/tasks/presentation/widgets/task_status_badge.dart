import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/task_entity.dart';

class TaskStatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool isOverdue;

  const TaskStatusBadge({
    super.key,
    required this.status,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    if (isOverdue && status != TaskStatus.done) {
      color = AppColors.error;
      label = 'OVERDUE';
    } else {
      switch (status) {
        case TaskStatus.todo:
          color = AppColors.taskTodo;
          label = 'TO DO';
          break;
        case TaskStatus.inProgress:
          color = AppColors.taskInProgress;
          label = 'IN PROGRESS';
          break;
        case TaskStatus.review:
          color = AppColors.warning;
          label = 'REVIEW';
          break;
        case TaskStatus.done:
          color = AppColors.taskDone;
          label = 'DONE';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
