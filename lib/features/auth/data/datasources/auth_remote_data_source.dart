import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_flow/core/error/exceptions.dart';
import 'package:team_flow/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);

  Future<UserModel> register(String email, String password, String name);
  Future<UserModel> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? "Unknown Error");
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    try {
      // 1. Create User in Firebase Auth
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Update Display Name (التاتش الزيادة 😉)
      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.reload(); // Refresh user data

      // 3. Get updated user
      final updatedUser = firebaseAuth.currentUser!;

      // 4. Return UserModel
      return UserModel.fromFirebaseUser(updatedUser);
    } on FirebaseAuthException catch (e) {
      // هنا بنهندل الأخطاء المشهورة زي: email-already-in-use
      if (e.code == 'weak-password') {
        throw ServerException(message: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw ServerException(
          message: 'The account already exists for that email.',
        );
      } else {
        throw ServerException(message: e.message ?? "Registration Failed");
      }
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // 1. Trigger the authentication flow (يطلع بوب اب يختار الايميل)
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // اليوزر قفل البوب اب ومختارش حاجة
        throw ServerException(message: "Google Sign In Cancelled");
      }

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the credential
      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      // 5. Return UserModel
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? "Google Sign In Failed");
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
