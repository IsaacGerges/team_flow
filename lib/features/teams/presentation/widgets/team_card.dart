import 'package:flutter/material.dart';
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
    if (date == null) return 'Updated recently';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    if (diff.inDays < 7) return 'Updated ${diff.inDays}d ago';
    return 'Updated on ${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimeAgo(team.updatedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
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
                  '${team.membersIds.length} Members',
                ),
                const SizedBox(width: 24),
                _buildStatItem(Icons.task_alt, '$activeTaskCount Active Tasks'),
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
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                    colors: [Color(0xFFFFEDD5), Color(0xFFFEF3C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    team.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFEA580C),
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
    final primaryBlue = const Color(0xFF2B6CEE);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? primaryBlue.withValues(alpha: 0.1)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdmin
              ? primaryBlue.withValues(alpha: 0.2)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Member',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAdmin ? primaryBlue : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow() {
    final primaryBlue = const Color(0xFF2B6CEE);
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
                    'Progress',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryBlue,
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
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
      ],
    );
  }
}
