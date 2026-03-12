import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';

class PrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = selectedPriority == priority;
        final (label, color) = _getPriorityData(priority);

        return Expanded(
          child: GestureDetector(
            onTap: () => onPriorityChanged(priority),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF64748B),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  (String, Color) _getPriorityData(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.high => ('High', const Color(0xFFEF4444)),
      TaskPriority.medium => ('Medium', const Color(0xFFF59E0B)),
      TaskPriority.low => ('Low', const Color(0xFF22C55E)),
    };
  }
}
