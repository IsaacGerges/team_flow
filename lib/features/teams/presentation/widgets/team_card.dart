import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';

/// A card that displays a team summary for the My Teams list.
class TeamCard extends StatelessWidget {
  final TeamEntity team;
  final VoidCallback? onTap;
  final bool isAdmin;

  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TeamCardHeader(team: team, isAdmin: isAdmin),
              const SizedBox(height: 12),
              _TeamCardStats(team: team),
              const SizedBox(height: 12),
              _TeamCardProgress(team: team),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamCardHeader extends StatelessWidget {
  final TeamEntity team;
  final bool isAdmin;

  const _TeamCardHeader({required this.team, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TeamAvatar(team: team),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _updatedAtLabel(team.updatedAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        _RoleBadge(isAdmin: isAdmin),
      ],
    );
  }

  String _updatedAtLabel(DateTime? updatedAt) {
    if (updatedAt == null) return 'Updated just now';
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${diff.inDays}d ago';
  }
}

class _TeamAvatar extends StatelessWidget {
  final TeamEntity team;

  const _TeamAvatar({required this.team});

  @override
  Widget build(BuildContext context) {
    if (team.photoUrl != null && team.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: ImageHelper.getProvider(team.photoUrl),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primaryBlue,
      child: Text(
        team.name[0].toUpperCase(),
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isAdmin;

  const _RoleBadge({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGray),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAdmin ? AppStrings.adminRole : AppStrings.memberRole,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _TeamCardStats extends StatelessWidget {
  final TeamEntity team;

  const _TeamCardStats({required this.team});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.group_outlined, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          '${team.membersIds.length} ${AppStrings.members}',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.check_circle_outline,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${team.activeTaskCount} ${AppStrings.activeTasks}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _TeamCardProgress extends StatelessWidget {
  final TeamEntity team;

  const _TeamCardProgress({required this.team});

  @override
  Widget build(BuildContext context) {
    final percent = team.progressPercent.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.progress,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const Spacer(),
            Text(
              '${percent.toInt()}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: AppColors.lightGray,
            color: AppColors.primaryBlue,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
