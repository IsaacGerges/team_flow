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
    // Firebase Auth handles network errors internally with better accuracy
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user); // Success
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message)); // Failure
    } catch (e) {
      return Left(ServerFailure('Network error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String name,
  ) async {
    // Firebase Auth handles network errors internally
    try {
      final user = await remoteDataSource.register(email, password, name);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Network error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    // Firebase and Google Sign-In handle network errors internally
    // No need for explicit network check that can give false negatives
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      // Catch any network-related errors
      return Left(ServerFailure('Network error: ${e.toString()}'));
    }
  }
}
