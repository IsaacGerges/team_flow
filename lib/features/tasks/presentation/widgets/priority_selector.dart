import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import '../../domain/entities/task_entity.dart';

/// A horizontal priority selector widget with colored dot indicators.
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
                color: isSelected ? AppColors.blueBg : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.slate200,
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
                          ? AppColors.slate800
                          : AppColors.slate500,
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
      TaskPriority.high => (AppStrings.high, AppColors.priorityHigh),
      TaskPriority.medium => (AppStrings.medium, AppColors.priorityMedium),
      TaskPriority.low => (AppStrings.low, AppColors.priorityLow),
    };
  }
}
