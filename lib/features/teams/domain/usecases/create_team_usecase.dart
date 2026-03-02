import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import '../../../../core/error/failures.dart';

/// Creates a new team owned by the given admin.
class CreateTeamUseCase {
  final TeamsRepository repository;

  CreateTeamUseCase(this.repository);

  Future<Either<Failure, Unit>> call(TeamEntity team) {
    return repository.createTeam(team);
  }
}
