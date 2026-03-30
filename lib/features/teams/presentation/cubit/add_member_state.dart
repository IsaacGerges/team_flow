import 'package:equatable/equatable.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';

/// Base state class for the Add Member feature.
abstract class AddMemberState extends Equatable {
  const AddMemberState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the Add Member flow starts.
class AddMemberInitial extends AddMemberState {}

/// State indicating that user data is being fetched or filtered.
class AddMemberLoading extends AddMemberState {}

/// State representing a successfully loaded list of users.
///
/// Contains [filteredUsers] to display and [isShowingCoworkers] to
/// determine if the current view is the "Suggested" or "Search results" view.
class AddMemberLoaded extends AddMemberState {
  final List<ProfileEntity> filteredUsers;
  final bool isShowingCoworkers;

  const AddMemberLoaded({
    required this.filteredUsers,
    required this.isShowingCoworkers,
  });

  @override
  List<Object?> get props => [filteredUsers, isShowingCoworkers];
}

/// State representing an error occurred during the Add Member flow.
class AddMemberError extends AddMemberState {
  final String message;

  const AddMemberError(this.message);

  @override
  List<Object?> get props => [message];
}
