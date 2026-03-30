import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';
import 'package:team_flow/features/profile/domain/usecases/get_all_users_usecase.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/domain/usecases/get_coworker_ids_usecase.dart';
import 'add_member_state.dart';

/// Cubit responsible for managing the state of the Add Member page.
///
/// It handles fetching all system users, identifying coworkers based on
/// existing teams and tasks, and filtering them based on search queries.
class AddMemberCubit extends Cubit<AddMemberState> {
  final GetAllUsersUseCase getAllUsersUseCase;
  final GetCoworkerIdsUseCase getCoworkerIdsUseCase;

  List<ProfileEntity> _allUsers = [];
  Set<String> _coworkerIds = {};
  TeamEntity? _currentTeam;

  AddMemberCubit({
    required this.getAllUsersUseCase,
    required this.getCoworkerIdsUseCase,
  }) : super(AddMemberInitial());

  /// Initializes the Cubit by fetching users and coworkers.
  ///
  /// [currentUserId] is used to fetch the current user's coworkers.
  /// [team] is used to exclude existing members from the search results.
  Future<void> init(String currentUserId, TeamEntity team) async {
    _currentTeam = team;
    emit(AddMemberLoading());

    // Fetch both all users and the subset of coworkers concurrently
    final results = await Future.wait([
      getAllUsersUseCase(),
      getCoworkerIdsUseCase(currentUserId),
    ]);

    final usersResult = results[0] as dynamic;
    final coworkersResult = results[1] as dynamic;

    _allUsers = usersResult.fold((_) => <ProfileEntity>[], (users) => users);
    _coworkerIds = coworkersResult.fold((_) => <String>{}, (ids) => ids);

    // Initial state displays coworkers by default
    _emitFilteredList('');
  }

  /// Filters the user list based on the provided [query].
  ///
  /// If the query is empty, it displays "Suggested People" (coworkers).
  /// Otherwise, it performs a global search across all system users.
  void search(String query) {
    if (_currentTeam == null) return;
    _emitFilteredList(query);
  }

  /// Applies the filtering logic and emits the [AddMemberLoaded] state.
  void _emitFilteredList(String query) {
    final isShowingCoworkers = query.trim().isEmpty;

    final filtered = _allUsers.where((user) {
      // Exclude users who are already in the target team
      if (_currentTeam!.membersIds.contains(user.uid)) return false;

      if (isShowingCoworkers) {
        // Suggested view: only show people the user has worked with
        return _coworkerIds.contains(user.uid);
      } else {
        // Search view: global search by name or email
        final normalizedQuery = query.toLowerCase();
        return user.fullName.toLowerCase().contains(normalizedQuery) ||
            user.email.toLowerCase().contains(normalizedQuery);
      }
    }).toList();

    emit(
      AddMemberLoaded(
        filteredUsers: filtered,
        isShowingCoworkers: isShowingCoworkers,
      ),
    );
  }
}
