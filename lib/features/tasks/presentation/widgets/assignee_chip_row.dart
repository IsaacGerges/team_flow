import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import '../../../../core/helpers/image_helper.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../../injection_container.dart';

/// A horizontal scrollable row of assignee avatar chips.
class AssigneeChipRow extends StatelessWidget {
  final List<String> assigneeIds;
  final VoidCallback onAddTap;
  final Function(String) onRemoveTag;

  const AssigneeChipRow({
    super.key,
    required this.assigneeIds,
    required this.onAddTap,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..getAllUsers(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.slate300, width: 1.5),
                    ),
                    child: const Icon(Icons.add, color: AppColors.slate500),
                  ),
                ),
                const SizedBox(width: 12),
                if (state is ProfileLoadedAll)
                  ...assigneeIds.map((uid) {
                    final user = state.users.firstWhere(
                      (u) => u.uid == uid,
                      orElse: () => throw Exception('User not found'),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blueBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: ImageHelper.getProvider(
                                user.photoUrl ?? '',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.fullName.split(' ').first,
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => onRemoveTag(uid),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
