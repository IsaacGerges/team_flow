import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_state.dart';
import 'package:team_flow/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:team_flow/features/notifications/presentation/cubit/notifications_state.dart';

/// Greeting header showing avatar, greeting text, and notification bell.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGreetingText(),
                const Text(
                  AppStrings.letsCheckUpdates,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          _buildNotificationIcon(context),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final hasPhoto =
            state is ProfileLoaded &&
            state.profile.photoUrl != null &&
            state.profile.photoUrl!.isNotEmpty;
        return Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.slate200, width: 1),
            image: hasPhoto
                ? DecorationImage(
                    image: ImageHelper.getProvider(state.profile.photoUrl!)!,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: !hasPhoto
              ? const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.slate400,
                    size: 20,
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildGreetingText() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        String name = AppStrings.user;
        if (state is ProfileLoaded) {
          name = state.profile.fullName.split(' ').first;
        }
        return Text(
          '${_getGreeting()}, $name!',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.slate800,
            height: 1.25,
          ),
        );
      },
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final hasUnread =
            state is NotificationsLoaded &&
            state.notifications.any((n) => !n.isRead);

        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.transparent,
              ),
              child: Material(
                color: AppColors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  highlightColor: AppColors.slate200,
                  splashColor: AppColors.slate300,
                  onTap: () => context.go('/notifications'),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.slate600,
                    size: 26,
                  ),
                ),
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.red500,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundDashboard,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }
}
