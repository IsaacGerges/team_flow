import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final bool isRemovable;
  final bool isAddButton;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const SkillChip({
    super.key,
    required this.label,
    this.isRemovable = false,
    this.isAddButton = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (isAddButton) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    if (isRemovable) {
      return Container(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
