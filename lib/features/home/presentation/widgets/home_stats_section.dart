import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';

/// Stats cards showing total, pending, and completed task counts.
class HomeStatsSection extends StatefulWidget {
  const HomeStatsSection({super.key});

  @override
  State<HomeStatsSection> createState() => _HomeStatsSectionState();
}

class _HomeStatsSectionState extends State<HomeStatsSection> {
  List<TaskEntity>? _lastTasks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          if (state is TasksLoaded) {
            _lastTasks = state.tasks;
          }

          final tasks = _lastTasks ?? [];
          final total = tasks.length;
          final pending = tasks
              .where((t) => t.status != TaskStatus.done)
              .length;
          final completed = tasks
              .where((t) => t.status == TaskStatus.done)
              .length;

          return Row(
            children: [
              _buildStatCard(
                label: AppStrings.totalTasks,
                count: total.toString(),
                textColor: AppColors.primaryBlue,
                labelColor: AppColors.primaryBlueDark,
                bgColor: AppColors.blueBg,
                borderColor: AppColors.blueBorder,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: AppStrings.pending,
                count: pending.toString(),
                textColor: AppColors.orange600,
                labelColor: AppColors.orange800,
                bgColor: AppColors.orangeBg,
                borderColor: AppColors.orangeBorder,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: AppStrings.completed,
                count: completed.toString(),
                textColor: AppColors.green700,
                labelColor: AppColors.green800,
                bgColor: AppColors.greenBg,
                borderColor: AppColors.greenBorder,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String count,
    required Color textColor,
    required Color labelColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate800.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
