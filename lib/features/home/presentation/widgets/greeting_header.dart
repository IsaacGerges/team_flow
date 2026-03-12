import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_state.dart';

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
                  "Let's check your updates",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _buildNotificationIcon(),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
                    color: Color(0xFF94A3B8),
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
        String name = 'User';
        if (state is ProfileLoaded) {
          name = state.profile.fullName.split(' ').first;
        }
        return Text(
          '${_getGreeting()}, $name!',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            height: 1.25,
          ),
        );
      },
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent, // using Material / InkWell for hover
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              highlightColor: const Color(0xFFE2E8F0),
              splashColor: const Color(0xFFCBD5E1),
              onTap: () {},
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF475569),
                size: 24,
              ),
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444), // red-500
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF6F7F8),
                width: 2,
              ), // matching background cut
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
