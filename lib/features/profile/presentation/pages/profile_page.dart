import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:team_flow/core/usecases/get_current_user_id_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_flow/core/constants/app_assets.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';
import 'package:team_flow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:team_flow/injection_container.dart';
import 'dart:convert';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<ProfileCubit>().state;
    if (currentState is! ProfileLoaded) {
      final uid =
          sl<GetCurrentUserIdUseCase>()() ??
          sl<GetCurrentUserIdUseCase>()();
      if (uid != null) {
        context.read<ProfileCubit>().getProfile(uid);
      }
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
      backgroundColor: AppColors.backgroundDashboard,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          } else if (state is ProfileError) {
            return Center(child: Text(state.message));
          } else if (state is ProfileLoaded) {
            return _buildProfileContent(context, state.profile);
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileEntity profile) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Stack(
        children: [
          const SizedBox.shrink(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroHeader(context, profile),
              const SizedBox(height: 16),
              _buildStatsRow(profile),
              const SizedBox(height: 24),
              _buildTabSelector(),
              const SizedBox(height: 24),
              _buildTabContent(profile),
              const SizedBox(height: 32),
              _buildPreferencesSection(),
              const SizedBox(height: 40),
              _buildLogoutAction(),
              const SizedBox(height: 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, ProfileEntity profile) {
    final joinedDate = DateFormat('MMM yyyy').format(profile.createdAt);
    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue,
                AppColors.primaryBlue,
                AppColors.primaryBlue,
                AppColors.backgroundDashboard,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.bgLight,
                        AppColors.bgLight.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildCircularButton(
                  icon: Icons.edit_outlined,
                  onPressed: () {
                    context.go('/profile/edit');
                  },
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 130),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundDashboard,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.backgroundDashboard,
                      backgroundImage:
                          profile.photoUrl != null &&
                              profile.photoUrl!.isNotEmpty
                          ? (profile.photoUrl!.startsWith('http') ||
                                        profile.photoUrl!.startsWith('https')
                                    ? NetworkImage(profile.photoUrl!)
                                    : MemoryImage(
                                        base64Decode(profile.photoUrl!),
                                      ))
                                as ImageProvider
                          : const AssetImage(AppAssets.profileDefaultImage),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/profile/edit'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.bgLight,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: AppColors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                profile.fullName,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Joined $joinedDate',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: AppColors.white, size: 18),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ProfileEntity profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<TeamsCubit, TeamsState>(
        builder: (context, teamsState) {
          return BlocBuilder<TasksCubit, TasksState>(
            builder: (context, tasksState) {
              final teamsCount = teamsState is TeamsLoaded
                  ? teamsState.teams.length
                  : profile.teamsCount;

              final tasks = tasksState is TasksLoaded ? tasksState.tasks : [];
              final completedCount = tasks
                  .where((t) => t.status == TaskStatus.done)
                  .length;
              final pendingCount = tasks
                  .where((t) => t.status != TaskStatus.done)
                  .length;

              return Row(
                children: [
                  Expanded(
                    child: _buildGlassStatCard(teamsCount.toString(), 'Teams'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPrimaryStatCard(
                      completedCount.toString(),
                      'Completed',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGlassStatCard(
                      pendingCount.toString(),
                      AppStrings.pendingLabel,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGlassStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate800.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.slate500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    final tabs = [AppStrings.aboutTab, AppStrings.activitySection, 'Teams'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.slate200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isSelected = _selectedTabIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.white : AppColors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.slate900
                            : AppColors.slate500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent(ProfileEntity profile) {
    if (_selectedTabIndex != 0) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppStrings.comingSoon,
            style: TextStyle(color: AppColors.slate500),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(AppStrings.biographySection),
          const SizedBox(height: 12),
          Text(
            profile.bio.isEmpty ? AppStrings.noBiographyAdded : profile.bio,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: AppColors.slate600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(AppStrings.skillsSection),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...profile.skills.map((skill) => _buildSimpleChip(skill)),
              _buildAddSkillChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.slate900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSimpleChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.slate600,
        ),
      ),
    );
  }

  Widget _buildAddSkillChip() {
    return GestureDetector(
      onTap: () {
        context.go('/profile/edit');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_rounded,
              size: 14,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 4),
            Text(
              AppStrings.addNew,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(AppStrings.preferencesSection),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate100),
            ),
            child: Column(
              children: [
                _buildPreferenceTile(
                  icon: Icons.notifications_rounded,
                  color: Colors.pink,
                  title: 'Notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (v) {},
                    activeThumbColor: AppColors.primaryBlue,
                  ),
                ),
                const Divider(height: 1, indent: 50, color: AppColors.slate100),
                _buildPreferenceTile(
                  icon: Icons.lock_rounded,
                  color: AppColors.success,
                  title: 'Privacy & Security',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required Color color,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.slate900,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLogoutAction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: _handleLogout,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Log Out',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
