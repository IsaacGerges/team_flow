import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';

class TeamCard extends StatelessWidget {
  final TeamEntity team;
  final VoidCallback? onTap;
  final bool isAdmin;
  final int activeTaskCount;
  final double progressPercent;

  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
    this.isAdmin = false,
    this.activeTaskCount = 0,
    this.progressPercent = 0.0,
  });

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return AppStrings.updatedRecently;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return AppStrings.updatedJustNow;
    if (diff.inMinutes < 60) {
      return '${AppStrings.updated} ${diff.inMinutes}m ${AppStrings.ago}';
    }
    if (diff.inHours < 24) {
      return '${AppStrings.updated} ${diff.inHours}h ${AppStrings.ago}';
    }
    if (diff.inDays < 7) {
      return '${AppStrings.updated} ${diff.inDays}d ${AppStrings.ago}';
    }
    return '${AppStrings.updatedOn} ${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimeAgo(team.updatedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRoleBadge(),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatItem(
                  Icons.group,
                  '${team.membersIds.length} ${AppStrings.members}',
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  Icons.task_alt,
                  '$activeTaskCount ${AppStrings.activeTasksSuffix}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final hasPhoto = team.photoUrl != null && team.photoUrl!.isNotEmpty;
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: hasPhoto
            ? Image(
                image: ImageHelper.getProvider(team.photoUrl)!,
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.dstATop,
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.orangeBorder, AppColors.amberBorder],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    team.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.orange600,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? AppColors.primaryBlue.withValues(alpha: 0.1)
            : AppColors.slate100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdmin
              ? AppColors.primaryBlue.withValues(alpha: 0.2)
              : AppColors.slate200,
        ),
      ),
      child: Text(
        isAdmin ? AppStrings.admin : AppStrings.member,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAdmin ? AppColors.primaryBlue : AppColors.slate500,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.slate400),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.slate600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow() {
    final percent = (progressPercent * 100).toInt();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.progress,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercent.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.slate100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.chevron_right, color: AppColors.slate400),
      ],
    );
  }
}
