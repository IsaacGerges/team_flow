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
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProfileModel(
      uid: doc.id,
      fullName: data['name'] ?? '',
      email: data['email'] ?? '',
      teamsCount: data['teamsCount'] ?? 0,
      completedCount: data['completedCount'] ?? 0,
      activeCount: data['activeCount'] ?? 0,
      phone: data['phone'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      department: data['department'] ?? '',
      location: data['location'] ?? '',
      bio: data['bio'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
