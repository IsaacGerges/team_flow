import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import '../../../../core/error/failures.dart';

class CreateTeamUseCase {
  final TeamsRepository repository;

  CreateTeamUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String teamName, String adminId) async {
    return await repository.createTeam(teamName, adminId);
  }
}
