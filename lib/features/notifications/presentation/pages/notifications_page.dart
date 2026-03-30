import 'package:flutter/material.dart';
import 'package:team_flow/core/usecases/get_current_user_id_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/injection_container.dart';
import 'package:team_flow/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:team_flow/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:team_flow/features/notifications/presentation/widgets/notification_card.dart';
import 'package:team_flow/features/notifications/presentation/widgets/notification_filter_tabs.dart';
import 'package:team_flow/features/notifications/domain/entities/notification_entity.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    final userId = sl<GetCurrentUserIdUseCase>()();
    if (userId != null) {
      context.read<NotificationsCubit>().loadNotifications(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                final activeFilter = state is NotificationsLoaded
                    ? state.activeFilter
                    : NotificationFilter.all;

                return NotificationFilterTabs(
                  activeFilter: activeFilter,
                  hasUnread:
                      state is NotificationsLoaded &&
                      state.notifications.any((n) => !n.isRead),
                  onFilterChanged: (filter) {
                    context.read<NotificationsCubit>().setFilter(filter);
                  },
                );
              },
            ),
            const Divider(height: 1, color: AppColors.slate100),
            Expanded(
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  if (state is NotificationsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is NotificationsError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is NotificationsLoaded) {
                    final filteredNotifications = _filterNotifications(
                      state.notifications,
                      state.activeFilter,
                    );

                    if (filteredNotifications.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildNotificationList(filteredNotifications);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              context.go('/home');
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          const Text(
            AppStrings.notifications,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppColors.slate800,
              letterSpacing: -0.5,
            ),
          ),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final hasUnread =
                  state is NotificationsLoaded &&
                  state.notifications.any((n) => !n.isRead);

              if (!hasUnread) {
                return const SizedBox(width: 48);
              }

              return IconButton(
                onPressed: () {
                  final userId = sl<GetCurrentUserIdUseCase>()();
                  if (userId != null) {
                    context.read<NotificationsCubit>().markAllAsRead(userId);
                  }
                },
                icon: const Icon(
                  Icons.done_all_rounded,
                  color: AppColors.primaryBlue,
                ),
                tooltip: AppStrings.markAllAsRead,
                style: IconButton.styleFrom(
                  hoverColor: AppColors.primaryBlue.withValues(alpha: 0.05),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<NotificationEntity> _filterNotifications(
    List<NotificationEntity> notifications,
    NotificationFilter filter,
  ) {
    switch (filter) {
      case NotificationFilter.all:
        return notifications;
      case NotificationFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.teams:
        return notifications
            .where((n) => n.type == NotificationType.teamActivity)
            .toList();
      case NotificationFilter.tasks:
        return notifications
            .where((n) => n.type == NotificationType.taskAlert)
            .toList();
      case NotificationFilter.mentions:
        return notifications
            .where((n) => n.type == NotificationType.mention)
            .toList();
    }
  }

  Widget _buildNotificationList(List<NotificationEntity> notifications) {
    final grouped = _groupNotificationsByDate(notifications);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final item = grouped[index];
        if (item is String) {
          return Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Text(
              item.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.slate500,
                letterSpacing: 1.2,
              ),
            ),
          );
        } else {
          final notification = item as NotificationEntity;
          return NotificationCard(
            notification: notification,
            onTap: () {
              context.read<NotificationsCubit>().markAsRead(notification.id);
            },
          );
        }
      },
    );
  }

  List<dynamic> _groupNotificationsByDate(
    List<NotificationEntity> notifications,
  ) {
    final List<dynamic> items = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    bool addedTodayHeader = false;
    bool addedYesterdayHeader = false;
    bool addedOlderHeader = false;

    for (final notification in notifications) {
      final date = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (date == today) {
        if (!addedTodayHeader) {
          items.add(AppStrings.today);
          addedTodayHeader = true;
        }
      } else if (date == yesterday) {
        if (!addedYesterdayHeader) {
          items.add(AppStrings.yesterday);
          addedYesterdayHeader = true;
        }
      } else {
        if (!addedOlderHeader) {
          items.add(AppStrings.older);
          addedOlderHeader = true;
        }
      }
      items.add(notification);
    }
    return items;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.slate800.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: AppColors.slate300,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            AppStrings.noNotifications,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.slate800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.noNotificationsHint,
            style: TextStyle(fontSize: 14, color: AppColors.slate500),
          ),
        ],
      ),
    );
  }
}
