import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import '../../domain/entities/task_entity.dart';

/// A coloured pill badge that shows the current [TaskStatus].
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
    final (label, bgColor, textColor) = _getData();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (String, Color, Color) _getData() {
    if (isOverdue && status != TaskStatus.done) {
      return (
        AppStrings.overdue,
        AppColors.taskReviewBg,
        AppColors.taskReviewText,
      );
    }

    return switch (status) {
      TaskStatus.todo => (
        AppStrings.toDo,
        AppColors.taskTodoBg,
        AppColors.taskTodoText,
      ),
      TaskStatus.review => (
        AppStrings.review,
        AppColors.taskInProgressBg,
        AppColors.taskInProgressText,
      ),
      TaskStatus.inProgress => (
        AppStrings.inProgressLabel,
        AppColors.blueBg,
        AppColors.primaryBlue,
      ),
      TaskStatus.done => (
        AppStrings.done,
        AppColors.taskDoneBg,
        AppColors.taskDoneText,
      ),
    };
  }
}
