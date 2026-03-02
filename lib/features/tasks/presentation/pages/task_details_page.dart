import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/image_helper.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/task_status_badge.dart';
import '../../../../injection_container.dart';

class TaskDetailsPage extends StatefulWidget {
  final TaskEntity task;
  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final _commentController = TextEditingController();
  late TaskEntity _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TasksCubit, TasksState>(
      listener: (context, state) {
        if (state is TaskUpdatedSuccess) {
          // Re-fetch or update local state logic
        } else if (state is TaskCommentAdded) {
          _commentController.clear();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundScreen,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundScreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          actions: [
            _buildStatusChip(),
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
              onPressed: () => _showOptionsMenu(),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriorityBar(),
                    const SizedBox(height: 16),
                    Text(
                      _currentTask.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentTask.teamName} • Created ${DateFormat('MMM dd, yyyy').format(_currentTask.createdAt)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildProgressCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentTask.description.isEmpty
                          ? 'No description provided.'
                          : _currentTask.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'ASSIGNEE',
                            _currentTask.assigneeIds.isNotEmpty
                                ? _currentTask.assigneeIds.first
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            'DUE DATE',
                            _currentTask.dueDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildCommentBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBar() {
    Color color = AppColors.priorityMedium;
    String label = 'Medium Priority';
    if (_currentTask.priority == TaskPriority.high) {
      color = AppColors.priorityHigh;
      label = 'High Priority';
    } else if (_currentTask.priority == TaskPriority.low) {
      color = AppColors.priorityLow;
      label = 'Low Priority';
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    return GestureDetector(
      onTap: _showStatusPicker,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: TaskStatusBadge(status: _currentTask.status),
      ),
    );
  }

  Widget _buildProgressCard() {
    final double progress = _getProgressValue();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: AppColors.primaryBlueLight,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Task Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'On track for delivery',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStageTracker(),
        ],
      ),
    );
  }

  double _getProgressValue() {
    switch (_currentTask.status) {
      case TaskStatus.todo:
        return 0.25;
      case TaskStatus.inProgress:
        return 0.50;
      case TaskStatus.review:
        return 0.75;
      case TaskStatus.done:
        return 1.0;
    }
  }

  Widget _buildStageTracker() {
    final stages = [
      TaskStatus.todo,
      TaskStatus.inProgress,
      TaskStatus.review,
      TaskStatus.done,
    ];
    final currentIdx = stages.indexOf(_currentTask.status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stages.length, (index) {
        final isCompleted = index < currentIdx;
        final isCurrent = index == currentIdx;
        return Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _updateStatus(stages[index]),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primaryBlue
                        : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBlue,
                      width: isCurrent ? 6 : 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              if (index < stages.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIdx
                        ? AppColors.primaryBlue
                        : AppColors.divider,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (label == 'ASSIGNEE')
            _buildAssigneeContent(value as String?)
          else
            _buildDateContent(value as DateTime?),
        ],
      ),
    );
  }

  Widget _buildAssigneeContent(String? uid) {
    if (uid == null)
      return const Text('None', style: TextStyle(fontWeight: FontWeight.bold));
    return BlocProvider(
      create: (context) => ProfileCubit(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
        getAllUsersUseCase: sl(),
      )..getProfile(uid),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            return Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: ImageHelper.getProvider(
                    state.profile.photoUrl ?? '',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.profile.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }
          return const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      ),
    );
  }

  Widget _buildDateContent(DateTime? date) {
    if (date == null)
      return const Text(
        'Not set',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    return Row(
      children: [
        const Icon(
          Icons.calendar_today,
          size: 16,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat('MMM dd').format(date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCommentBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.white,
      child: SafeArea(
        child: Row(
          children: [
            const Icon(Icons.attach_file, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _addComment,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: TaskStatus.values.map((s) {
              return ListTile(
                leading: TaskStatusBadge(status: s),
                title: Text(s.name.toUpperCase()),
                trailing: _currentTask.status == s
                    ? const Icon(Icons.check, color: AppColors.primaryBlue)
                    : null,
                onTap: () {
                  _updateStatus(s);
                  context.pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _updateStatus(TaskStatus status) {
    setState(() => _currentTask = _currentTask.copyWith(status: status));
    context.read<TasksCubit>().updateTaskStatus(
      _currentTask.id,
      status,
      _currentTask,
    );
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final comment = TaskCommentEntity(
      id: '',
      authorId: userId,
      text: _commentController.text,
      createdAt: DateTime.now(),
    );
    context.read<TasksCubit>().addComment(_currentTask.id, comment);
  }

  void _showOptionsMenu() {
    // Edit / Delete logic
  }
}

extension on TaskEntity {
  TaskEntity copyWith({TaskStatus? status}) {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      teamId: teamId,
      teamName: teamName,
      assigneeIds: assigneeIds,
      creatorId: creatorId,
      priority: priority,
      status: status ?? this.status,
      startDate: startDate,
      dueDate: dueDate,
      isRecurring: isRecurring,
      isDraft: isDraft,
      comments: comments,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
