import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/teams/domain/usecases/delete_team_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/update_team_usecase.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/create_team_usecase.dart';

/// Manages state for the teams feature.
class TeamsCubit extends Cubit<TeamsState> {
  final CreateTeamUseCase createTeamUseCase;
  final GetTeamsUseCase getTeamsUseCase;
  final UpdateTeamUseCase updateTeamUseCase;
  final DeleteTeamUseCase deleteTeamUseCase;

  StreamSubscription? _teamsSubscription;
  String? _currentUserId;

  TeamsCubit({
    required this.createTeamUseCase,
    required this.getTeamsUseCase,
    required this.updateTeamUseCase,
    required this.deleteTeamUseCase,
  }) : super(const TeamsInitial());

  /// Starts listening to the real-time teams stream for the given user.
  void getTeams(String userId) {
    _currentUserId = userId;
    emit(const TeamsLoading());
    _teamsSubscription?.cancel();
    _teamsSubscription = getTeamsUseCase(userId).listen(
      (teams) => emit(TeamsLoaded(teams)),
      onError: (error) => emit(TeamsError(error.toString())),
    );
  }

  /// Creates a new team with the given name and admin.
  Future<void> createTeam(String teamName, String adminId) async {
    emit(const TeamsLoading());
    final result = await createTeamUseCase(teamName, adminId);
    result.fold(
      (failure) => emit(TeamsError(_mapFailureToMessage(failure))),
      (_) => emit(const TeamCreatedSuccess()),
    );
  }

  /// Updates the name of an existing team.
  Future<void> updateTeam(String teamId, String newName) async {
    emit(const TeamsLoading());
    final result = await updateTeamUseCase(teamId, newName);
    result.fold((failure) => emit(TeamsError(_mapFailureToMessage(failure))), (
      _,
    ) {
      emit(const TeamUpdatedSuccess());
      if (_currentUserId != null) getTeams(_currentUserId!);
    });
  }

  /// Deletes the team with the given id.
  Future<void> deleteTeam(String teamId) async {
    emit(const TeamsLoading());
    final result = await deleteTeamUseCase(teamId);
    result.fold((failure) => emit(TeamsError(_mapFailureToMessage(failure))), (
      _,
    ) {
      emit(const TeamDeletedSuccess());
      if (_currentUserId != null) getTeams(_currentUserId!);
    });
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure() => failure.message,
      OfflineFailure() => AppStrings.checkInternetConnection,
      _ => AppStrings.unexpectedError,
    };
  }

  @override
  Future<void> close() {
    _teamsSubscription?.cancel();
    return super.close();
  }
}
