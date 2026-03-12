import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../../../core/helpers/image_helper.dart';
import '../../../../injection_container.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import 'task_status_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final Function(bool?) onCheckboxChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCheckboxChanged,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                // Priority color indicator (Stripe on the left)
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
                            // Custom Rounded Checkbox
                            GestureDetector(
                              onTap: () => onCheckboxChanged(!isDone),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDone
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFE2E8F0),
                                    width: 2,
                                  ),
                                  color: isDone
                                      ? const Color(0xFF22C55E)
                                      : Colors.transparent,
                                ),
                                child: isDone
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                            ),
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
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF1E293B),
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
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            TaskStatusBadge(
                              status: task.status,
                              isOverdue: isOverdue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Category Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${task.teamName.replaceAll(' ', '')}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Assigned by',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
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
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      backgroundImage: photo,
                                      child: photo == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 14,
                                              color: Color(0xFF94A3B8),
                                            )
                                          : null,
                                    );
                                  }
                                  return const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Color(0xFFF1F5F9),
                                    child: Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Color(0xFF94A3B8),
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

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFEF4444);
      case TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case TaskPriority.low:
        return const Color(0xFF22C55E);
    }
  }
}
