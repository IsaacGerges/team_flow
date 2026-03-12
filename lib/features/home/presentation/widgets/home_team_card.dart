import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_state.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/injection_container.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';

class HomeTeamCard extends StatelessWidget {
  final TeamEntity team;
  final VoidCallback onTap;
  final int activeTaskCount;
  final double progressPercent;

  const HomeTeamCard({
    super.key,
    required this.team,
    required this.onTap,
    required this.activeTaskCount,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    final progressInt = (progressPercent * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 256,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildTeamPhoto(), _buildCategoryBadge()],
            ),
            const SizedBox(height: 16),
            Text(
              team.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$activeTaskCount Active tasks',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAvatarCluster(),
                Text(
                  '$progressInt%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getCategoryColor(team.category).iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({Color bgColor, Color iconColor}) _getCategoryColor(String category) {
    if (category.toLowerCase().contains('design')) {
      return (
        bgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
      );
    }
    if (category.toLowerCase().contains('marketing') ||
        category.toLowerCase().contains('growth')) {
      return (
        bgColor: const Color(0xFFFCE7F3),
        iconColor: const Color(0xFFDB2777),
      );
    }
    if (category.toLowerCase().contains('dev') ||
        category.toLowerCase().contains('tech')) {
      return (
        bgColor: const Color(0xFFDBEAFE),
        iconColor: const Color(0xFF2563EB),
      );
    }
    return (
      bgColor: const Color(0xFFF1F5F9),
      iconColor: const Color(0xFF64748B),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.toLowerCase().contains('design')) {
      return Icons.design_services_rounded;
    }
    if (category.toLowerCase().contains('marketing')) {
      return Icons.campaign_rounded;
    }
    if (category.toLowerCase().contains('dev') ||
        category.toLowerCase().contains('tech')) {
      return Icons.code_rounded;
    }
    return Icons.work_outline_rounded;
  }

  Widget _buildTeamPhoto() {
    final colors = _getCategoryColor(team.category);
    final provider = ImageHelper.getProvider(team.photoUrl);

    if (provider != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: provider, fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(team.category),
          color: colors.iconColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        team.category.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAvatarCluster() {
    if (team.membersIds.isEmpty) {
      return const SizedBox(height: 24);
    }
    final displayIds = team.membersIds.take(3).toList();
    final extraCount = team.membersIds.length - 3;

    final int totalSlots = displayIds.length + (extraCount > 0 ? 1 : 0);
    final double clusterWidth = (totalSlots - 1) * 20.0 + 28;

    return SizedBox(
      height: 28,
      width: clusterWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < displayIds.length; i++)
            Positioned(left: i * 20.0, child: _buildAvatar(displayIds[i])),
          if (extraCount > 0)
            Positioned(
              left: displayIds.length * 20.0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$extraCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String uid) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..getProfile(uid),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded &&
              state.profile.photoUrl != null &&
              state.profile.photoUrl!.isNotEmpty) {
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                image: DecorationImage(
                  image: ImageHelper.getProvider(state.profile.photoUrl!)!,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, size: 14, color: Color(0xFF94A3B8)),
          );
        },
      ),
    );
  }
}
