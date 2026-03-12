import 'package:dartz/dartz.dart';
import 'package:team_flow/core/network/network_info.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String uid) async {
    try {
      final profile = await remoteDataSource.getProfile(uid);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Network error: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, ProfileEntity>> getProfileStream(String uid) async* {
    try {
      await for (final profile in remoteDataSource.getProfileStream(uid)) {
        yield Right(profile);
      }
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(ProfileEntity profile) async {
    try {
      final profileModel = ProfileModel(
        uid: profile.uid,
        fullName: profile.fullName,
        email: profile.email,
        createdAt: profile.createdAt,
        teamsCount: profile.teamsCount,
        completedCount: profile.completedCount,
        activeCount: profile.activeCount,
        phone: profile.phone,
        jobTitle: profile.jobTitle,
        department: profile.department,
        location: profile.location,
        photoUrl: profile.photoUrl,
        bio: profile.bio,
        skills: profile.skills,
        isDarkMode: profile.isDarkMode,
        notificationsEnabled: profile.notificationsEnabled,
        isVisibleToTeam: profile.isVisibleToTeam,
        shareContactInfo: profile.shareContactInfo,
      );
      await remoteDataSource.updateProfile(profileModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Network error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProfileEntity>>> getAllUsers() async {
    try {
      final profiles = await remoteDataSource.getAllUsers();
      return Right(profiles);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Network error: ${e.toString()}'));
    }
  }
}
