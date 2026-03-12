import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.teamsCount,
    required super.completedCount,
    required super.activeCount,
    required super.phone,
    required super.jobTitle,
    required super.department,
    required super.location,
    required super.bio,
    required super.skills,
    super.photoUrl,
    required super.createdAt,
    required super.isDarkMode,
    required super.notificationsEnabled,
    required super.isVisibleToTeam,
    required super.shareContactInfo,
  });

  factory ProfileModel.fromSnapshot(DocumentSnapshot doc) {
    return ProfileModel.fromSnapshotWithCounts(
      doc: doc,
      teamsCount: 0,
      completedCount: 0,
      activeCount: 0,
    );
  }

  factory ProfileModel.fromSnapshotWithCounts({
    required DocumentSnapshot doc,
    required int teamsCount,
    required int completedCount,
    required int activeCount,
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProfileModel(
      uid: doc.id,
      fullName: data['name'] ?? '',
      email: data['email'] ?? '',
      teamsCount: teamsCount,
      completedCount: completedCount,
      activeCount: activeCount,
      phone: data['phone'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      department: data['department'] ?? '',
      location: data['location'] ?? '',
      bio: data['bio'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isDarkMode: data['isDarkMode'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      isVisibleToTeam: data['isVisibleToTeam'] ?? true,
      shareContactInfo: data['shareContactInfo'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': fullName,
      'email': email,
      'teamsCount': teamsCount,
      'completedCount': completedCount,
      'activeCount': activeCount,
      'phone': phone,
      'jobTitle': jobTitle,
      'department': department,
      'location': location,
      'bio': bio,
      'skills': skills,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'isVisibleToTeam': isVisibleToTeam,
      'shareContactInfo': shareContactInfo,
    };
  }
}
