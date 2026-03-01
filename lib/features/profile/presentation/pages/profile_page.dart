import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';
import 'package:team_flow/features/profile/presentation/widgets/preference_tile.dart';
import 'package:team_flow/features/profile/presentation/widgets/profile_section_title.dart';
import 'package:team_flow/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:team_flow/features/profile/presentation/widgets/skill_chip.dart';
import 'package:team_flow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:team_flow/injection_container.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ProfileCubit>().getProfile(uid);
    }
  }

  void _handleLogout() async {
    final authCubit = sl<AuthCubit>();
    await authCubit.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return Center(child: Text(state.message));
          } else if (state is ProfileLoaded) {
            return _buildProfileContent(context, state.profile);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileEntity profile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, profile),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabs(),
                const SizedBox(height: 24),
                _buildBiography(profile),
                const SizedBox(height: 24),
                _buildSkills(profile),
                const SizedBox(height: 24),
                _buildPreferences(),
                const SizedBox(height: 32),
                _buildLogOutButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileEntity profile) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => context.push('/home'),
                  ),
                  Container(
                    // padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.white),
                      onPressed: () {
                        context.push('/profile/edit');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipOval(
                      child:
                          profile.photoUrl != null &&
                              profile.photoUrl!.isNotEmpty
                          ? Image.memory(
                              base64Decode(profile.photoUrl!),
                              width: 133,
                              height: 133,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
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
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.textHint,
                                  ),
                            ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => context.push('/profile/edit'),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              profile.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.white),
                  SizedBox(width: 6),
                  Text(
                    "Joined ${profile.createdAt.year}-${profile.createdAt.month}-${profile.createdAt.day}",
                    style: TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              transform: Matrix4.translationValues(0.0, 20.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileStatCard(
                    count: profile.teamsCount.toString(),
                    label: AppStrings.teamsStats,
                  ),
                  ProfileStatCard(
                    count: profile.completedCount.toString(),
                    label: AppStrings.completedStats,
                    isPrimary: true,
                  ),
                  ProfileStatCard(
                    count: profile.activeCount.toString(),
                    label: AppStrings.activeStats,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    AppStrings.about,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  AppStrings.activity,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  AppStrings.teamsStats,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiography(ProfileEntity profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionTitle(title: AppStrings.biography),
          Text(
            profile.bio.isEmpty ? "No biography added yet." : profile.bio,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkills(ProfileEntity profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionTitle(title: AppStrings.skills),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (profile.skills.isEmpty)
                const Text(
                  "No skills added yet.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ...profile.skills.map((s) => SkillChip(label: s)),
              SkillChip(
                label: AppStrings.addSkillNew,
                isAddButton: true,
                onTap: () => context.push('/profile/edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionTitle(title: AppStrings.preferences),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                PreferenceTile(
                  title: AppStrings.darkMode,
                  icon: Icons.dark_mode,
                  iconBgColor: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF7E22CE),
                  trailing: Switch(
                    value: false,
                    onChanged: (v) {},
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                const Divider(height: 1, indent: 56),
                PreferenceTile(
                  title: AppStrings.notifications,
                  icon: Icons.notifications,
                  iconBgColor: const Color(0xFFFFE4E6),
                  iconColor: const Color(0xFFE11D48),
                  trailing: Switch(
                    value: true,
                    onChanged: (v) {},
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                const Divider(height: 1, indent: 56),
                PreferenceTile(
                  title: AppStrings.privacyAndSecurity,
                  icon: Icons.lock,
                  iconBgColor: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogOutButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: const Text(
          AppStrings.logOut,
          style: TextStyle(
            color: AppColors.error,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
