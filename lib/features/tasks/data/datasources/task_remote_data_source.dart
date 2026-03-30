import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TasksRemoteDataSource {
  Future<String> createTask(TaskModel taskModel);
  Future<void> updateTask(String taskId, TaskModel taskModel);
  Future<void> deleteTask(String taskId);
  Stream<List<TaskModel>> getTasksForUser(String userId);

  /// Returns a published-only stream of tasks for a single team.
  ///
  /// Draft filtering is done client-side so no composite Firestore index on
  /// (teamId, isDraft, updatedAt) is required.
  Stream<List<TaskModel>> getTasksForTeam(String teamId);

  /// Returns a viewer-aware stream of tasks across multiple teams.
  ///
  /// A single Firestore query fetches all tasks for [teamIds]; the
  /// visibility rule is applied in-memory:
  /// - Show all published tasks (isDraft == false).
  /// - Show drafts only when creatorId == viewerId.
  ///
  /// Using one query instead of two separate isDraft-filtered queries avoids
  /// the need for composite Firestore indexes on (teamId, isDraft, updatedAt)
  /// and guarantees that when a draft is published the stream updates in
  /// real-time without restart.
  Stream<List<TaskModel>> getTasksForTeams(
    List<String> teamIds, {
    required String viewerId,
  });

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

  /// Single-team published view. Draft filtering is client-side to avoid
  /// requiring a composite (teamId, isDraft, updatedAt) Firestore index.
  @override
  Stream<List<TaskModel>> getTasksForTeam(String teamId) {
    return firestore
        .collection('tasks')
        .where('teamId', isEqualTo: teamId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromSnapshot(doc))
              .where((t) => !t.isDraft)
              .toList(),
        );
  }

  /// Multi-team viewer-aware stream using a **single** Firestore query.
  ///
  /// Visibility rule applied in-memory:
  ///   `!task.isDraft || task.creatorId == viewerId`
  ///
  /// This is intentionally a single query (no `isDraft` Firestore filter) so
  /// that when a draft is published (isDraft flips to false) the document is
  /// still part of the same query result set and the real-time listener fires
  /// immediately — no composite index gap, no restart needed.
  @override
  Stream<List<TaskModel>> getTasksForTeams(
    List<String> teamIds, {
    required String viewerId,
  }) {
    if (teamIds.isEmpty) return Stream.value([]);

    return firestore
        .collection('tasks')
        .where('teamId', whereIn: teamIds)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromSnapshot(doc))
              .where((t) => !t.isDraft || t.creatorId == viewerId)
              .toList(),
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
