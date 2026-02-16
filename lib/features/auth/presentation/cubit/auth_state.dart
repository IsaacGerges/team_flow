import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// 1. الحالة المبدئية (أول ما التطبيق يفتح)
class AuthInitial extends AuthState {}

// 2. حالة التحميل (لما يدوس Login والسبينر يلف)
class AuthLoading extends AuthState {}

// 3. حالة النجاح (لما الـ Login يخلص ويرجع يوزر)
class AuthSuccess extends AuthState {
  final UserEntity user; // شايلين اليوزر معانا عشان لو احتاجناه
  const AuthSuccess(this.user);

  @override
  List<Object> get props => [user];
}

// 4. حالة الفشل (لو الباسورد غلط أو مفيش نت)
class AuthFailure extends AuthState {
  final String message; // رسالة الخطأ اللي هتظهر لليوزر
  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}
