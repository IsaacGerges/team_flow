import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    required super.adminId,
    required super.membersIds,
  });

  // تحويل لـ JSON عشان نبعته لـ Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'adminId': adminId,
      'membersIds': membersIds,
      'createdAt': FieldValue.serverTimestamp(), // بنسجل وقت الإنشاء
    };
  }

  // تحويل من Firestore لـ Model (هنحتاجها بعدين)
  factory TeamModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamModel(
      id: doc.id,
      name: data['name'] ?? '',
      adminId: data['adminId'] ?? '',
      membersIds: List<String>.from(data['membersIds'] ?? []),
    );
  }
}
