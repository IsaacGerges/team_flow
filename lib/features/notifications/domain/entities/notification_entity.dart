import 'package:equatable/equatable.dart';

enum NotificationType {
  mention,
  taskAlert,
  teamActivity,
  assignment,
  meetingInvite,
  systemUpdate,
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId; // recipient
  final NotificationType type;
  final String title; // bold text ("Sarah Jenkins")
  final String body; // full message
  final String? targetId; // task/team/meeting id
  final String? targetName; // "Marketing Strategy"
  final String? senderName;
  final String? senderPhotoUrl;
  final String? teamInitials; // for team activity cards
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.targetId,
    this.targetName,
    this.senderName,
    this.senderPhotoUrl,
    this.teamInitials,
    required this.isRead,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? targetId,
    String? targetName,
    String? senderName,
    String? senderPhotoUrl,
    String? teamInitials,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      teamInitials: teamInitials ?? this.teamInitials,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    body,
    targetId,
    targetName,
    senderName,
    senderPhotoUrl,
    teamInitials,
    isRead,
    createdAt,
  ];
}
