import 'package:equatable/equatable.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { todo, inProgress, review, done }

class TaskCommentEntity extends Equatable {
  final String id;
  final String authorId;
  final String text;
  final DateTime createdAt;

  const TaskCommentEntity({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, authorId, text, createdAt];
}

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String teamId;
  final String teamName;
  final List<String> assigneeIds;
  final String creatorId;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? startDate;
  final DateTime? dueDate;
  final bool isRecurring;
  final bool isDraft;
  final List<TaskCommentEntity> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.teamId,
    required this.teamName,
    required this.assigneeIds,
    required this.creatorId,
    required this.priority,
    required this.status,
    this.startDate,
    this.dueDate,
    this.isRecurring = false,
    this.isDraft = false,
    this.comments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    teamId,
    teamName,
    assigneeIds,
    creatorId,
    priority,
    status,
    startDate,
    dueDate,
    isRecurring,
    isDraft,
    comments,
    createdAt,
    updatedAt,
  ];
}
