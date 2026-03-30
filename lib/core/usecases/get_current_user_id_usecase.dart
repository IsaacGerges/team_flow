import 'package:firebase_auth/firebase_auth.dart';

/// Returns the currently authenticated user's UID, or `null` if not signed in.
///
/// Encapsulates FirebaseAuth access so the presentation layer never imports
/// Firebase directly. Consumed by cubits / pages that need the viewer's ID.
class GetCurrentUserIdUseCase {
  const GetCurrentUserIdUseCase();

  /// Returns the UID of the signed-in user, or `null` when unauthenticated.
  String? call() => FirebaseAuth.instance.currentUser?.uid;
}
