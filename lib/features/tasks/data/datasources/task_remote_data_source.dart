import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TasksRemoteDataSource {
  Future<String> createTask(TaskModel taskModel);
  Future<void> updateTask(String taskId, TaskModel taskModel);
  Future<void> deleteTask(String taskId);
  Stream<List<TaskModel>> getTasksForUser(String userId);
  Stream<List<TaskModel>> getTasksForTeam(String teamId);
  Stream<List<TaskModel>> getTasksForTeams(List<String> teamIds);
  Future<void> addComment(String taskId, TaskCommentModel comment);
  Stream<List<TaskCommentModel>> getComments(String taskId);
}

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  final FirebaseFirestore firestore;

  TasksRemoteDataSourceImpl({required this.firestore});

  @override
  Future<String> createTask(TaskModel taskModel) async {
    try {
      final docRef = await firestore
          .collection('tasks')
          .add(taskModel.toJson());
      return docRef.id;
    } catch (e) {
      throw ServerException(message: 'Failed to create task');
    }
  }

  @override
  Future<void> updateTask(String taskId, TaskModel taskModel) async {
    try {
      await firestore
          .collection('tasks')
          .doc(taskId)
          .update(taskModel.toUpdateJson());
    } catch (e) {
      throw ServerException(message: 'Failed to update task');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete task');
    }
  }

  @override
  Stream<List<TaskModel>> getTasksForUser(String userId) {
    return firestore
        .collection('tasks')
        .where('assigneeIds', arrayContains: userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromSnapshot(doc)).toList(),
        );
  }

  @override
  Stream<List<TaskModel>> getTasksForTeam(String teamId) {
    return firestore
        .collection('tasks')
        .where('teamId', isEqualTo: teamId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromSnapshot(doc)).toList(),
        );
  }

  @override
  Stream<List<TaskModel>> getTasksForTeams(List<String> teamIds) {
    if (teamIds.isEmpty) return Stream.value([]);

    // Note: Firestore 'whereIn' supports up to 30 items.
    // For typical usage, a user won't easily exceed 30 teams.
    return firestore
        .collection('tasks')
        .where('teamId', whereIn: teamIds)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromSnapshot(doc)).toList(),
        );
  }

  @override
  Future<void> addComment(String taskId, TaskCommentModel comment) async {
    try {
      await firestore
          .collection('tasks')
          .doc(taskId)
          .collection('comments')
          .add(comment.toJson());
    } catch (e) {
      throw ServerException(message: 'Failed to add comment');
    }
  }

  @override
  Stream<List<TaskCommentModel>> getComments(String taskId) {
    return firestore
        .collection('tasks')
        .doc(taskId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskCommentModel.fromSnapshot(doc))
              .toList(),
        );
  }
}
