import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetAllUsersUseCase {
  final ProfileRepository repository;

  GetAllUsersUseCase(this.repository);

  Future<Either<Failure, List<ProfileEntity>>> call() async {
    return await repository.getAllUsers();
  }
}
