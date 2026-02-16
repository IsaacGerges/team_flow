import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
  });

  // بنحول الـ Firebase User لـ UserModel بتاعنا
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'No Name',
    );
  }
}
