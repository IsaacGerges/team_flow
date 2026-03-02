import 'package:equatable/equatable.dart';

/// Represents a team in the domain layer.
class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final List<String> membersIds;
  final String? photoUrl;
  final String category;
  final bool isPrivate;
  final double progressPercent;
  final DateTime? updatedAt;

  const TeamEntity({
    required this.id,
    required this.name,
    required this.adminId,
    required this.membersIds,
    this.description = '',
    this.photoUrl,
    this.category = 'Other',
    this.isPrivate = false,
    this.progressPercent = 0.0,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    adminId,
    membersIds,
    photoUrl,
    category,
    isPrivate,
    progressPercent,
    updatedAt,
  ];
}
