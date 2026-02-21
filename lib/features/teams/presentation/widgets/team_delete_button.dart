import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';

/// A delete icon button with a confirmation dialog for a team.
class TeamDeleteButton extends StatelessWidget {
  final TeamEntity team;

  const TeamDeleteButton({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: AppColors.error),
      onPressed: () => _showDeleteConfirmation(context),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final cubit = context.read<TeamsCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BlocConsumer<TeamsCubit, TeamsState>(
          listener: (context, state) {
            if (state is TeamDeletedSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.teamDeleted),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is TeamsError) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: const Text(AppStrings.deleteTeam),
              content: Text(
                '${AppStrings.deleteTeamConfirmation} "${team.name}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
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
                        context.read<TeamsCubit>().deleteTeam(team.id),
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
