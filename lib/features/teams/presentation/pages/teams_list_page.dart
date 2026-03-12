import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/features/teams/presentation/widgets/team_card.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';

class TeamsListPage extends StatefulWidget {
  const TeamsListPage({super.key});

  @override
  State<TeamsListPage> createState() => _TeamsListPageState();
}

class _TeamsListPageState extends State<TeamsListPage> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    context.read<TeamsCubit>().getTeams(userId);
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF2B6CEE);

    return BlocListener<TeamsCubit, TeamsState>(
      listener: (context, state) {
        if (state is TeamDeletedSuccess) {
          _showSnackBar(
            context,
            'Team removed successfully',
            AppColors.success,
          );
        } else if (state is TeamsError) {
          _showSnackBar(context, state.message, AppColors.error);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F8),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<TeamsCubit, TeamsState>(
                  builder: (context, state) {
                    if (state is TeamsLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: primaryBlue,
                        ),
                      );
                    }
                    if (state is TeamsLoaded) {
                      if (state.teams.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildTeamsList(state.teams);
                    }
                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => context.push('/teams/create'),
            backgroundColor: primaryBlue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8).withValues(alpha: 0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x1A2B6CEE)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Teams',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              _buildHeaderAction(Icons.search),
              _buildHeaderAction(Icons.filter_list),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: const Color(0xFF475569),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsList(List<TeamEntity> teams) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, tasksState) {
        List<TaskEntity> allTasks = [];
        if (tasksState is TasksLoaded) {
          allTasks = tasksState.tasks;
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
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

            return TeamCard(
              team: team,
              isAdmin: team.adminId == currentUserId,
              activeTaskCount: activeCount,
              progressPercent: progress,
              onTap: () => context.push('/teams/details', extra: team),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final primaryBlue = const Color(0xFF2B6CEE);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                      style: BorderStyle.none,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.groups,
                      size: 64,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                // Dashed circle decoration (simplified as Border)
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'No teams yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You aren't part of any team yet. Create one to get started collaborating.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/teams/create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Create Team',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
