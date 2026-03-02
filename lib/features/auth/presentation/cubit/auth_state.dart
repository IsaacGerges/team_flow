import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Initial state before any auth action.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Emitted while an auth operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Emitted when auth succeeds, carrying the authenticated user.
class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object> get props => [user];
}

/// Emitted when auth fails, carrying a user-facing message.
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}
