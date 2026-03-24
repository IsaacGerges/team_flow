import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:team_flow/features/home/presentation/widgets/greeting_header.dart';
import 'package:team_flow/features/home/presentation/widgets/home_stats_section.dart';
import 'package:team_flow/features/home/presentation/widgets/my_teams_section.dart';
import 'package:team_flow/features/home/presentation/widgets/recent_tasks_section.dart';
import 'package:team_flow/core/helpers/cache_helper.dart';
import 'package:team_flow/injection_container.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F7F8),
      body: SafeArea(child: _HomeContent()),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  void _loadDataForCurrentUser() {
    final userId =
        FirebaseAuth.instance.currentUser?.uid ??
        sl<CacheHelper>().getData(key: CacheKeys.userId) as String?;
    if (userId == null) return;
    context.read<ProfileCubit>().getProfile(userId);
    context.read<NotificationsCubit>().loadNotifications(userId);

    final teamsState = context.read<TeamsCubit>().state;
    if (teamsState is TeamsLoaded) {
      final teamIds = teamsState.teams.map((t) => t.id).toList();
      context.read<TasksCubit>().loadTasksForTeams(teamIds);
    } else {
      context.read<TeamsCubit>().getTeams(userId);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeamsCubit, TeamsState>(
      listener: (context, state) {
        if (state is TeamsLoaded) {
          final teamIds = state.teams.map((t) => t.id).toList();
          context.read<TasksCubit>().loadTasksForTeams(teamIds);
        }
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            GreetingHeader(),
            SizedBox(height: 8),
            HomeStatsSection(),
            SizedBox(height: 32),
            MyTeamsSection(),
            SizedBox(height: 32),
            RecentTasksSection(),
          ],
        ),
      ),
    );
  }
}
