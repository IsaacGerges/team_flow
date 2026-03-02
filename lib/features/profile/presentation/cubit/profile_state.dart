import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdatedSuccess extends ProfileState {
  const ProfileUpdatedSuccess();
}

class ProfilePhotoPicked extends ProfileState {
  final String base64Photo;

  const ProfilePhotoPicked(this.base64Photo);

  @override
  List<Object?> get props => [base64Photo];
}

class ProfileLoadedAll extends ProfileState {
  final List<ProfileEntity> users;

  const ProfileLoadedAll(this.users);

  @override
  List<Object?> get props => [users];
}
