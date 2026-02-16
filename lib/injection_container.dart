import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:team_flow/core/network/network_info.dart';
import 'package:team_flow/features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // 1. UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));

  // 2. Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(), // <-- ضفنا الحقن هنا
    ),
  );

  // 3. Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), googleSignIn: sl()),
  );

  // 1. Cubit (Factory مش Singleton!)
  // ليه Factory؟ عشان كل مرة نفتح صفحة الـ Auth ممكن نحتاج Cubit جديد بحالة جديدة (Initial)،
  // أو ممكن نسيبه Singleton لو عايز الحالة تثبت. بس في الـ ViewModels يفضل Factory.
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      googleSignInUseCase: sl(),
    ),
  );

  // ! Core (جديد)
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  final firebaseAuth = FirebaseAuth.instance;
  sl.registerLazySingleton(() => firebaseAuth);

  final googleSignIn = GoogleSignIn();
  sl.registerLazySingleton(() => googleSignIn);
}
