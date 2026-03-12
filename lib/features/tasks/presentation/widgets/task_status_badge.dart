import 'package:flutter/material.dart';
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
      return ('Overdue', const Color(0xFFFEF2F2), const Color(0xFFEF4444));
    }

    return switch (status) {
      TaskStatus.todo => (
        'To Do',
        const Color(0xFFF1F5F9),
        const Color(0xFF64748B),
      ),
      TaskStatus.review => (
        'Review',
        const Color(0xFFFFF7ED),
        const Color(0xFFEA580C),
      ),
      TaskStatus.inProgress => (
        'In Progress',
        const Color(0xFFEFF6FF),
        const Color(0xFF3B82F6),
      ),
      TaskStatus.done => (
        'Done',
        const Color(0xFFF0FDF4),
        const Color(0xFF22C55E),
      ),
    };
  }
}
