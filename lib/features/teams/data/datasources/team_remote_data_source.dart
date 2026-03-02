import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/team_model.dart';

/// Handles all Firestore operations for the teams feature.
abstract class TeamsRemoteDataSource {
  Future<void> createTeam(TeamModel teamModel);
  Future<void> updateTeam(String teamId, TeamModel teamModel);
  Future<void> deleteTeam(String teamId);
  Stream<List<TeamModel>> getTeams(String userId);
  Future<void> addMember(String teamId, String userId);
  Future<void> removeMember(String teamId, String userId);
}

class TeamsRemoteDataSourceImpl implements TeamsRemoteDataSource {
  final FirebaseFirestore firestore;

  TeamsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createTeam(TeamModel teamModel) async {
    try {
      await firestore.collection('teams').add(teamModel.toJson());
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
}
