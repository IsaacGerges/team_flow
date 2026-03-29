import 'package:equatable/equatable.dart';
import 'dart:typed_data';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';

/// Base state class for the Teams feature.
abstract class TeamsState extends Equatable {
  const TeamsState();

  @override
  List<Object> get props => [];
}

/// Initial state before any teams operation.
class TeamsInitial extends TeamsState {
  const TeamsInitial();
}

/// Emitted while a teams operation is in progress.
class TeamsLoading extends TeamsState {
  const TeamsLoading();
}

/// Emitted while a team creation is specifically in progress.
class TeamCreateSubmitting extends TeamsState {
  const TeamCreateSubmitting();
}

/// Emitted when the teams list is loaded successfully.
class TeamsLoaded extends TeamsState {
  final List<TeamEntity> teams;

  const TeamsLoaded(this.teams);

  @override
  List<Object> get props => [teams];
}

/// Emitted when a team is successfully created.
class TeamCreatedSuccess extends TeamsState {
  const TeamCreatedSuccess();
}

/// Emitted when a team is successfully updated.
class TeamUpdatedSuccess extends TeamsState {
  const TeamUpdatedSuccess();
}

/// Emitted when a team is successfully deleted.
class TeamDeletedSuccess extends TeamsState {
  const TeamDeletedSuccess();
}

/// Emitted when a member is successfully added to a team.
class TeamMemberAddedSuccess extends TeamsState {
  const TeamMemberAddedSuccess();
}

/// Emitted when a member is successfully removed from a team.
class TeamMemberRemovedSuccess extends TeamsState {
  const TeamMemberRemovedSuccess();
}

/// Emitted when a team logo is picked from gallery but not yet saved.
class TeamLogoPicked extends TeamsState {
  final Uint8List imageBytes;

  const TeamLogoPicked(this.imageBytes);

  @override
  List<Object> get props => [imageBytes];
}

/// Emitted when a teams operation fails.
class TeamsError extends TeamsState {
  final String message;

  const TeamsError(this.message);

  @override
  List<Object> get props => [message];
}
