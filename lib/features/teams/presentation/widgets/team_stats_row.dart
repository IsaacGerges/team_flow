import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';

/// Displays team summary statistics in a styled row.
class TeamStatsRow extends StatelessWidget {
  final TeamEntity team;

  const TeamStatsRow({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          label: AppStrings.members,
          value: '${team.membersIds.length}',
        ),
        _Divider(),
        _StatItem(
          label: AppStrings.activeTasksShort,
          value: '8',
          valueColor: AppColors.primaryBlue,
        ),
        _Divider(),
        _StatItem(
          label: AppStrings.completedShort,
          value: '${team.progressPercent.toInt()}%',
          valueColor: AppColors.success,
          trailingIcon: Icons.trending_up,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? trailingIcon;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 2),
                Icon(trailingIcon, size: 14, color: valueColor),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 32, width: 1, color: AppColors.divider);
  }
}
