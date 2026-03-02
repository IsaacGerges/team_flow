import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/team_entity.dart';

/// Firestore data model for [TeamEntity].
class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    required super.adminId,
    required super.membersIds,
    super.description,
    super.photoUrl,
    super.category,
    super.isPrivate,
    super.progressPercent,
    super.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'adminId': adminId,
      'membersIds': membersIds,
      'photoUrl': photoUrl,
      'category': category,
      'isPrivate': isPrivate,
      'progressPercent': progressPercent,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Used for updates (does not overwrite createdAt).
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'category': category,
      'isPrivate': isPrivate,
      'progressPercent': progressPercent,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory TeamModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      adminId: data['adminId'] as String? ?? '',
      membersIds: List<String>.from(data['membersIds'] as List? ?? []),
      photoUrl: data['photoUrl'] as String?,
      category: data['category'] as String? ?? 'Other',
      isPrivate: data['isPrivate'] as bool? ?? false,
      progressPercent: (data['progressPercent'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
