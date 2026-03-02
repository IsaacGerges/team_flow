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
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.currentAssigneeIds.isNotEmpty
        ? widget.currentAssigneeIds.first
        : null;
    context.read<TasksCubit>().loadTeamTasks(widget.teamId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundScreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Assign Task',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, taskState) {
          return BlocBuilder<TeamsCubit, TeamsState>(
            builder: (context, teamState) {
              if (teamState is TeamsLoading || taskState is TasksLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                );
              }

              // In a real app, we'd find the specific team.
              // For now we use the members loaded in TeamsCubit if available.
              // Better: TeamsCubit should have a getter for team by ID.
              // But we can just use the ProfileCubit (which we should provide)
              // to get all users and filter by team members.

              // For this demo, I'll assume it's already provided.
              // I'll use a placeholder list of profiles for now.
              return _buildBody(taskState);
            },
          );
        },
      ),
      bottomNavigationBar: _selectedUserId != null ? _buildBottomPanel() : null,
    );
  }

  Widget _buildBody(TasksState taskState) {
    // We need the team members from ProfileCubit
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..getAllUsers(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          if (profileState is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (profileState is ProfileLoadedAll) {
            final tasks = taskState is TasksLoaded
                ? taskState.tasks
                : <TaskEntity>[];
            final users = profileState.users.where((u) {
              final matchesQuery = u.fullName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
              return matchesQuery;
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search team members...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildSectionHeader('SUGGESTED MEMBERS', isAI: true),
                      ..._buildUserList(users, tasks, isSuggested: true),
                      const SizedBox(height: 24),
                      _buildSectionHeader('ALL MEMBERS (${users.length})'),
                      ..._buildUserList(users, tasks, isSuggested: false),
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

  Widget _buildSectionHeader(String title, {bool isAI = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          if (isAI) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'AI RECOMMENDED',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
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
    // Calculate load per user
    final Map<String, int> loadMap = {};
    for (var task in tasks) {
      if (task.status != TaskStatus.done) {
        for (var uid in task.assigneeIds) {
          loadMap[uid] = (loadMap[uid] ?? 0) + 1;
        }
      }
    }

    final filteredUsers = isSuggested
        ? users.where((u) => (loadMap[u.uid] ?? 0) <= 2).take(3).toList()
        : users;

    return filteredUsers.map((user) {
      final load = loadMap[user.uid] ?? 0;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          onTap: () => setState(() => _selectedUserId = user.uid),
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: ImageHelper.getProvider(user.photoUrl ?? ''),
          ),
          title: Text(
            user.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Capacity: ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (load / 10).clamp(0, 1),
                          backgroundColor: AppColors.divider.withValues(
                            alpha: 0.5,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getLoadColor(load),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '$load Active Tasks',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Radio<String>(
            value: user.uid,
            groupValue: _selectedUserId,
            onChanged: (val) => setState(() => _selectedUserId = val),
            activeColor: AppColors.primaryBlue,
          ),
        ),
      );
    }).toList();
  }

  Color _getLoadColor(int load) {
    if (load <= 2) return AppColors.success;
    if (load <= 5) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primaryBlue,
                radius: 20,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Assigning to member',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Member will receive a notification',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop([_selectedUserId!]),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm Assignment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
