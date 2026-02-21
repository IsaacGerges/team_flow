import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String adminId; // مين القائد؟
  final List<String> membersIds; // ليستة فيها IDs بتوع الأعضاء

  const TeamEntity({
    required this.id,
    required this.name,
    required this.adminId,
    required this.membersIds,
  });

  @override
  List<Object> get props => [id, name, adminId, membersIds];
}
