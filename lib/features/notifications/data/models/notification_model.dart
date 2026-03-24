import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.body,
    super.targetId,
    super.targetName,
    super.senderName,
    super.senderPhotoUrl,
    super.teamInitials,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: _parseType(data['type'] as String?),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      targetId: data['targetId'] as String?,
      targetName: data['targetName'] as String?,
      senderName: data['senderName'] as String?,
      senderPhotoUrl: data['senderPhotoUrl'] as String?,
      teamInitials: data['teamInitials'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'targetId': targetId,
      'targetName': targetName,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'teamInitials': teamInitials,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  NotificationModel copyWith({
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
    return NotificationModel(
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

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'mention':
        return NotificationType.mention;
      case 'taskAlert':
        return NotificationType.taskAlert;
      case 'teamActivity':
        return NotificationType.teamActivity;
      case 'assignment':
        return NotificationType.assignment;
      case 'meetingInvite':
        return NotificationType.meetingInvite;
      case 'systemUpdate':
        return NotificationType.systemUpdate;
      default:
        return NotificationType.systemUpdate;
    }
  }
}
