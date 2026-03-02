import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import '../../../../core/error/failures.dart';

/// Adds a user to a team's member list.
class AddMemberUseCase {
  final TeamsRepository repository;

  AddMemberUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String teamId, String userId) {
    return repository.addMember(teamId, userId);
  }
}
