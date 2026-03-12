import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/features/home/presentation/widgets/home_task_card.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';

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
                'Recent Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/tasks'),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
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
              if (state is TasksLoaded) _lastTasks = state.tasks;
              if (state is TasksLoading && _lastTasks == null)
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                );

              if (_lastTasks != null) {
                final recentTasks =
                    _lastTasks!.where((t) => !t.isDraft).toList()
                      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                final displayTasks = recentTasks.take(5).toList();

                if (displayTasks.isEmpty) return _buildEmptyState();

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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.assignment_rounded, color: Color(0xFF94A3B8), size: 32),
          SizedBox(height: 12),
          Text(
            'No recent tasks',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
