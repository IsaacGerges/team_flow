import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';

import '../entities/team_entity.dart';

class GetTeamsUseCase {
  final TeamsRepository repository;

  GetTeamsUseCase(this.repository);

  // لاحظ إن هنا مفيش Either<Failure>.. الداتا يا بتيجي يا بترمى Error في الـ Stream
  Stream<List<TeamEntity>> call(String userId) {
    return repository.getMyTeams(userId);
  }
}
