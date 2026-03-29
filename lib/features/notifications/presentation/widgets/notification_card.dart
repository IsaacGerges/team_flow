import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/notification_entity.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeading(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Color(0xFF1E293B),
                            ),
                            children: _buildMessageSpans(),
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4, left: 8),
                          decoration: const BoxDecoration(
                            color: AppColors.unreadDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRelativeTime(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  if (_hasActions()) ...[
                    const SizedBox(height: 12),
                    _buildActions(),
                  ],
                  if (notification.type == NotificationType.teamActivity) ...[
                    const SizedBox(height: 12),
                    _buildFilePreview(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    switch (notification.type) {
      case NotificationType.mention:
      case NotificationType.assignment:
        return Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F5F9),
              ),
              child: ClipOval(
                child: notification.senderPhotoUrl != null
                    ? Image.network(
                        notification.senderPhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: Color(0xFF94A3B8)),
                      )
                    : const Icon(Icons.person, color: Color(0xFF94A3B8)),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: notification.type == NotificationType.mention
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.type == NotificationType.mention
                        ? Icons.alternate_email
                        : Icons.assignment_ind,
                    size: 10,
                    color: notification.type == NotificationType.mention
                        ? AppColors.primaryBlue
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ],
        );

      case NotificationType.taskAlert:
        return _buildIconLeading(
          Icons.alarm_rounded,
          AppColors.notificationAmber,
          AppColors.notificationAmberBg,
          badgeIcon: true,
        );

      case NotificationType.teamActivity:
        return Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                notification.teamInitials ?? '??',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        );

      case NotificationType.meetingInvite:
        return _buildIconLeading(
          Icons.event_rounded,
          AppColors.notificationPurple,
          AppColors.notificationPurpleBg,
        );

      case NotificationType.systemUpdate:
        return _buildIconLeading(
          Icons.security_update_good_rounded,
          const Color(0xFF64748B),
          const Color(0xFFF1F5F9),
        );
    }
  }

  Widget _buildIconLeading(
    IconData icon,
    Color color,
    Color bgColor, {
    bool badgeIcon = false,
  }) {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 24),
        ),
        if (badgeIcon)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
      ],
    );
  }

  List<TextSpan> _buildMessageSpans() {
    switch (notification.type) {
      case NotificationType.mention:
        return [
          TextSpan(
            text: notification.senderName ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: ' mentioned you in '),
          TextSpan(
            text: notification.targetName ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ];

      case NotificationType.assignment:
        return [
          TextSpan(
            text: notification.senderName ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: ' assigned you to '),
          TextSpan(
            text: notification.targetName ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ];

      case NotificationType.taskAlert:
      case NotificationType.meetingInvite:
        return [
          TextSpan(text: notification.title),
          if (notification.targetName != null) ...[
            const TextSpan(text: ': '),
            TextSpan(
              text: notification.targetName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ];

      case NotificationType.teamActivity:
        return [
          const TextSpan(text: 'Team '),
          TextSpan(
            text: notification.targetName ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: ' '),
          TextSpan(text: notification.body),
        ];

      case NotificationType.systemUpdate:
        return [TextSpan(text: notification.body)];
    }
  }

  bool _hasActions() {
    return notification.type == NotificationType.mention ||
        notification.type == NotificationType.taskAlert ||
        notification.type == NotificationType.meetingInvite;
  }

  Widget _buildActions() {
    switch (notification.type) {
      case NotificationType.mention:
        return _ActionBtn(
          label: AppStrings.reply,
          onPressed: () {},
          isPrimary: true,
        );
      case NotificationType.taskAlert:
        return Row(
          children: [
            _ActionBtn(
              label: AppStrings.viewTaskLabel,
              onPressed: () {},
              isPrimary: false,
            ),
            const SizedBox(width: 8),
            _ActionBtn(
              label: AppStrings.snooze,
              onPressed: () {},
              isPrimary: false,
              isGhost: true,
            ),
          ],
        );
      case NotificationType.meetingInvite:
        return Row(
          children: [
            _ActionBtn(
              label: AppStrings.accept,
              onPressed: () {},
              isPrimary: true,
            ),
            const SizedBox(width: 8),
            _ActionBtn(
              label: AppStrings.decline,
              onPressed: () {},
              isPrimary: false,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFilePreview() {
    return Row(
      children: [
        _FileIcon(icon: Icons.description_rounded),
        const SizedBox(width: 8),
        _FileIcon(icon: Icons.image_rounded),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text(
            '+1',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat.jm().format(dateTime)}';
    } else {
      return DateFormat('MMM d, j:mm a').format(dateTime);
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isGhost;

  const _ActionBtn({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isGhost = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppColors.primaryBlue
              : (isGhost ? Colors.transparent : const Color(0xFFF1F5F9)),
          foregroundColor: isPrimary
              ? Colors.white
              : (isGhost ? const Color(0xFF64748B) : const Color(0xFF1E293B)),
          elevation: isPrimary ? 2 : 0,
          shadowColor: isPrimary
              ? AppColors.primaryBlue.withValues(alpha: 0.4)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isGhost ? BorderSide.none : BorderSide.none,
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        child: Text(label),
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  final IconData icon;

  const _FileIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: const Color(0xFFCBD5E1)),
    );
  }
}
