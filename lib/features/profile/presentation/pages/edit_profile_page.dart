import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_state.dart';
import 'package:team_flow/features/profile/presentation/widgets/edit_profile_text_field.dart';
import 'package:team_flow/features/profile/presentation/widgets/profile_section_title.dart';
import 'package:team_flow/features/profile/presentation/widgets/skill_chip.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  List<String> _currentSkills = [];
  bool _isVisibleToTeam = true;
  bool _shareContactInfo = false;
  late final String _uid;
  ProfileEntity? _currentProfile;
  String? _pickedPhoto;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      _currentProfile = state.profile;
      _uid = state.profile.uid;
      _nameController.text = state.profile.fullName;
      _emailController.text = state.profile.email;
      _phoneController.text = state.profile.phone;
      _jobTitleController.text = state.profile.jobTitle;
      _departmentController.text = state.profile.department;
      _locationController.text = state.profile.location;
      _bioController.text = state.profile.bio;
      _currentSkills = List.from(state.profile.skills);
      _isVisibleToTeam = state.profile.isVisibleToTeam;
      _shareContactInfo = state.profile.shareContactInfo;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_currentProfile == null) return;
    final newProfile = ProfileEntity(
      createdAt: _currentProfile!.createdAt,
      uid: _uid,
      fullName: _nameController.text,
      email: _emailController.text,
      teamsCount: _currentProfile!.teamsCount,
      completedCount: _currentProfile!.completedCount,
      activeCount: _currentProfile!.activeCount,
      phone: _phoneController.text,
      jobTitle: _jobTitleController.text,
      department: _departmentController.text,
      location: _locationController.text,
      bio: _bioController.text,
      skills: _currentSkills,
      photoUrl: _pickedPhoto ?? _currentProfile!.photoUrl,
      isDarkMode: _currentProfile!.isDarkMode,
      notificationsEnabled: _currentProfile!.notificationsEnabled,
      isVisibleToTeam: _isVisibleToTeam,
      shareContactInfo: _shareContactInfo,
    );
    context.read<ProfileCubit>().updateProfile(newProfile);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdatedSuccess) {
          Fluttertoast.showToast(msg: AppStrings.profileUpdated);
          context.pop();
        } else if (state is ProfileError) {
          Fluttertoast.showToast(msg: state.message);
        } else if (state is ProfilePhotoPicked) {
          setState(() {
            _pickedPhoto = state.base64Photo;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            AppStrings.editProfile,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhotoSection(),
                const Divider(color: AppColors.divider, thickness: 1),
                const SizedBox(height: 16),

                const ProfileSectionTitle(title: AppStrings.basicInfo),
                EditProfileTextField(
                  label: AppStrings.fullName,
                  controller: _nameController,
                ),
                EditProfileTextField(
                  label: AppStrings.emailAddress,
                  controller: _emailController,
                ),
                EditProfileTextField(
                  label: AppStrings.phoneNumber,
                  controller: _phoneController,
                ),

                const SizedBox(height: 24),
                const ProfileSectionTitle(title: AppStrings.professionalInfo),
                EditProfileTextField(
                  label: AppStrings.jobTitle,
                  controller: _jobTitleController,
                ),
                EditProfileTextField(
                  label: AppStrings.department,
                  controller: _departmentController,
                ),
                EditProfileTextField(
                  label: AppStrings.officeLocation,
                  controller: _locationController,
                  suffixIcon: const Icon(
                    Icons.location_on,
                    color: AppColors.textHint,
                  ),
                ),

                const SizedBox(height: 24),
                const ProfileSectionTitle(title: AppStrings.about),
                EditProfileTextField(
                  label: AppStrings.bio,
                  controller: _bioController,
                  maxLines: 4,
                ),

                _buildSkillsSection(),

                const SizedBox(height: 24),
                const ProfileSectionTitle(title: AppStrings.privacySettings),
                _buildPrivacyToggles(),

                const SizedBox(height: 32),
                _buildBottomActions(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final displayPhoto = _pickedPhoto ?? _currentProfile?.photoUrl;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 70,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: ClipOval(
              child: displayPhoto != null && displayPhoto.isNotEmpty
                  ? Image.memory(
                      base64Decode(displayPhoto),
                      width: 133,
                      height: 133,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.textHint,
                      ),
                    )
                  : Image.asset(
                      'assets/images/profile/profile_default_image.png',
                      width: 133,
                      height: 133,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.textHint,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  context.read<ProfileCubit>().pickPhoto();
                },
                child: const Text(
                  AppStrings.changePhoto,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (displayPhoto != null && displayPhoto.isNotEmpty)
                Container(
                  width: 1,
                  height: 16,
                  color: AppColors.divider,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
              if (displayPhoto != null && displayPhoto.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pickedPhoto =
                          ''; // Using empty string to represent removed
                    });
                  },
                  child: const Text(
                    AppStrings.remove,
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionTitle(title: AppStrings.skills),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._currentSkills.map(
                (s) => SkillChip(
                  label: s,
                  isRemovable: true,
                  onRemove: () => setState(() => _currentSkills.remove(s)),
                ),
              ),
              SkillChip(
                label: AppStrings.addSkill,
                isAddButton: true,
                onTap: _showAddSkillDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSkillDialog() async {
    final skillController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.addSkill),
          content: TextField(
            controller: skillController,
            decoration: const InputDecoration(
              hintText: 'e.g. Flutter, UI/UX, Dart',
            ),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              final trimmed = value.trim();
              if (trimmed.isNotEmpty && !_currentSkills.contains(trimmed)) {
                setState(() {
                  _currentSkills.add(trimmed);
                });
              }
              context.pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                AppStrings.cancel,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final trimmed = skillController.text.trim();
                if (trimmed.isNotEmpty && !_currentSkills.contains(trimmed)) {
                  setState(() {
                    _currentSkills.add(trimmed);
                  });
                }
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrivacyToggles() {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              AppStrings.visibleToTeam,
              style: TextStyle(fontSize: 14),
            ),
            subtitle: const Text(
              AppStrings.visibleToTeamDesc,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: _isVisibleToTeam,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _isVisibleToTeam = v),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text(
              AppStrings.shareContactInfo,
              style: TextStyle(fontSize: 14),
            ),
            subtitle: const Text(
              AppStrings.shareContactInfoDesc,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: _shareContactInfo,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _shareContactInfo = v),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                _pickedPhoto = ''; // Using empty string to represent removed
                context.pop();
              },
              child: const Text(
                AppStrings.cancel,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                AppStrings.saveChanges,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
