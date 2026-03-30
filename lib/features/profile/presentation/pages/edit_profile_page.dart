import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_state.dart';
import 'package:team_flow/features/profile/presentation/widgets/edit_profile_text_field.dart';
import 'package:team_flow/features/profile/presentation/widgets/skill_chip.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:team_flow/core/constants/app_assets.dart';
import 'package:team_flow/core/helpers/image_helper.dart';

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
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.slate800,
              size: 18,
            ),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: AppColors.slate800,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoSection(),
              const SizedBox(height: 32),
              const Text(
                'BASIC INFORMATION',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              EditProfileTextField(
                label: AppStrings.fullName,
                controller: _nameController,
                hint: 'e.g. Isaac Gerges',
              ),
              EditProfileTextField(
                label: AppStrings.emailAddress,
                controller: _emailController,
                hint: 'isaac@example.com',
              ),
              EditProfileTextField(
                label: AppStrings.phoneNumber,
                controller: _phoneController,
                hint: '+1 234 567 890',
              ),

              const SizedBox(height: 24),
              const Text(
                'PROFESSIONAL INFO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              EditProfileTextField(
                label: AppStrings.jobTitle,
                controller: _jobTitleController,
                hint: 'e.g. Senior Designer',
              ),
              EditProfileTextField(
                label: AppStrings.department,
                controller: _departmentController,
                hint: 'e.g. Product Team',
              ),
              EditProfileTextField(
                label: 'Office Location',
                controller: _locationController,
                hint: 'e.g. New York, USA',
                suffixIcon: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.slate400,
                  size: 20,
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'ABOUT ME',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              EditProfileTextField(
                label: AppStrings.bio,
                controller: _bioController,
                maxLines: 4,
                hint: 'Tell us about yourself...',
              ),

              _buildSkillsSection(),

              const SizedBox(height: 24),
              const Text(
                'PRIVACY SETTINGS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildPrivacyToggles(),

              const SizedBox(height: 40),
              _buildBottomActions(),
              const SizedBox(height: 60),
            ],
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
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.slate100, width: 8),
                ),
              ),
              CircleAvatar(
                radius: 54,
                backgroundColor: AppColors.white,
                child: CircleAvatar(
                  radius: 51,
                  backgroundImage:
                      ImageHelper.getProvider(displayPhoto) ??
                      const AssetImage(
                        AppAssets.profileDefaultImage,
                      ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => context.read<ProfileCubit>().pickPhoto(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (displayPhoto != null && displayPhoto.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _pickedPhoto = ''),
                  child: const Text(
                    'Remove Photo',
                    style: TextStyle(
                      color: AppColors.red500,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          AppStrings.skillsSection,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.slate500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._currentSkills.map(
              (s) => SkillChip(
                label: s,
                isRemovable: true,
                onRemove: () => setState(() => _currentSkills.remove(s)),
              ),
            ),
            SkillChip(
              label: 'Add Skill',
              isAddButton: true,
              onTap: _showAddSkillDialog,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showAddSkillDialog() async {
    final skillController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Add New Skill',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: skillController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Project Management',
            border: UnderlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = skillController.text.trim();
              if (val.isNotEmpty && !_currentSkills.contains(val)) {
                setState(() => _currentSkills.add(val));
              }
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyToggles() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Visible to Team',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.slate800,
              ),
            ),
            subtitle: const Text(
              'Allow others to see your status',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.slate500,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: _isVisibleToTeam,
            activeTrackColor: AppColors.primaryBlue,
            onChanged: (v) => setState(() => _isVisibleToTeam = v),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: AppColors.slate200),
          ),
          SwitchListTile(
            title: const Text(
              'Share Contact Info',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.slate800,
              ),
            ),
            subtitle: const Text(
              'Show phone/email to members',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.slate500,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: _shareContactInfo,
            activeTrackColor: AppColors.primaryBlue,
            onChanged: (v) => setState(() => _shareContactInfo = v),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: AppColors.primaryBlue.withValues(alpha: 0.3),
        ),
        child: const Text(
          'Save Changes',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}
