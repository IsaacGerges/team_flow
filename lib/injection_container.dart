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

final sl = GetIt.instance;

Future<void> init() async {
  // === Core ===
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // === Auth Feature ===
  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), googleSignIn: sl()),
  );

  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      googleSignInUseCase: sl(),
    ),
  );

  // === Teams Feature ===
  // Use Cases
  sl.registerLazySingleton(() => CreateTeamUseCase(sl()));
  sl.registerLazySingleton(() => GetTeamsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTeamUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTeamUseCase(sl()));

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
    ),
  );

  // === External ===
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
}
