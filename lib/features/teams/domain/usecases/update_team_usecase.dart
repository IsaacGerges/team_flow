import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import '../../../../core/error/failures.dart';

/// Updates an existing team's data.
class UpdateTeamUseCase {
  final TeamsRepository repository;

  UpdateTeamUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String teamId, TeamEntity team) {
    return repository.updateTeam(teamId, team);
  }
}
