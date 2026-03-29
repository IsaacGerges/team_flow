import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/image_helper.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../teams/presentation/cubit/team_cubit.dart';
import '../../../teams/presentation/cubit/team_state.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../../../../injection_container.dart';

class TaskAssignmentPage extends StatefulWidget {
  final String teamId;
  final List<String> currentAssigneeIds;

  const TaskAssignmentPage({
    super.key,
    required this.teamId,
    required this.currentAssigneeIds,
  });

  @override
  State<TaskAssignmentPage> createState() => _TaskAssignmentPageState();
}

class _TaskAssignmentPageState extends State<TaskAssignmentPage> {
  String _searchQuery = '';
  final Set<String> _selectedUserIds = {};
  late final TasksCubit _localTasksCubit;

  @override
  void initState() {
    super.initState();
    _selectedUserIds.addAll(widget.currentAssigneeIds);
    _localTasksCubit = sl<TasksCubit>()..loadTeamTasks(widget.teamId);
  }

  @override
  void dispose() {
    _localTasksCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TasksCubit>.value(
      value: _localTasksCubit,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.slate800),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Assign Task',
            style: TextStyle(
              color: AppColors.slate800,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<TasksCubit, TasksState>(
          bloc: _localTasksCubit,
          builder: (context, taskState) {
            return BlocBuilder<TeamsCubit, TeamsState>(
              builder: (context, teamState) {
                if (teamState is TeamsLoading || taskState is TasksLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBlue),
                  );
                }
                return _buildBody(taskState);
              },
            );
          },
        ),
        bottomNavigationBar: _selectedUserIds.isNotEmpty
            ? _buildBottomPanel()
            : null,
      ),
    );
  }

  Widget _buildBody(TasksState taskState) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..getAllUsers(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          if (profileState is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }
          if (profileState is ProfileLoadedAll) {
            final tasks = taskState is TasksLoaded
                ? taskState.tasks
                : <TaskEntity>[];
            final teamsState = context.read<TeamsCubit>().state;
            final currentTeam = teamsState is TeamsLoaded
                ? teamsState.teams
                      .where((t) => t.id == widget.teamId)
                      .firstOrNull
                : null;
            final memberIds = currentTeam?.membersIds ?? [];
            final adminId = currentTeam?.adminId;

            final users = profileState.users
                .where((u) => memberIds.contains(u.uid))
                .where(
                  (u) => u.fullName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .where((u) => u.uid != adminId)
                .toList();

            return Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildSectionHeader('SUGGESTED', isAI: true),
                      ..._buildUserList(users, tasks, isSuggested: true),
                      const SizedBox(height: 32),
                      _buildSectionHeader('TEAM MEMBERS (${users.length})'),
                      ..._buildUserList(users, tasks, isSuggested: false),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.slate800,
          ),
          decoration: const InputDecoration(
            hintText: 'Search members...',
            hintStyle: TextStyle(
              color: AppColors.slate400,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.slate400,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isAI = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.slate500,
              letterSpacing: 0.5,
            ),
          ),
          if (isAI) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.blueBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primaryBlue, size: 10),
                  SizedBox(width: 4),
                  Text(
                    'AI POWERED',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildUserList(
    List<dynamic> users,
    List<TaskEntity> tasks, {
    required bool isSuggested,
  }) {
    final Map<String, int> loadMap = {};
    for (var task in tasks) {
      if (task.status != TaskStatus.done && !task.isDraft) {
        for (var uid in task.assigneeIds) {
          loadMap[uid] = (loadMap[uid] ?? 0) + 1;
        }
      }
    }


    final maxLoad = loadMap.values.isEmpty
        ? 1
        : loadMap.values.reduce((a, b) => a > b ? a : b);
    final maxLoadClamped = maxLoad < 1 ? 1 : maxLoad;

    final filteredUsers = isSuggested
        ? users.where((u) => (loadMap[u.uid] ?? 0) <= 2).take(3).toList()
        : users;

    return filteredUsers.map((user) {
      final load = loadMap[user.uid] ?? 0;
      final isSelected = _selectedUserIds.contains(user.uid);
      final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

      return GestureDetector(
        onTap: () => setState(() {
          if (_selectedUserIds.contains(user.uid)) {
            _selectedUserIds.remove(user.uid);
          } else {
            _selectedUserIds.add(user.uid);
          }
        }),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blueBg : AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.slate200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.slate100,
                backgroundImage: hasPhoto
                    ? ImageHelper.getProvider(user.photoUrl)
                    : null,
                child: !hasPhoto
                    ? Text(
                        user.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.slate800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$load active task${load == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: load == 0
                                  ? 0.0
                                  : (load / maxLoadClamped).clamp(0.05, 1.0),
                              backgroundColor: AppColors.slate100,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getLoadColor(load),
                              ),
                              minHeight: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildCustomCheckbox(isSelected),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCustomCheckbox(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.slate300,
          width: 2,
        ),
        color: isSelected ? AppColors.primaryBlue : AppColors.white,
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 16, color: AppColors.white)
          : null,
    );
  }

  Color _getLoadColor(int load) {
    if (load <= 2) return AppColors.success;
    if (load <= 5) return AppColors.notificationAmber;
    return AppColors.red500;
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Confirming will notify ${_selectedUserIds.length} member${_selectedUserIds.length == 1 ? '' : 's'} immediately.',
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(_selectedUserIds.toList()),
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
                'Confirm Assignment',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
