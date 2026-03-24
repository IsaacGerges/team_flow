import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/core/helpers/progress_helper.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/features/tasks/presentation/widgets/task_card.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';
import 'package:team_flow/injection_container.dart';

class TeamDetailsPage extends StatefulWidget {
  final TeamEntity team;

  const TeamDetailsPage({super.key, required this.team});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProfileEntity> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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

  TeamEntity _resolveTeam(TeamsState state) {
    if (state is TeamsLoaded) {
      for (final team in state.teams) {
        if (team.id == widget.team.id) return team;
      }
    }
    return widget.team;
  }

  bool _isAdmin(TeamEntity team) =>
      team.adminId == FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TasksCubit>()..loadTeamTasks(widget.team.id),
      child: BlocConsumer<TeamsCubit, TeamsState>(
        listener: (context, state) {
          if (state is TeamDeletedSuccess) {
            context.go('/home');
          } else if (state is TeamMemberAddedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Member added successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is TeamMemberRemovedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Member removed successfully'),
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
        builder: (context, state) {
          final team = _resolveTeam(state);
          final isAdmin = _isAdmin(team);

          return Scaffold(
            backgroundColor: const Color(0xFFF6F6F8),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (_tabController.index == 1) {
                  context.push('/tasks/create', extra: team);
                } else if (_tabController.index == 0 && isAdmin) {
                  context.push('/teams/add-member', extra: team);
                }
              },
              backgroundColor: const Color(0xFF2B6CEE),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 8,
              child: const Icon(Icons.add_rounded, size: 28),
            ),
            body: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _HeroSection(team: team, isAdmin: isAdmin),
                  _StatsOverlay(team: team),
                  const SizedBox(height: 4),
                  _SegmentedTabBar(tabController: _tabController),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Semantics(
                      key: ValueKey('tab_${_tabController.index}'),
                      container: true,
                      child: [
                        _MembersTab(
                          team: team,
                          isAdmin: isAdmin,
                          allUsers: _allUsers,
                        ),
                        _TasksTab(team: team),
                        _ChatTab(),
                      ][_tabController.index],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final TeamEntity team;
  final bool isAdmin;

  const _HeroSection({required this.team, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B6CEE), Color(0xFF1A4FB8)],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(13),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6B9AF5).withAlpha(51),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BlurIconButton(
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => context.pop(),
                        ),
                        if (isAdmin)
                          _BlurIconButton(
                            icon: Icons.more_vert_rounded,
                            onPressed: () => _showMenu(context),
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _HeroAvatar(team: team),
                  const SizedBox(height: 16),
                  Text(
                    team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (team.description.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        team.description,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFDBEAFE),
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 54),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded),
              title: const Text(
                'Edit Team',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/teams/update', extra: team);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: const Text(
                'Delete Team',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final cubit = context.read<TeamsCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete Team',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Are you sure you want to delete "${team.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                cubit.deleteTeam(team.id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
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
    final hasPhoto = team.photoUrl != null && team.photoUrl!.isNotEmpty;
    return Stack(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(51), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 46,
            backgroundColor: const Color(0xFFF1F5F9),
            backgroundImage: hasPhoto
                ? ImageHelper.getProvider(team.photoUrl)
                : null,
            child: !hasPhoto
                ? Text(
                    team.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 6,
          right: 6,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF255BC9), width: 4),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsOverlay extends StatelessWidget {
  final TeamEntity team;
  const _StatsOverlay({required this.team});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            final tasks = state is TasksLoaded ? state.tasks : <TaskEntity>[];
            final progress = ProgressHelper.calculateTasksProgress(tasks);
            final activeCount = tasks
                .where((t) => t.status != TaskStatus.done)
                .length;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(color: Colors.black.withAlpha(5), spreadRadius: 1),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _StatItem(
                      label: 'MEMBERS',
                      value: '${team.membersIds.length}',
                      valueColor: const Color(0xFF1E293B),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9), // slate-100
                    ),
                    _StatItem(
                      label: 'ACTIVE',
                      value: '$activeCount',
                      valueColor: const Color(0xFF2B6CEE), // primary
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9), // slate-100
                    ),
                    _StatItem(
                      label: 'COMPLETE',
                      value: '${(progress * 100).toInt()}%',
                      valueColor: const Color(0xFF10B981), // emerald-500
                      icon: Icons.trending_up_rounded,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData? icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B), // slate-500
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  letterSpacing: -0.5,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: valueColor),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabBar extends StatelessWidget {
  final TabController tabController;
  const _SegmentedTabBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final tabs = ['Members', 'Tasks', 'Chat'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 52,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0).withAlpha(128),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isSelected = tabController.index == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => tabController.animateTo(i),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 14,
                        color: isSelected
                            ? const Color(0xFF2B6CEE)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  final TeamEntity team;
  final bool isAdmin;
  final List<ProfileEntity> allUsers;

  const _MembersTab({
    required this.team,
    required this.isAdmin,
    required this.allUsers,
  });

  ProfileEntity? _findProfile(String uid) =>
      allUsers.where((u) => u.uid == uid).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final otherMemberIds = team.membersIds
        .where((id) => id != team.adminId)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (isAdmin) ...[
            _InviteButton(
              onTap: () => context.push('/teams/add-member', extra: team),
            ),
            const SizedBox(height: 24),
          ],
          const _SectionHeader(label: 'TEAM LEADS'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                const BoxShadow(color: Color(0x08000000), spreadRadius: 1),
              ],
            ),
            child: _MemberRow(
              profile: _findProfile(team.adminId),
              userId: team.adminId,
              isAdmin: true,
            ),
          ),
          const SizedBox(height: 24),
          if (otherMemberIds.isNotEmpty) ...[
            const _SectionHeader(label: 'MEMBERS'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  const BoxShadow(color: Color(0x08000000), spreadRadius: 1),
                ],
              ),
              child: Column(
                children: [
                  for (var i = 0; i < otherMemberIds.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF8FAFC),
                      ),
                    _MemberRow(
                      profile: _findProfile(otherMemberIds[i]),
                      userId: otherMemberIds[i],
                      isAdmin: false,
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              final doneTasks = state is TasksLoaded
                  ? state.tasks
                        .where((t) => t.status == TaskStatus.done)
                        .toList()
                  : <TaskEntity>[];
              if (doneTasks.isEmpty) return const SizedBox.shrink();
              final latest = doneTasks.first;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B6CEE).withAlpha(13),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2B6CEE).withAlpha(25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B6CEE).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.assignment_rounded,
                        color: Color(0xFF2B6CEE),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Latest Task Update',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${latest.title}" completed.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _InviteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DottedBorderPainter(
                  color: const Color(0xFF2B6CEE).withAlpha(76),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B6CEE).withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF2B6CEE),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Invite New Member',
                    style: TextStyle(
                      color: Color(0xFF2B6CEE),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _BlurIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8), // slate-400
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final ProfileEntity? profile;
  final String userId;
  final bool isAdmin;

  const _MemberRow({
    required this.profile,
    required this.userId,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile?.fullName ?? 'Loading...';
    final role = profile?.jobTitle ?? (isAdmin ? 'Admin' : 'Member');
    final hasPhoto = profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF1F5F9),
                backgroundImage: hasPhoto
                    ? ImageHelper.getProvider(profile!.photoUrl)
                    : null,
                child: !hasPhoto
                    ? Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2B6CEE),
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // emerald-500
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7), // amber-100
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Color(0xFFB45309), // amber-700
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            IconButton(
              onPressed: () {}, // Chat action
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
              ),
            ),
        ],
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    final newPath = Path();
    for (var metric in metrics) {
      double i = 0.0;
      while (i < metric.length) {
        newPath.addPath(
          metric.extractPath(i, i + 6), // dash length
          Offset.zero,
        );
        i += 12; // gap length
      }
    }
    canvas.drawPath(newPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TasksTab extends StatelessWidget {
  final TeamEntity team;
  const _TasksTab({required this.team});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        if (state is TasksLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          );
        }
        if (state is TasksLoaded) {
          final tasks = state.tasks;
          if (tasks.isEmpty) return _buildEmpty(context);
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TaskCard(
                task: tasks[index],
                onTap: () =>
                    context.push('/tasks/details', extra: tasks[index]),
                onCheckboxChanged: (val) {
                  if (val != null &&
                      tasks[index].creatorId ==
                          FirebaseAuth.instance.currentUser?.uid) {
                    context.read<TasksCubit>().updateTaskStatus(
                      tasks[index].id,
                      val ? TaskStatus.done : TaskStatus.todo,
                      tasks[index],
                    );
                  }
                },
              ),
            ),
          );
        }
        return _buildEmpty(context);
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_late_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No tasks created yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by adding tasks to this team.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/tasks/create', extra: team),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Create First Task',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  const _ChatTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Team Chat Coming Soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time collaboration is on its way.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
