import 'package:equatable/equatable.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';

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

/// Emitted when a teams operation fails, carrying a user-facing message.
class TeamsError extends TeamsState {
  final String message;

  const TeamsError(this.message);

  @override
  List<Object> get props => [message];
}

/// Emitted when the teams list is loaded successfully.
class TeamsLoaded extends TeamsState {
  final List<TeamEntity> teams;

  const TeamsLoaded(this.teams);

  @override
  List<Object> get props => [teams];
}
