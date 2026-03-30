import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/home/presentation/widgets/home_task_card.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';

/// Recent tasks list on the home dashboard.
class RecentTasksSection extends StatefulWidget {
  const RecentTasksSection({super.key});

  @override
  State<RecentTasksSection> createState() => _RecentTasksSectionState();
}

class _RecentTasksSectionState extends State<RecentTasksSection> {
  List<TaskEntity>? _lastTasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.recentTasks,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate800,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/tasks'),
                child: const Text(
                  AppStrings.seeAllSmall,
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              if (state is TasksLoaded) {
                _lastTasks = state.tasks;
              }
              if (state is TasksLoading && _lastTasks == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                );
              }

              if (_lastTasks != null) {
                final recentTasks =
                    _lastTasks!.where((t) => !t.isDraft).toList()
                      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                final displayTasks = recentTasks.take(5).toList();

                if (displayTasks.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: displayTasks
                      .map(
                        (task) => HomeTaskCard(
                          task: task,
                          onTap: () =>
                              context.push('/tasks/details', extra: task),
                        ),
                      )
                      .toList(),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: const Column(
        children: [
          Icon(Icons.assignment_rounded, color: AppColors.slate400, size: 32),
          SizedBox(height: 12),
          Text(
            AppStrings.noRecentTasksMessage,
            style: TextStyle(
              color: AppColors.slate500,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
