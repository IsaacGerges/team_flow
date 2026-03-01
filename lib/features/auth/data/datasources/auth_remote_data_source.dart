import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_flow/core/error/exceptions.dart';
import 'package:team_flow/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<UserModel> signInWithGoogle();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firestore,
  });

  Future<void> _createUserInFirestore(User user) async {
    final userRef = firestore.collection('users').doc(user.uid);
    final docSnapshot = await userRef.get();

    if (!docSnapshot.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? 'No Name',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

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

      // 4. Create User in Firestore collection
      await _createUserInFirestore(updatedUser);

      // 5. Return UserModel
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

      // 5. Sync user in Firestore
      await _createUserInFirestore(userCredential.user!);

      // 6. Return UserModel
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? "Google Sign In Failed");
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      throw ServerException(message: "Logout failed");
    }
  }
}
