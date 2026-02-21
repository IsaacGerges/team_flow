import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';

/// Displays detailed information about a single team.
class TeamDetailsPage extends StatelessWidget {
  final TeamEntity team;

  const TeamDetailsPage({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(team.name), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _TeamDetailHeader(team: team),
            const SizedBox(height: 32),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            _MembersSection(memberCount: team.membersIds.length),
          ],
        ),
      ),
    );
  }
}

class _TeamDetailHeader extends StatelessWidget {
  final TeamEntity team;

  const _TeamDetailHeader({required this.team});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.primary,
          child: Text(
            team.name[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Admin ID: ${team.adminId}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MembersSection extends StatelessWidget {
  final int memberCount;

  const _MembersSection({required this.memberCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.group_outlined, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$memberCount Members',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
