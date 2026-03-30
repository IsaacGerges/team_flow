import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';

/// Compact task card used on the home dashboard.
class HomeTaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;

  const HomeTaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.status == TaskStatus.done;
    final String dateText = task.dueDate != null
        ? _getRelativeDateText(task.dueDate!)
        : AppStrings.noDate;
    final String timeText = task.dueDate != null
        ? DateFormat('hh:mm a').format(task.dueDate!)
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDone ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate100),
            boxShadow: [
              if (!isDone)
                BoxShadow(
                  color: AppColors.slate800.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purpleBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.teamName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.purple700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _buildStatusPill(task.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate800,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.slate400,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.slate400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate500,
                    ),
                  ),
                  if (timeText.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.slate400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (task.priority == TaskPriority.high)
                    const Icon(
                      Icons.flag_rounded,
                      color: AppColors.red500,
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(TaskStatus status) {
    final (Color bgColor, Color textColor, String label) = switch (status) {
      TaskStatus.todo => (
        AppColors.taskTodoBg,
        AppColors.taskTodoText,
        AppStrings.toDo,
      ),
      TaskStatus.inProgress => (
        AppColors.taskInProgressBg,
        AppColors.taskInProgressText,
        AppStrings.inProgressLabel,
      ),
      TaskStatus.review => (
        AppColors.taskReviewBg,
        AppColors.taskReviewText,
        AppStrings.review,
      ),
      TaskStatus.done => (
        AppColors.taskDoneBg,
        AppColors.taskDoneText,
        AppStrings.done,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  String _getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);
    if (checkDate == today) return AppStrings.today;
    if (checkDate == tomorrow) {
      return AppStrings.tomorrow;
    }
    return DateFormat('MMM d').format(date);
  }
}
