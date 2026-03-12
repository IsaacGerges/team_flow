import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/features/home/presentation/widgets/home_team_card.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';

class MyTeamsSection extends StatelessWidget {
  const MyTeamsSection({super.key});

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
                'My Teams',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/teams'),
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
        SizedBox(
          height: 210,
          child: BlocBuilder<TeamsCubit, TeamsState>(
            buildWhen: (p, c) => c is TeamsLoaded || c is TeamsLoading,
            builder: (context, state) {
              if (state is TeamsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                );
              }
              if (state is TeamsLoaded) {
                if (state.teams.isEmpty) return _buildEmptyState();

                return BlocBuilder<TasksCubit, TasksState>(
                  builder: (context, tasksState) {
                    List<TaskEntity> allTasks = [];
                    if (tasksState is TasksLoaded) allTasks = tasksState.tasks;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: state.teams.length,
                      itemBuilder: (context, index) {
                        final team = state.teams[index];
                        final teamTasks = allTasks
                            .where((t) => t.teamId == team.id)
                            .toList();
                        final activeCount = teamTasks
                            .where((t) => t.status != TaskStatus.done)
                            .length;
                        final doneCount = teamTasks
                            .where((t) => t.status == TaskStatus.done)
                            .length;
                        final progress = teamTasks.isEmpty
                            ? 0.0
                            : doneCount / teamTasks.length;

                        return HomeTeamCard(
                          team: team,
                          onTap: () =>
                              context.push('/teams/details', extra: team),
                          activeTaskCount: activeCount,
                          progressPercent: progress,
                        );
                      },
                    );
                  },
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
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_rounded, color: Color(0xFF94A3B8), size: 32),
          SizedBox(height: 12),
          Text(
            'No teams joined',
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
