import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/features/teams/presentation/widgets/team_stats_row.dart';

/// Full-featured team details screen with hero header and 3 tabs.
///
/// The page receives an initial [TeamEntity] via the route, but
/// subscribes to the cubit stream so it always shows the latest
/// data from Firestore (e.g. after adding a member).
class TeamDetailsPage extends StatefulWidget {
  final TeamEntity team;

  const TeamDetailsPage({super.key, required this.team});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Cached user profiles, fetched once on init.
  List<ProfileEntity> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserProfiles();
  }

  Future<void> _loadUserProfiles() async {
    final users = await context.read<TeamsCubit>().getAllUsers();
    if (mounted) setState(() => _allUsers = users);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Finds the up-to-date team from the cubit's loaded list.
  /// Falls back to the initial snapshot passed via the route.
  TeamEntity _resolveTeam(TeamsState state) {
    if (state is TeamsLoaded) {
      return state.teams.cast<TeamEntity>().firstWhere(
        (t) => t.id == widget.team.id,
        orElse: () => widget.team,
      );
    }
    return widget.team;
  }

  bool _isAdmin(TeamEntity team) =>
      team.adminId == FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamsCubit, TeamsState>(
      listenWhen: (prev, curr) =>
          curr is TeamDeletedSuccess ||
          curr is TeamsError ||
          curr is TeamMemberRemovedSuccess ||
          curr is TeamMemberAddedSuccess,
      listener: (context, state) {
        if (state is TeamDeletedSuccess) {
          context.go('/home');
        } else if (state is TeamMemberAddedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.memberAdded),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is TeamMemberRemovedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.memberRemoved),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is TeamsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      buildWhen: (prev, curr) => curr is TeamsLoaded || curr is TeamsLoading,
      builder: (context, state) {
        final team = _resolveTeam(state);
        final isAdmin = _isAdmin(team);

        return Scaffold(
          backgroundColor: AppColors.backgroundScreen,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _TeamHeroSliver(
                team: team,
                isAdmin: isAdmin,
                tabController: _tabController,
              ),
            ],
            body: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryBlue,
                  indicatorWeight: 2,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: AppStrings.membersTab),
                    Tab(text: AppStrings.tasksTab),
                    Tab(text: AppStrings.chatTab),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _MembersTab(
                        team: team,
                        isAdmin: isAdmin,
                        allUsers: _allUsers,
                      ),
                      const _TasksTab(),
                      const _ChatTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: isAdmin
              ? FloatingActionButton(
                  onPressed: () =>
                      context.push('/teams/add-member', extra: team),
                  backgroundColor: AppColors.primaryBlue,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: AppColors.white),
                )
              : null,
        );
      },
    );
  }
}

// --- Hero Sliver ---

class _TeamHeroSliver extends StatelessWidget {
  final TeamEntity team;
  final bool isAdmin;
  final TabController tabController;

  const _TeamHeroSliver({
    required this.team,
    required this.isAdmin,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (isAdmin)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text(AppStrings.edit),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(
                      AppStrings.delete,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(background: _HeroBackground(team: team)),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    if (action == 'edit') {
      context.push('/teams/update', extra: team);
    } else if (action == 'delete') {
      _showDeleteConfirmation(context);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final cubit = context.read<TeamsCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: const Text(AppStrings.deleteTeam),
          content: Text('${AppStrings.deleteTeamConfirmation} "${team.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.deleteTeam(team.id);
              },
              child: const Text(
                AppStrings.delete,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  final TeamEntity team;

  const _HeroBackground({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                _HeroAvatar(team: team),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.onlineStatus,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              team.name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (team.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  team.description,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TeamStatsRow(team: team),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  final TeamEntity team;

  const _HeroAvatar({required this.team});

  @override
  Widget build(BuildContext context) {
    if (team.photoUrl != null && team.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: ImageHelper.getProvider(team.photoUrl),
      );
    }
    return CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.white.withValues(alpha: 0.3),
      child: Text(
        team.name[0].toUpperCase(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// --- Members Tab ---

class _MembersTab extends StatelessWidget {
  final TeamEntity team;
  final bool isAdmin;
  final List<ProfileEntity> allUsers;

  const _MembersTab({
    required this.team,
    required this.isAdmin,
    required this.allUsers,
  });

  ProfileEntity? _findProfile(String uid) {
    final matches = allUsers.where((u) => u.uid == uid);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isAdmin) ...[
          _InviteMemberButton(
            onTap: () => context.push('/teams/add-member', extra: team),
          ),
          const SizedBox(height: 16),
        ],
        const _MembersSectionHeader(label: AppStrings.teamLeads),
        const SizedBox(height: 8),
        _MemberTile(
          profile: _findProfile(team.adminId),
          userId: team.adminId,
          isAdmin: true,
        ),
        const SizedBox(height: 16),
        if (team.membersIds.length > 1) ...[
          const _MembersSectionHeader(label: 'MEMBERS'),
          const SizedBox(height: 8),
          ...team.membersIds
              .where((id) => id != team.adminId)
              .map(
                (uid) => _MemberTile(
                  profile: _findProfile(uid),
                  userId: uid,
                  isAdmin: false,
                ),
              ),
        ],
        const SizedBox(height: 16),
        _LatestTaskUpdateBanner(team: team),
      ],
    );
  }
}

class _InviteMemberButton extends StatelessWidget {
  final VoidCallback onTap;

  const _InviteMemberButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primaryBlueLight,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_outlined, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text(
              AppStrings.inviteNewMember,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MembersSectionHeader extends StatelessWidget {
  final String label;

  const _MembersSectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }
}

/// Shows a member tile with real profile data when available.
class _MemberTile extends StatelessWidget {
  final ProfileEntity? profile;
  final String userId;
  final bool isAdmin;

  const _MemberTile({
    this.profile,
    required this.userId,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile?.fullName ?? 'User ${userId.substring(0, 6)}';
    final subtitle = profile?.jobTitle ?? (isAdmin ? 'Admin' : 'Member');
    final hasPhoto = profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: ImageHelper.getProvider(profile?.photoUrl),
                backgroundColor: AppColors.primaryBlue,
                child: hasPhoto
                    ? null
                    : Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.onlineStatus,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                AppStrings.adminRole,
                style: TextStyle(
                  color: Color(0xFFE65100),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

class _LatestTaskUpdateBanner extends StatelessWidget {
  final TeamEntity team;

  const _LatestTaskUpdateBanner({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: AppColors.primaryBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.latestTaskUpdate,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'No recent task updates.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Tasks Tab ---

class _TasksTab extends StatelessWidget {
  const _TasksTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_outlined, size: 56, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Assigned tasks will appear here.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// --- Chat Tab ---

class _ChatTab extends StatelessWidget {
  const _ChatTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 56,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            AppStrings.chatComingSoon,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
