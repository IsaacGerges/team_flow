import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/features/home/presentation/widgets/home_team_card.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/core/helpers/progress_helper.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';

/// Horizontal scrolling list of the user's teams on the dashboard.
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
                AppStrings.myTeams,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate800,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/teams'),
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
        SizedBox(
          height: 210,
          child: BlocBuilder<TeamsCubit, TeamsState>(
            buildWhen: (p, c) => c is TeamsLoaded || c is TeamsLoading,
            builder: (context, state) {
              if (state is TeamsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                );
              }
              if (state is TeamsLoaded) {
                if (state.teams.isEmpty) {
                  return _buildEmptyState();
                }

                return BlocBuilder<TasksCubit, TasksState>(
                  builder: (context, tasksState) {
                    List<TaskEntity> allTasks = [];
                    if (tasksState is TasksLoaded) {
                      allTasks = tasksState.tasks;
                    }

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
                        final progress = ProgressHelper.calculateTasksProgress(
                          teamTasks,
                        );

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
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_rounded, color: AppColors.slate400, size: 32),
          SizedBox(height: 12),
          Text(
            AppStrings.noTeamsJoined,
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
