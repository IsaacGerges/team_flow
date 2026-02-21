import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import '../../../../core/error/failures.dart';

abstract class TeamsRepository {
  Future<Either<Failure, Unit>> createTeam(String teamName, String adminId);

  Future<Either<Failure, Unit>> updateTeam(String teamId, String newName);

  Future<Either<Failure, Unit>> deleteTeam(String teamId);

  Stream<List<TeamEntity>> getMyTeams(String userId);
}
