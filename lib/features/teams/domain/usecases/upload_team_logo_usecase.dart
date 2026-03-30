import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import '../../../../core/error/failures.dart';

class UploadTeamLogoUseCase {
  final TeamsRepository repository;

  UploadTeamLogoUseCase(this.repository);

  Future<Either<Failure, String>> call(String teamId, Uint8List bytes) {
    return repository.uploadTeamLogo(teamId, bytes);
  }
}
