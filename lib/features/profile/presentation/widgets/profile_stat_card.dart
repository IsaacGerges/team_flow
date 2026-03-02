import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';

class ProfileStatCard extends StatelessWidget {
  final String count;
  final String label;
  final bool isPrimary;

  const ProfileStatCard({
    super.key,
    required this.count,
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPrimary ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPrimary ? AppColors.white : AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
