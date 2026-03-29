import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../models/team_model.dart';

/// Handles all Firestore operations for the teams feature.
abstract class TeamsRemoteDataSource {
  Future<String> createTeam(TeamModel teamModel);
  Future<void> updateTeam(String teamId, TeamModel teamModel);
  Future<void> deleteTeam(String teamId);
  Stream<List<TeamModel>> getTeams(String userId);
  Future<void> addMember(String teamId, String userId);
  Future<void> removeMember(String teamId, String userId);
  Future<String> uploadTeamLogo(String teamId, Uint8List bytes);
  Future<void> updateTeamPhoto(String teamId, String photoUrl);
}

class TeamsRemoteDataSourceImpl implements TeamsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  TeamsRemoteDataSourceImpl({required this.firestore, required this.storage});

  @override
  Future<String> createTeam(TeamModel teamModel) async {
    try {
      return await firestore.runTransaction((transaction) async {
        // If an ID is provided, check if it already exists to avoid duplicates
        final docRef = teamModel.id.isNotEmpty
            ? firestore.collection('teams').doc(teamModel.id)
            : firestore.collection('teams').doc();

        final snapshot = await transaction.get(docRef);

        if (snapshot.exists) {
          // If the document already exists, return the same ID
          return docRef.id;
        }

        // If it doesn't exist, create it
        final modelWithId = TeamModel(
          id: docRef.id,
          name: teamModel.name,
          description: teamModel.description,
          adminId: teamModel.adminId,
          membersIds: teamModel.membersIds,
          photoUrl: null,
          category: teamModel.category,
          isPrivate: teamModel.isPrivate,
          progressPercent: teamModel.progressPercent,
        );

        transaction.set(docRef, modelWithId.toJson());
        return docRef.id;
      });
    } catch (e) {
      throw ServerException(message: 'Failed to create team');
    }
  }

  @override
  Future<void> updateTeam(String teamId, TeamModel teamModel) async {
    try {
      await firestore
          .collection('teams')
          .doc(teamId)
          .update(teamModel.toUpdateJson());
    } catch (e) {
      throw ServerException(message: 'Failed to update team');
    }
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    try {
      await firestore.collection('teams').doc(teamId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete team');
    }
  }

  @override
  Stream<List<TeamModel>> getTeams(String userId) {
    return firestore
        .collection('teams')
        .where('membersIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TeamModel.fromSnapshot(doc)).toList(),
        );
  }

  @override
  Future<void> addMember(String teamId, String userId) async {
    try {
      await firestore.collection('teams').doc(teamId).update({
        'membersIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to add member');
    }
  }

  @override
  Future<void> removeMember(String teamId, String userId) async {
    try {
      await firestore.collection('teams').doc(teamId).update({
        'membersIds': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to remove member');
    }
  }

  @override
  Future<String> uploadTeamLogo(String teamId, Uint8List bytes) async {
    try {
      final ref = storage.ref().child('teams/$teamId/logo.jpg');
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return ref.getDownloadURL();
    } catch (e) {
      throw ServerException(message: 'Failed to upload team logo');
    }
  }

  @override
  Future<void> updateTeamPhoto(String teamId, String photoUrl) async {
    try {
      await firestore.collection('teams').doc(teamId).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to update team photo');
    }
  }
}
