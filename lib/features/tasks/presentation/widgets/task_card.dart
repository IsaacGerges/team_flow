import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import '../../domain/entities/task_entity.dart';
import '../../../../core/helpers/image_helper.dart';
import '../../../../injection_container.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import 'task_status_badge.dart';

/// A card widget that displays a single task with priority indicator,
/// status badge, and assignee avatar.
///
/// When [isDraftCard] is `true`:
/// - The completion checkbox is replaced with a pencil icon.
/// - The status badge is replaced with a "DRAFT" pill.
class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;

  /// Called when the user taps the completion toggle.
  /// Ignored when [isDraftCard] is `true`.
  final Function(bool?) onCheckboxChanged;

  /// Whether this card represents a draft (creator-only visibility).
  final bool isDraftCard;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCheckboxChanged,
    this.isDraftCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.status == TaskStatus.done;
    final bool isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !isDone;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: _getPriorityColor(task.priority)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLeadingIcon(isDone),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isDone
                                          ? AppColors.slate400
                                          : AppColors.slate800,
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (task.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.slate500,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            isDraftCard
                                ? _DraftPill()
                                : TaskStatusBadge(
                                    status: task.status,
                                    isOverdue: isOverdue,
                                  ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.slate100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${task.teamName.replaceAll(' ', '')}',
                                style: const TextStyle(
                                  color: AppColors.slate500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              AppStrings.assignedBy,
                              style: TextStyle(
                                color: AppColors.slate400,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            BlocProvider(
                              create: (_) =>
                                  sl<ProfileCubit>()
                                    ..getProfile(task.creatorId),
                              child: BlocBuilder<ProfileCubit, ProfileState>(
                                builder: (context, state) {
                                  if (state is ProfileLoaded) {
                                    final photo = ImageHelper.getProvider(
                                      state.profile.photoUrl ?? '',
                                    );
                                    return CircleAvatar(
                                      radius: 12,
                                      backgroundColor: AppColors.slate100,
                                      backgroundImage: photo,
                                      child: photo == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 14,
                                              color: AppColors.slate400,
                                            )
                                          : null,
                                    );
                                  }
                                  return const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.slate100,
                                    child: Icon(
                                      Icons.person,
                                      size: 14,
                                      color: AppColors.slate400,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a pencil icon for drafts instead of the completion checkbox.
  Widget _buildLeadingIcon(bool isDone) {
    if (isDraftCard) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.slate100,
        ),
        child: const Icon(
          Icons.edit_outlined,
          color: AppColors.slate400,
          size: 14,
        ),
      );
    }

    return GestureDetector(
      onTap: () => onCheckboxChanged(!isDone),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDone ? AppColors.taskDone : AppColors.slate200,
            width: 2,
          ),
          color: isDone ? AppColors.taskDone : AppColors.transparent,
        ),
        child: isDone
            ? const Icon(
                Icons.check,
                color: AppColors.white,
                size: 14,
              )
            : null,
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.high => AppColors.priorityHigh,
      TaskPriority.medium => AppColors.priorityMedium,
      TaskPriority.low => AppColors.priorityLow,
    };
  }
}

/// A small pill badge shown in place of the status badge on draft cards.
class _DraftPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.slate500,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        AppStrings.draft,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
