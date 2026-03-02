import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/features/teams/presentation/widgets/team_card.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';

/// Displays the list of all teams for the current user.
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
    return BlocListener<TeamsCubit, TeamsState>(
      listener: (context, state) {
        if (state is TeamDeletedSuccess) {
          _showSnackBar(context, AppStrings.teamDeleted, AppColors.success);
        } else if (state is TeamUpdatedSuccess) {
          _showSnackBar(context, AppStrings.teamUpdated, AppColors.success);
        } else if (state is TeamsError) {
          _showSnackBar(context, state.message, AppColors.error);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundScreen,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundScreen,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            AppStrings.myTeams,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textPrimary),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.tune, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<TeamsCubit, TeamsState>(
          buildWhen: (prev, curr) =>
              curr is TeamsLoading || curr is TeamsLoaded || curr is TeamsError,
          builder: (context, state) {
            if (state is TeamsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }
            if (state is TeamsLoaded) {
              if (state.teams.isEmpty) {
                return const _EmptyTeamsView();
              }
              return _TeamsList(teams: state.teams);
            }
            if (state is TeamsError) {
              return Center(
                child: Text(
                  '${AppStrings.errorPrefix}${state.message}',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }
            return const _EmptyTeamsView();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/teams/create'),
          backgroundColor: AppColors.primaryBlue,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}

class _EmptyTeamsView extends StatelessWidget {
  const _EmptyTeamsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryBlueLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_outlined,
                size: 48,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.noTeamsYet,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noTeamsHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/teams/create'),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.createFirstTeam),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamsList extends StatelessWidget {
  final List<TeamEntity> teams;

  const _TeamsList({required this.teams});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 90),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        final isAdmin = team.adminId == currentUserId;
        return TeamCard(
          team: team,
          isAdmin: isAdmin,
          onTap: () => context.push('/teams/details', extra: team),
        );
      },
    );
  }
}
