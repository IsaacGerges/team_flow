import 'package:team_flow/core/helpers/cache_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

/// Manages authentication state for the auth feature.
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final LogoutUseCase logoutUseCase;
  final CacheHelper cacheHelper;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.googleSignInUseCase,
    required this.logoutUseCase,
    required this.cacheHelper,
  }) : super(const AuthInitial());

  /// Signs in a user with email and password.
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    final result = await loginUseCase(email, password);
    result.fold((failure) => emit(AuthFailure(_mapFailureToMessage(failure))), (
      user,
    ) async {
      await cacheHelper.saveData(key: CacheKeys.userId, value: user.uid);
      emit(AuthSuccess(user));
    });
  }

  /// Registers a new user with email, password and display name.
  Future<void> register(String email, String password, String name) async {
    emit(const AuthLoading());
    final result = await registerUseCase(email, password, name);
    result.fold((failure) => emit(AuthFailure(_mapFailureToMessage(failure))), (
      user,
    ) async {
      await cacheHelper.saveData(key: CacheKeys.userId, value: user.uid);
      emit(AuthSuccess(user));
    });
  }

  /// Signs in a user using Google OAuth.
  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    final result = await googleSignInUseCase();
    result.fold((failure) => emit(AuthFailure(_mapFailureToMessage(failure))), (
      user,
    ) async {
      await cacheHelper.saveData(key: CacheKeys.userId, value: user.uid);
      emit(AuthSuccess(user));
    });
  }

  /// Logs out the user.
  Future<void> logout() async {
    emit(const AuthLoading());
    final result = await logoutUseCase();
    result.fold((failure) => emit(AuthFailure(_mapFailureToMessage(failure))), (
      _,
    ) async {
      await cacheHelper.removeData(key: CacheKeys.userId);
      emit(const AuthInitial());
    });
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure() => failure.message,
      OfflineFailure() => AppStrings.checkInternetConnection,
      _ => AppStrings.unexpectedError,
    };
  }
}
