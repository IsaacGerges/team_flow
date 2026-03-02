import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';

class TaskCommentModel extends TaskCommentEntity {
  const TaskCommentModel({
    required super.id,
    required super.authorId,
    required super.text,
    required super.createdAt,
  });

  factory TaskCommentModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskCommentModel(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.teamId,
    required super.teamName,
    required super.assigneeIds,
    required super.creatorId,
    required super.priority,
    required super.status,
    super.startDate,
    super.dueDate,
    super.isRecurring,
    super.isDraft,
    super.comments,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      teamId: data['teamId'] as String? ?? '',
      teamName: data['teamName'] as String? ?? '',
      assigneeIds: List<String>.from(data['assigneeIds'] as List? ?? []),
      creatorId: data['creatorId'] as String? ?? '',
      priority: _parsePriority(data['priority'] as String?),
      status: _parseStatus(data['status'] as String?),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      isRecurring: data['isRecurring'] as bool? ?? false,
      isDraft: data['isDraft'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Comments are usually fetched via subcollection stream,
      // but we include them here if passed in data.
      comments: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'teamId': teamId,
      'teamName': teamName,
      'assigneeIds': assigneeIds,
      'creatorId': creatorId,
      'priority': priority.name,
      'status': status.name,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isRecurring': isRecurring,
      'isDraft': isDraft,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    final map = {
      'title': title,
      'description': description,
      'assigneeIds': assigneeIds,
      'priority': priority.name,
      'status': status.name,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isRecurring': isRecurring,
      'isDraft': isDraft,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    return map;
  }

  static TaskPriority _parsePriority(String? priority) {
    switch (priority) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  static TaskStatus _parseStatus(String? status) {
    switch (status) {
      case 'todo':
        return TaskStatus.todo;
      case 'inProgress':
        return TaskStatus.inProgress;
      case 'review':
        return TaskStatus.review;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }
}
