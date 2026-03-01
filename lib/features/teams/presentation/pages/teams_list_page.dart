import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/features/teams/presentation/widgets/team_card.dart';

/// Displays the list of teams for the current user.
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.teamDeleted),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is TeamUpdatedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.teamUpdated),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is TeamsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.myTeams),
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () => context.go('/profile'),
              child: const Text(AppStrings.profile),
            ),
          ],
        ),
        body: BlocBuilder<TeamsCubit, TeamsState>(
          builder: (context, state) {
            if (state is TeamsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TeamsLoaded) {
              if (state.teams.isEmpty) {
                return const _EmptyTeamsView();
              }
              return _TeamsList(teams: state.teams);
            }
            if (state is TeamsError) {
              return Center(
                child: Text('${AppStrings.errorPrefix}${state.message}'),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/teams/create'),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.newTeam),
        ),
      ),
    );
  }
}

class _EmptyTeamsView extends StatelessWidget {
  const _EmptyTeamsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 80, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            '${AppStrings.noTeamsYet}\n${AppStrings.noTeamsHint}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TeamsList extends StatelessWidget {
  final List teams;

  const _TeamsList({required this.teams});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        final currentUserId = FirebaseAuth.instance.currentUser!.uid;
        final isAdmin = team.adminId == currentUserId;

        return TeamCard(
          team: team,
          onTap: () {},
          trailing: isAdmin
              ? _TeamPopupMenu(team: team)
              : const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }
}

class _TeamPopupMenu extends StatelessWidget {
  final dynamic team;

  const _TeamPopupMenu({required this.team});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          context.push('/teams/update', extra: team);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, team.id, team.name);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 8),
              Text(AppStrings.edit),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppColors.error),
              SizedBox(width: 8),
              Text(AppStrings.delete, style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String teamId,
    String teamName,
  ) {
    final cubit = context.read<TeamsCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocConsumer<TeamsCubit, TeamsState>(
          listener: (listenerContext, state) {
            if (state is TeamDeletedSuccess || state is TeamsError) {
              Navigator.pop(dialogContext);
            }
          },
          builder: (builderContext, state) {
            return AlertDialog(
              title: const Text(AppStrings.deleteTeam),
              content: Text(
                '${AppStrings.deleteTeamConfirmation} "$teamName"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(AppStrings.cancel),
                ),
                if (state is TeamsLoading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  TextButton(
                    onPressed: () =>
                        builderContext.read<TeamsCubit>().deleteTeam(teamId),
                    child: const Text(
                      AppStrings.delete,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
