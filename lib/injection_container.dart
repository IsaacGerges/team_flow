import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:team_flow/core/usecases/get_current_user_id_usecase.dart';
import 'package:team_flow/features/onboarding/domain/usecases/save_onboarding_status_usecase.dart';
import 'package:team_flow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:team_flow/core/network/network_info.dart';
import 'package:team_flow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:team_flow/features/teams/data/datasources/team_remote_data_source.dart';
import 'package:team_flow/features/teams/data/repositories/team_repository_impl.dart';
import 'package:team_flow/features/teams/domain/repositories/team_repository.dart';
import 'package:team_flow/features/teams/domain/usecases/add_member_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/create_team_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/delete_team_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/update_team_photo_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/upload_team_logo_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/update_team_usecase.dart';
import 'package:team_flow/features/teams/domain/usecases/get_coworker_ids_usecase.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/add_member_cubit.dart';
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
import 'features/tasks/data/datasources/task_remote_data_source.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/domain/usecases/add_comment_usecase.dart';
import 'features/tasks/domain/usecases/create_task_usecase.dart';
import 'features/tasks/domain/usecases/delete_task_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_for_team_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_for_teams_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_for_user_usecase.dart';
import 'features/tasks/domain/usecases/update_task_usecase.dart';
import 'features/tasks/presentation/cubit/task_cubit.dart';
import 'features/notifications/data/datasources/notification_remote_data_source.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'features/notifications/domain/usecases/create_notification_usecase.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_flow/core/helpers/cache_helper.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // === Core ===
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => CacheHelper(sharedPreferences: sl()));
  sl.registerLazySingleton(() => const GetCurrentUserIdUseCase());

  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // === Onboarding Feature ===
  sl.registerLazySingleton(() => SaveOnboardingStatusUseCase(sl()));
  sl.registerFactory(() => OnboardingCubit(saveOnboardingStatusUseCase: sl()));

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
  sl.registerLazySingleton(() => UpdateTeamPhotoUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTeamUseCase(sl()));
  sl.registerLazySingleton(() => AddMemberUseCase(sl()));
  sl.registerLazySingleton(() => UploadTeamLogoUseCase(sl()));
  sl.registerLazySingleton(
    () => GetCoworkerIdsUseCase(teamsRepository: sl(), tasksRepository: sl()),
  );

  // Repository
  sl.registerLazySingleton<TeamsRepository>(
    () => TeamsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data Source
  sl.registerLazySingleton<TeamsRemoteDataSource>(
    () => TeamsRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );

  // Cubit
  sl.registerFactory(
    () => TeamsCubit(
      createTeamUseCase: sl(),
      getTeamsUseCase: sl(),
      updateTeamUseCase: sl(),
      updateTeamPhotoUseCase: sl(),
      deleteTeamUseCase: sl(),
      addMemberUseCase: sl(),
      uploadTeamLogoUseCase: sl(),
      getAllUsersUseCase: sl(),
      createNotificationUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AddMemberCubit(getAllUsersUseCase: sl(), getCoworkerIdsUseCase: sl()),
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
    () => ProfileCubit(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      getAllUsersUseCase: sl(),
    ),
  );

  // === Tasks Feature ===
  // Use Cases
  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksForUserUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksForTeamUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksForTeamsUseCase(sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));

  // Repository
  sl.registerLazySingleton<TasksRepository>(
    () => TasksRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data Source
  sl.registerLazySingleton<TasksRemoteDataSource>(
    () => TasksRemoteDataSourceImpl(firestore: sl()),
  );

  // Cubit
  sl.registerFactory(
    () => TasksCubit(
      createTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
      getTasksForUserUseCase: sl(),
      getTasksForTeamUseCase: sl(),
      getTasksForTeamsUseCase: sl(),
      addCommentUseCase: sl(),
      createNotificationUseCase: sl(),
    ),
  );

  // === Notifications Feature ===
  // Use Cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()));
  sl.registerLazySingleton(() => CreateNotificationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(firestore: sl()),
  );

  // Cubit
  sl.registerFactory(
    () => NotificationsCubit(
      getNotificationsUseCase: sl(),
      markNotificationReadUseCase: sl(),
      markAllNotificationsReadUseCase: sl(),
    ),
  );

  // === External ===
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
}
