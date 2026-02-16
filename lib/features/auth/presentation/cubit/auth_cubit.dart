import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

// ركز في النصايح دي عشان تبقى محترف 👇
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleSignInUseCase googleSignInUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.googleSignInUseCase,
  }) : super(AuthInitial());

  // دالة تسجيل الدخول
  Future<void> login(String email, String password) async {
    // 1. بنغير الحالة لـ Loading عشان الـ UI يظهر Loading Spinner
    emit(AuthLoading());

    // 2. بننادي الـ UseCase
    final failureOrUser = await loginUseCase(email, password);

    // 3. بنشوف النتيجة (Either) ونغير الحالة بناءً عليها
    failureOrUser.fold(
      (failure) => emit(AuthFailure(_mapFailureToMessage(failure))), // لو فشل
      (user) => emit(AuthSuccess(user)), // لو نجح
    );
  }

  // دالة إنشاء حساب جديد
  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    final failureOrUser = await registerUseCase(email, password, name);

    failureOrUser.fold(
      (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
      (user) => emit(AuthSuccess(user)),
    );
  }

  // دالة تسجيل الدخول بـ Google
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final failureOrUser = await googleSignInUseCase();

    failureOrUser.fold(
      (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
      (user) => emit(AuthSuccess(user)),
    );
  }

  // Helper Function عشان تحول أنواع الفشل لرسايل يفهمها اليوزر
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case OfflineFailure:
        return 'Please check your internet connection';
      default:
        return 'Unexpected Error, Please try again later ._.';
    }
  }
}
