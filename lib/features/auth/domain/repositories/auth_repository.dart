import 'package:dartz/dartz.dart';
import 'package:team_flow/core/error/failures.dart';
import 'package:team_flow/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);

  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String name,
  );

  Future<Either<Failure, UserEntity>> signInWithGoogle();
}
