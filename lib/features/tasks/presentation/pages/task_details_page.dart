import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:team_flow/injection_container.dart';
import 'package:team_flow/core/usecases/get_current_user_id_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:team_flow/features/profile/presentation/cubit/profile_state.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';
import 'package:team_flow/features/tasks/presentation/create_task_page_args.dart';
import 'package:team_flow/features/tasks/presentation/widgets/task_status_badge.dart';

class TaskDetailsPage extends StatefulWidget {
  final TaskEntity task;
  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final _commentController = TextEditingController();
  late TaskEntity _currentTask;
  bool _isDirty = false;
  bool _isSaving = false;

  String get _currentUserId => sl<GetCurrentUserIdUseCase>()() ?? '';
  bool get _isAdmin => _currentUserId == _currentTask.creatorId;

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
        if (state is TasksError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 32),
                    _buildProgressCard(),
                    const SizedBox(height: 32),
                    _buildDescriptionSection(),
                    const SizedBox(height: 32),
                    _buildInfoRow(),
                    const SizedBox(height: 32),
                    _buildCommentsHeader(),
                    const SizedBox(height: 16),
                    _buildCommentsList(),
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.slate500,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: InkWell(
        onTap: _showStatusPicker,
        borderRadius: BorderRadius.circular(20),
        child: TaskStatusBadge(status: _currentTask.status),
      ),
      centerTitle: true,
      actions: [
        if (_isDirty)
          _isSaving
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveChanges,
                  child: const Text(
                    AppStrings.save,
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        if (_isAdmin)
          IconButton(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.slate500,
            ),
            onPressed: _showOptionsMenu,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderSection() {
    final (priorityLabel, priorityColor) = _getPriorityData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              priorityLabel,
              style: TextStyle(
                color: priorityColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _currentTask.title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.slate800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.groups_rounded,
                    color: AppColors.slate500,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentTask.teamName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Created ${DateFormat('MMM dd, yyyy').format(_currentTask.createdAt)}',
              style: const TextStyle(
                color: AppColors.slate400,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final double progress = _getProgressValue();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate800.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.taskProgress,
                      style: TextStyle(
                        color: AppColors.slate800,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppStrings.onTrackForDelivery,
                      style: TextStyle(
                        color: AppColors.slate500,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor: AppColors.slate100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStageTracker(),
        ],
      ),
    );
  }

  Widget _buildStageTracker() {
    final stages = [
      TaskStatus.todo,
      TaskStatus.inProgress,
      TaskStatus.review,
      TaskStatus.done,
    ];
    final stageLabels = ['To Do', 'Doing', 'Review', 'Done'];
    final currentIdx = stages.indexOf(_currentTask.status);

    return Row(
      children: List.generate(stages.length, (index) {
        final isCompleted = index < currentIdx;
        final isCurrent = index == currentIdx;
        final isActive = isCurrent || isCompleted;
        return Expanded(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _isAdmin ? () => _updateStatus(stages[index]) : null,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.primaryBlue
                            : isCurrent
                            ? AppColors.blueBg
                            : AppColors.slate100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? AppColors.primaryBlue
                              : AppColors.slate300,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: AppColors.white,
                            )
                          : isCurrent
                          ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stageLabels[index],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? AppColors.primaryBlue : AppColors.slate400,
                    ),
                  ),
                ],
              ),
              if (index < stages.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: index < currentIdx
                          ? AppColors.primaryBlue
                          : AppColors.slate200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.description,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.slate500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate100),
          ),
          child: Text(
            _currentTask.description.isEmpty
                ? AppStrings.noDescriptionProvided
                : _currentTask.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.slate600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            AppStrings.assignee,
            _currentTask.assigneeIds.isNotEmpty
                ? _currentTask.assigneeIds.first
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoCard('Due Date', _currentTask.dueDate)),
      ],
    );
  }

  Widget _buildInfoCard(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          if (label == AppStrings.assignee)
            _buildAssigneeContent(value as String?)
          else
            _buildDateContent(value as DateTime?),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 2),
                if (label == AppStrings.assignee)
                  _buildAssigneeName(value as String?)
                else
                  _buildDateText(value as DateTime?),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssigneeContent(String? uid) {
    if (uid == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.slate100,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_outline,
          color: AppColors.slate400,
          size: 18,
        ),
      );
    }
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..getProfile(uid),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            return Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: ImageHelper.getProvider(
                    state.profile.photoUrl ?? '',
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
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                ),
              ],
            );
          }
          return Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.slate100,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
      ),
    );
  }

  Widget _buildAssigneeName(String? uid) {
    if (uid == null) {
      return const Text(
        AppStrings.notAssigned,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.slate800,
        ),
      );
    }
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return Text(
            state.profile.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.slate800,
            ),
            overflow: TextOverflow.ellipsis,
          );
        }
        return const SizedBox(height: 16);
      },
    );
  }

  Widget _buildDateContent(DateTime? date) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.blueBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.calendar_month_rounded,
        size: 18,
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildDateText(DateTime? date) {
    if (date == null) {
      return const Text(
        AppStrings.notSet,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.slate800,
        ),
      );
    }
    return Text(
      DateFormat('MMM dd').format(date),
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.slate800,
      ),
    );
  }

  Widget _buildCommentsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          AppStrings.activitySection,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.slate500,
            letterSpacing: 0.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.blueBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            AppStrings.activityBadgeNew,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .doc(_currentTask.id)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.slate200,
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.slate300,
                  size: 40,
                ),
                SizedBox(height: 12),
                Text(
                  AppStrings.noCommentsYet,
                  style: TextStyle(
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _CommentTile(
              authorId: data['authorId'] as String? ?? '',
              text: data['text'] as String? ?? '',
              createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCommentBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: AppColors.slate200)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    hintText: AppStrings.addComment,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.slate400,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _addComment,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker() {
    if (!_isAdmin) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                AppStrings.updateStatus,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(height: 16),
              ...TaskStatus.values.map((s) {
                final isSelected = _currentTask.status == s;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: TaskStatusBadge(status: s),
                  title: Text(
                    s.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.slate500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryBlue,
                        )
                      : null,
                  onTap: () {
                    _updateStatus(s);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _updateStatus(TaskStatus status) {
    if (!_isAdmin || _currentTask.status == status) return;
    setState(() {
      _currentTask = _currentTask.copyWith(status: status);
      _isDirty = true;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final success = await context.read<TasksCubit>().updateTask(
      _currentTask.id,
      _currentTask,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (success) _isDirty = false;
    });
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.changesSaved),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final comment = TaskCommentEntity(
      id: '',
      authorId: _currentUserId,
      text: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );
    final success = await context.read<TasksCubit>().addComment(
      _currentTask.id,
      comment,
    );
    if (success && mounted) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showOptionsMenu() {
    if (!_isAdmin) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primaryBlue,
                ),
                title: const Text(
                  AppStrings.editTask,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _editTask();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.red500,
                ),
                title: const Text(
                  AppStrings.deleteTask,
                  style: TextStyle(
                    color: AppColors.red500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteTask();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editTask() async {
    final updatedTask = await context.push(
      '/tasks/create',
      extra: CreateTaskPageArgs(activeTaskToEdit: _currentTask),
    );

    if (updatedTask != null && updatedTask is TaskEntity && mounted) {
      setState(() {
        _currentTask = updatedTask;
      });
    }
  }

  void _confirmDeleteTask() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          AppStrings.deleteTask,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(AppStrings.deleteTaskConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _deleteTask();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red500,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask() async {
    final success = await context.read<TasksCubit>().deleteTask(
      _currentTask.id,
    );
    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.taskDeleted),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  (String, Color) _getPriorityData() {
    return switch (_currentTask.priority) {
      TaskPriority.high => (AppStrings.highPriority, AppColors.red500),
      TaskPriority.medium => (AppStrings.mediumPriority, AppColors.notificationAmber),
      TaskPriority.low => (AppStrings.lowPriority, AppColors.onlineStatus),
    };
  }

  double _getProgressValue() {
    return switch (_currentTask.status) {
      TaskStatus.todo => 0.25,
      TaskStatus.inProgress => 0.50,
      TaskStatus.review => 0.75,
      TaskStatus.done => 1.0,
    };
  }
}

class _CommentTile extends StatelessWidget {
  final String authorId;
  final String text;
  final DateTime? createdAt;
  const _CommentTile({
    required this.authorId,
    required this.text,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthorAvatar(authorId: authorId),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: AppColors.slate100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _AuthorName(authorId: authorId),
                      if (createdAt != null)
                        Text(
                          _formatTime(createdAt!),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.slate400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM dd').format(dt);
  }
}

class _AuthorAvatar extends StatelessWidget {
  final String authorId;
  const _AuthorAvatar({required this.authorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..getProfile(authorId),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            return CircleAvatar(
              radius: 16,
              backgroundImage: ImageHelper.getProvider(
                state.profile.photoUrl ?? '',
              ),
            );
          }
          return Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.slate100,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}

class _AuthorName extends StatelessWidget {
  final String authorId;
  const _AuthorName({required this.authorId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return Text(
            state.profile.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.slate800,
            ),
          );
        }
        return const SizedBox(height: 16);
      },
    );
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
