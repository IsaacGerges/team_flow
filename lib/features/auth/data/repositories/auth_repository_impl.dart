import 'package:dartz/dartz.dart';
import 'package:team_flow/core/network/network_info.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(OfflineFailure());
    }
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user); // Success
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message)); // Failure
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String name,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(OfflineFailure());
    }
    try {
      final user = await remoteDataSource.register(email, password, name);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (!await networkInfo.isConnected) {
      return Left(OfflineFailure());
    }
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
