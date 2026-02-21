import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/data/datasources/team_remote_data_source.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../models/team_model.dart';

class TeamsRepositoryImpl implements TeamsRepository {
  final TeamsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TeamsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Unit>> createTeam(
    String teamName,
    String adminId,
  ) async {
    try {
      final team = TeamModel(
        id: '',
        name: teamName,
        adminId: adminId,
        membersIds: [adminId],
      );
      await remoteDataSource.createTeam(team);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTeam(
    String teamId,
    String newName,
  ) async {
    try {
      await remoteDataSource.updateTeam(teamId, newName);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTeam(String teamId) async {
    try {
      await remoteDataSource.deleteTeam(teamId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<TeamEntity>> getMyTeams(String userId) {
    return remoteDataSource.getTeams(userId).map((teamModels) {
      return teamModels;
    });
  }
}
