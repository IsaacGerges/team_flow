import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';

class HomeTaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;

  const HomeTaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.status == TaskStatus.done;
    final String dateText = task.dueDate != null
        ? _getRelativeDateText(task.dueDate!)
        : 'No date';
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              if (!isDone)
                BoxShadow(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.05),
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
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.teamName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7E22CE),
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
                  color: const Color(0xFF1E293B),
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (timeText.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (task.priority == 'high')
                    const Icon(
                      Icons.flag_rounded,
                      color: Color(0xFFEF4444),
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
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case TaskStatus.todo:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        label = 'To Do';
        break;
      case TaskStatus.inProgress:
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFC2410C);
        label = 'In Progress';
        break;
      case TaskStatus.review:
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFEF4444);
        label = 'Review';
        break;
      case TaskStatus.done:
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF15803D);
        label = 'Done';
        break;
    }

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
    if (checkDate == today) return 'Today';
    if (checkDate == tomorrow) return 'Tomorrow';
    return DateFormat('MMM d').format(date);
  }
}
