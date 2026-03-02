import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String uid);
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
