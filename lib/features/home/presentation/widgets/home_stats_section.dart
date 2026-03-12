import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';

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
          final pending = tasks.where((t) => t.status != TaskStatus.done).length;
          final completed = tasks.where((t) => t.status == TaskStatus.done).length;

          return Row(
            children: [
              _buildStatCard(
                label: 'Total Tasks',
                count: total.toString(),
                textColor: const Color(0xFF2563EB), // text-primary / blue-600
                labelColor: const Color(0xFF1E40AF), // text-blue-800
                bgColor: const Color(0xFFEFF6FF), // bg-blue-50
                borderColor: const Color(0xFFDBEAFE), // border-blue-100
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Pending',
                count: pending.toString(),
                textColor: const Color(0xFFEA580C), // text-orange-600
                labelColor: const Color(0xFF9A3412), // text-orange-800
                bgColor: const Color(0xFFFFF7ED), // bg-orange-50
                borderColor: const Color(0xFFFFEDD5), // border-orange-100
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Completed',
                count: completed.toString(),
                textColor: const Color(0xFF15803D), // text-green-700
                labelColor: const Color(0xFF166534), // text-green-800
                bgColor: const Color(0xFFECFDF5), // bg-green-50
                borderColor: const Color(0xFFD1FAE5), // border-green-100
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
              color: const Color(0xFF1E293B).withValues(alpha: 0.05), // Light drop shadow mocking Tailwind shadow-sm
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
