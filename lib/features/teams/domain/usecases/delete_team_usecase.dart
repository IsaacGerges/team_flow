import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import '../../../../core/error/failures.dart';

class DeleteTeamUseCase {
  final TeamsRepository repository;

  DeleteTeamUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String teamId) async {
    return await repository.deleteTeam(teamId);
  }
}
