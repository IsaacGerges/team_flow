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
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                (isPrimary ? AppColors.primaryBlue : const Color(0xFF1E293B))
                    .withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: isPrimary ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isPrimary ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.8)
                  : const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
