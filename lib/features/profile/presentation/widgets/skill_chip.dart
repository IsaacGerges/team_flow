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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.blueBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.blue200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: AppColors.primaryBlue, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.slate600,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          if (isRemovable) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.slate500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
