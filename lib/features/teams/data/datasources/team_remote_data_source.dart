import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/team_model.dart';

abstract class TeamsRemoteDataSource {
  Future<void> createTeam(TeamModel teamModel);
  Future<void> updateTeam(String teamId, String newName);
  Future<void> deleteTeam(String teamId);
  Stream<List<TeamModel>> getTeams(String userId);
}

class TeamsRemoteDataSourceImpl implements TeamsRemoteDataSource {
  final FirebaseFirestore firestore;

  TeamsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createTeam(TeamModel teamModel) async {
    try {
      final teamCollection = firestore.collection('teams');
      await teamCollection.add(teamModel.toJson());
    } catch (e) {
      throw ServerException(message: "Failed to create team");
    }
  }

  @override
  Future<void> updateTeam(String teamId, String newName) async {
    try {
      await firestore.collection('teams').doc(teamId).update({'name': newName});
    } catch (e) {
      throw ServerException(message: "Failed to update team");
    }
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    try {
      await firestore.collection('teams').doc(teamId).delete();
    } catch (e) {
      throw ServerException(message: "Failed to delete team");
    }
  }

  @override
  Stream<List<TeamModel>> getTeams(String userId) {
    return firestore
        .collection('teams')
        .where('membersIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TeamModel.fromSnapshot(doc))
              .toList();
        });
  }
}
