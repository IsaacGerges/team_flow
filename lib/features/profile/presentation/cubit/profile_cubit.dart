import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileCubit({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileInitial());

  Future<void> getProfile(String uid) async {
    emit(const ProfileLoading());
    final result = await getProfileUseCase(uid);
    result.fold(
      (failure) => emit(ProfileError(_mapFailureToMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> updateProfile(ProfileEntity profile) async {
    emit(const ProfileLoading());

    final result = await updateProfileUseCase(profile);
    result.fold(
      (failure) => emit(ProfileError(_mapFailureToMessage(failure))),
      (_) {
        emit(const ProfileUpdatedSuccess());
        emit(ProfileLoaded(profile));
      },
    );
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30, // Downscale due to Firestore limits
      maxWidth: 300,
      maxHeight: 300,
    );

    if (pickedFile != null) {
      try {
        final File file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);

        // Just emit the picked photo, do NOT update firebase yet
        emit(ProfilePhotoPicked(base64String));
      } catch (e) {
        emit(ProfileError(AppStrings.unexpectedError));
      }
    }
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure() => failure.message,
      OfflineFailure() => AppStrings.checkInternetConnection,
      _ => AppStrings.unexpectedError,
    };
  }
}
