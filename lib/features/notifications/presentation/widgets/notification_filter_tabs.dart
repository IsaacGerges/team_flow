import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import '../cubit/notifications_state.dart';

class NotificationFilterTabs extends StatelessWidget {
  final NotificationFilter activeFilter;
  final bool hasUnread;
  final Function(NotificationFilter) onFilterChanged;

  const NotificationFilterTabs({
    super.key,
    required this.activeFilter,
    required this.hasUnread,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: NotificationFilter.values.map((filter) {
          final isActive = filter == activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryBluePure : Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primaryBluePure
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBluePure.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getFilterName(filter),
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFF475569),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (filter == NotificationFilter.unread && hasUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : AppColors.unreadDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterName(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return AppStrings.filterAll;
      case NotificationFilter.unread:
        return AppStrings.filterUnread;
      case NotificationFilter.teams:
        return AppStrings.filterTeams;
      case NotificationFilter.tasks:
        return AppStrings.filterTasks;
      case NotificationFilter.mentions:
        return AppStrings.filterMentions;
    }
  }
}
