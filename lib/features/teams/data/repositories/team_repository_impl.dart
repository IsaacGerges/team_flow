import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/data/datasources/team_remote_data_source.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../models/team_model.dart';

/// Concrete implementation of [TeamsRepository].
class TeamsRepositoryImpl implements TeamsRepository {
  final TeamsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TeamsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> createTeam(TeamEntity team) async {
    try {
      final model = TeamModel(
        id: team.id,
        name: team.name,
        description: team.description,
        adminId: team.adminId,
        membersIds: [team.adminId],
        photoUrl: teamModel.photoUrl,
        category: team.category,
        isPrivate: team.isPrivate,
        progressPercent: team.progressPercent,
      );
      final teamId = await remoteDataSource.createTeam(model);
      return Right(teamId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTeam(
    String teamId,
    TeamEntity team,
  ) async {
    try {
      final model = TeamModel(
        id: teamId,
        name: team.name,
        description: team.description,
        adminId: team.adminId,
        membersIds: team.membersIds,
        photoUrl: team.photoUrl,
        category: team.category,
        isPrivate: team.isPrivate,
        progressPercent: team.progressPercent,
      );
      await remoteDataSource.updateTeam(teamId, model);
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
  Future<Either<Failure, Unit>> addMember(String teamId, String userId) async {
    try {
      await remoteDataSource.addMember(teamId, userId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeMember(
    String teamId,
    String userId,
  ) async {
    try {
      await remoteDataSource.removeMember(teamId, userId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> uploadTeamLogo(
    String teamId,
    Uint8List bytes,
  ) async {
    try {
      final photoUrl = await remoteDataSource.uploadTeamLogo(teamId, bytes);
      return Right(photoUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTeamPhoto(
    String teamId,
    String photoUrl,
  ) async {
    try {
      await remoteDataSource.updateTeamPhoto(teamId, photoUrl);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<TeamEntity>> getMyTeams(String userId) {
    return remoteDataSource.getTeams(userId);
  }
}
