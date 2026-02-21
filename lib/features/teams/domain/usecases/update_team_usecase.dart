import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import '../../../../core/error/failures.dart';

class UpdateTeamUseCase {
  final TeamsRepository repository;

  UpdateTeamUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String teamId, String newName) async {
    return await repository.updateTeam(teamId, newName);
  }
}
