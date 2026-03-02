import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:team_flow/core/network/network_info.dart';
import 'package:team_flow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:team_flow/features/teams/data/datasources/team_remote_data_source.dart';
import 'package:team_flow/features/teams/data/repositories/team_repository_impl.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import 'package:team_flow/features/teams/domain/usecases/add_member_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/create_team_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/delete_team_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/update_team_usecase.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_all_users_usecase.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_flow/core/helpers/cache_helper.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // === Core ===
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => CacheHelper(sharedPreferences: sl()));

  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // === Auth Feature ===
  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      firestore: sl(),
    ),
  );

  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      googleSignInUseCase: sl(),
      logoutUseCase: sl(),
      cacheHelper: sl(),
    ),
  );

  // === Teams Feature ===
  // Use Cases
  sl.registerLazySingleton(() => CreateTeamUseCase(sl()));
  sl.registerLazySingleton(() => GetTeamsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTeamUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTeamUseCase(sl()));
  sl.registerLazySingleton(() => AddMemberUseCase(sl()));

  // Repository
  sl.registerLazySingleton<TeamsRepository>(
    () => TeamsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data Source
  sl.registerLazySingleton<TeamsRemoteDataSource>(
    () => TeamsRemoteDataSourceImpl(firestore: sl()),
  );

  // Cubit
  sl.registerFactory(
    () => TeamsCubit(
      createTeamUseCase: sl(),
      getTeamsUseCase: sl(),
      updateTeamUseCase: sl(),
      deleteTeamUseCase: sl(),
      addMemberUseCase: sl(),
      getAllUsersUseCase: sl(),
    ),
  );

  // === Profile Feature ===
  // Use Cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data Source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl()),
  );

  // Cubit
  sl.registerFactory(
    () => ProfileCubit(getProfileUseCase: sl(), updateProfileUseCase: sl()),
  );

  // === External ===
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
}
