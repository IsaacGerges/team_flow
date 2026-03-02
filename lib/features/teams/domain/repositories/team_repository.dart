import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import '../../../../core/error/failures.dart';

/// Abstract contract for all team operations.
abstract class TeamsRepository {
  Future<Either<Failure, Unit>> createTeam(TeamEntity team);
  Future<Either<Failure, Unit>> updateTeam(String teamId, TeamEntity team);
  Future<Either<Failure, Unit>> deleteTeam(String teamId);
  Future<Either<Failure, Unit>> addMember(String teamId, String userId);
  Future<Either<Failure, Unit>> removeMember(String teamId, String userId);
  Stream<List<TeamEntity>> getMyTeams(String userId);
}
