import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import '../../../../core/error/failures.dart';

class UpdateTeamPhotoUseCase {
  final TeamsRepository repository;

  UpdateTeamPhotoUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String teamId, String photoUrl) {
    return repository.updateTeamPhoto(teamId, photoUrl);
  }
}
