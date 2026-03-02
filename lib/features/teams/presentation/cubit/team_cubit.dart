import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';
import 'package:team_flow/features/profile/domain/usecases/get_all_users_usecase.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/domain/usecases/add_member_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/create_team_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/delete_team_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/update_team_usecase.dart';
import 'package:team_flow/core/error/failures.dart';
import 'team_state.dart';

/// Manages the state for the entire Teams feature.
///
/// Uses a Firestore stream (`getTeams`) as the single source of truth.
/// After every mutation (create / update / delete / addMember) the cubit
/// re-subscribes to the stream so the UI always shows fresh data.
class TeamsCubit extends Cubit<TeamsState> {
  final CreateTeamUseCase createTeamUseCase;
  final GetTeamsUseCase getTeamsUseCase;
  final UpdateTeamUseCase updateTeamUseCase;
  final DeleteTeamUseCase deleteTeamUseCase;
  final AddMemberUseCase addMemberUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;

  StreamSubscription<List<TeamEntity>>? _teamsSubscription;
  String? _currentUserId;

  TeamsCubit({
    required this.createTeamUseCase,
    required this.getTeamsUseCase,
    required this.updateTeamUseCase,
    required this.deleteTeamUseCase,
    required this.addMemberUseCase,
    required this.getAllUsersUseCase,
  }) : super(const TeamsInitial());

  // ----------------------------------------------------------
  // Stream
  // ----------------------------------------------------------

  /// Subscribes to the Firestore teams stream for [userId].
  void getTeams(String userId) {
    _currentUserId = userId;
    emit(const TeamsLoading());
    _teamsSubscription?.cancel();
    _teamsSubscription = getTeamsUseCase(userId).listen(
      (teams) => emit(TeamsLoaded(teams)),
      onError: (error) => emit(TeamsError(error.toString())),
    );
  }

  /// Re-subscribes to the stream using the stored userId.
  void _refreshTeams() {
    if (_currentUserId != null) {
      getTeams(_currentUserId!);
    }
  }

  // ----------------------------------------------------------
  // Mutations
  // ----------------------------------------------------------

  Future<void> createTeam(TeamEntity team) async {
    emit(const TeamsLoading());
    final result = await createTeamUseCase(team);
    result.fold((failure) => emit(TeamsError(_mapFailureToMessage(failure))), (
      _,
    ) {
      emit(const TeamCreatedSuccess());
      _refreshTeams();
    });
  }

  Future<void> updateTeam(String teamId, TeamEntity team) async {
    emit(const TeamsLoading());
    final result = await updateTeamUseCase(teamId, team);
    result.fold((failure) => emit(TeamsError(_mapFailureToMessage(failure))), (
      _,
    ) {
      emit(const TeamUpdatedSuccess());
      _refreshTeams();
    });
  }

  Future<void> deleteTeam(String teamId) async {
    emit(const TeamsLoading());
    final result = await deleteTeamUseCase(teamId);
    result.fold((failure) => emit(TeamsError(_mapFailureToMessage(failure))), (
      _,
    ) {
      emit(const TeamDeletedSuccess());
      _refreshTeams();
    });
  }

  /// Adds a single member and refreshes the stream.
  Future<void> addMember(String teamId, String userId) async {
    emit(const TeamsLoading());
    final result = await addMemberUseCase(teamId, userId);
    result.fold((failure) => emit(TeamsError(_mapFailureToMessage(failure))), (
      _,
    ) {
      emit(const TeamMemberAddedSuccess());
      _refreshTeams();
    });
  }

  /// Adds multiple members sequentially, then refreshes once.
  Future<void> addMembers(String teamId, List<String> userIds) async {
    emit(const TeamsLoading());
    for (final uid in userIds) {
      final result = await addMemberUseCase(teamId, uid);
      final failed = result.fold<bool>((failure) {
        emit(TeamsError(_mapFailureToMessage(failure)));
        return true;
      }, (_) => false);
      if (failed) return;
    }
    emit(const TeamMemberAddedSuccess());
    _refreshTeams();
  }

  /// Picks a photo from gallery, compresses it, and emits as base64.
  Future<void> pickTeamLogo() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 30,
        maxWidth: 300,
        maxHeight: 300,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        emit(TeamLogoPicked(base64String));
      }
    } catch (e) {
      emit(TeamsError('Failed to pick logo: ${e.toString()}'));
    }
  }

  // ----------------------------------------------------------
  // Queries
  // ----------------------------------------------------------

  /// Returns all users from Firestore (for the member search screen).
  Future<List<ProfileEntity>> getAllUsers() async {
    final result = await getAllUsersUseCase();
    return result.fold((failure) => [], (users) => users);
  }

  // ----------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is OfflineFailure) {
      return 'Please check your internet connection';
    }
    return 'Unexpected error occurred';
  }

  @override
  Future<void> close() {
    _teamsSubscription?.cancel();
    return super.close();
  }
}
