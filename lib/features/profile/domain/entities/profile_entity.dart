import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final int teamsCount;
  final int completedCount;
  final int activeCount;
  final DateTime createdAt;
  final String phone;
  final String jobTitle;
  final String department;
  final String location;
  final String bio;
  final List<String> skills;
  final String? photoUrl;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool isVisibleToTeam;
  final bool shareContactInfo;

  const ProfileEntity({
    required this.uid,
    required this.createdAt,
    required this.fullName,
    required this.email,
    required this.teamsCount,
    required this.completedCount,
    required this.activeCount,
    required this.phone,
    required this.jobTitle,
    required this.department,
    required this.location,
    required this.bio,
    required this.skills,
    this.photoUrl,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.isVisibleToTeam,
    required this.shareContactInfo,
  });

  @override
  List<Object?> get props => [
    uid,
    fullName,
    email,
    teamsCount,
    completedCount,
    activeCount,
    phone,
    jobTitle,
    department,
    location,
    bio,
    skills,
    photoUrl,
    isDarkMode,
    notificationsEnabled,
    isVisibleToTeam,
    shareContactInfo,
  ];
}
