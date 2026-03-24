import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isDirty = false;
  bool _isSaving = false;

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';
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
        backgroundColor: const Color(0xFFF6F6F8),
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
      backgroundColor: Colors.white.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF64748B),
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
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveChanges,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        if (_isAdmin)
          IconButton(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Color(0xFF64748B),
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
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.groups_rounded,
                    color: Color(0xFF64748B),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentTask.teamName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
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
                color: Color(0xFF94A3B8),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.03),
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
                      'Task Progress',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'On track for delivery',
                      style: TextStyle(
                        color: Color(0xFF64748B),
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
                      backgroundColor: const Color(0xFFEEF2F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
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
                            ? const Color(0xFF3B82F6)
                            : isCurrent
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: Colors.white,
                            )
                          : isCurrent
                          ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF3B82F6),
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
                      color: isActive
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF94A3B8),
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
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFE2E8F0),
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
          'DESCRIPTION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Text(
            _currentTask.description.isEmpty
                ? 'No description provided.'
                : _currentTask.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF475569),
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
            'Assignee',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          if (label == 'Assignee')
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
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                if (label == 'Assignee')
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
          color: Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_outline,
          color: Color(0xFF94A3B8),
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
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
              color: Color(0xFFF1F5F9),
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
        'Not assigned',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Color(0xFF1E293B),
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
              color: Color(0xFF1E293B),
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
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.calendar_month_rounded,
        size: 18,
        color: Color(0xFF2563EB),
      ),
    );
  }

  Widget _buildDateText(DateTime? date) {
    if (date == null) {
      return const Text(
        'Not set',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Color(0xFF1E293B),
        ),
      );
    }
    return Text(
      DateFormat('MMM dd').format(date),
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildCommentsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ACTIVITY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'New',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
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
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 40,
                ),
                SizedBox(height: 12),
                Text(
                  'No comments yet.',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
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
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  color: const Color(0xFFEEF2F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
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
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Update Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
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
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2563EB),
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
          content: Text('Changes saved successfully'),
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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF2563EB),
                ),
                title: const Text(
                  'Edit Task',
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
                  color: Color(0xFFEF4444),
                ),
                title: const Text(
                  'Delete Task',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
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

  void _editTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit task coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDeleteTask() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete Task',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text('Are you sure? This action cannot be undone.'),
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
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
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
          content: Text('Task deleted'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  (String, Color) _getPriorityData() {
    return switch (_currentTask.priority) {
      TaskPriority.high => ('High Priority', const Color(0xFFEF4444)),
      TaskPriority.medium => ('Medium Priority', const Color(0xFFF59E0B)),
      TaskPriority.low => ('Low Priority', const Color(0xFF22C55E)),
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
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
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
                            color: Color(0xFF94A3B8),
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
                      color: Color(0xFF475569),
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
    if (diff.inMinutes < 1) return 'Just now';
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
              color: Color(0xFFF1F5F9),
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
              color: Color(0xFF1E293B),
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
