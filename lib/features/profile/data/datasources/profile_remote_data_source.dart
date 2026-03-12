import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';
import 'package:rxdart/rxdart.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String uid);
  Stream<ProfileModel> getProfileStream(String uid);
  Future<void> updateProfile(ProfileModel profile);
  Future<List<ProfileModel>> getAllUsers();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSourceImpl({required this.firestore});

  @override
  Future<ProfileModel> getProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw ServerException(message: 'User profile not found');
      }
      return ProfileModel.fromSnapshot(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch profile: ${e.toString()}',
      );
    }
  }

  @override
  Stream<ProfileModel> getProfileStream(String uid) {
    // Stream 1 — user profile document (real-time)
    final profileStream = firestore
        .collection('users')
        .doc(uid)
        .snapshots();

    // Stream 2 — teams where user is a member (real-time)
    final teamsStream = firestore
        .collection('teams')
        .where('membersIds', arrayContains: uid)
        .snapshots();

    // Stream 3 — tasks assigned to the user (real-time)
    final tasksStream = firestore
        .collection('tasks')
        .where('assigneeIds', arrayContains: uid)
        .snapshots();

    // Combine all three — re-emits whenever ANY stream fires
    return Rx.combineLatest3(
      profileStream,
      teamsStream,
      tasksStream,
      (
        DocumentSnapshot profileSnap,
        QuerySnapshot teamsSnap,
        QuerySnapshot tasksSnap,
      ) {
        if (!profileSnap.exists) {
          // Fallback if profile doc is missing (rare after login)
          return ProfileModel.fromSnapshot(profileSnap);
        }

        final teamsCount = teamsSnap.docs.length;

        final completedCount = tasksSnap.docs
            .where((d) => d['status'] == 'done')
            .length;

        final activeCount = tasksSnap.docs
            .where(
              (d) =>
                  d['status'] != 'done' &&
                  (d['isDraft'] as bool? ?? false) == false,
            )
            .length;

        return ProfileModel.fromSnapshotWithCounts(
          doc: profileSnap,
          teamsCount: teamsCount,
          completedCount: completedCount,
          activeCount: activeCount,
        );
      },
    );
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await firestore
          .collection('users')
          .doc(profile.uid)
          .update(profile.toJson());
    } catch (e) {
      throw ServerException(
        message: 'Failed to update profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ProfileModel>> getAllUsers() async {
    try {
      final snapshot = await firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => ProfileModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch users: ${e.toString()}');
    }
  }
}
