import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/image_helper.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../../injection_container.dart';

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
            child: Row(
              children: [
                GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlue,
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.add, color: AppColors.primaryBlue),
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
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        avatar: CircleAvatar(
                          backgroundImage: ImageHelper.getProvider(
                            user.photoUrl ?? '',
                          ),
                        ),
                        label: Text(user.fullName),
                        onDeleted: () => onRemoveTag(uid),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        backgroundColor: AppColors.veryLightGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
