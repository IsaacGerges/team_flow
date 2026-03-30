import 'package:flutter/material.dart';
import 'package:team_flow/injection_container.dart';
import 'package:team_flow/core/usecases/get_current_user_id_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../teams/domain/entities/team_entity.dart';
import '../../../teams/presentation/cubit/team_cubit.dart';
import '../../../teams/presentation/cubit/team_state.dart';
import '../../domain/entities/task_entity.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';
import 'package:team_flow/features/tasks/presentation/create_task_page_args.dart';
import 'package:team_flow/features/tasks/presentation/widgets/assignee_chip_row.dart';
import 'package:team_flow/features/tasks/presentation/widgets/priority_selector.dart';

/// A form page for creating a new task or editing/publishing an existing draft.
///
/// Behaviour depends on [args]:
/// - `args == null` or `args.draftTask == null` → new-task mode.
/// - `args.draftTask != null` → edit-draft mode: fields are pre-filled and
///   the primary button becomes "Publish Task".
/// - `args.presetTeam != null` → pre-selects a team (used from Team Details).
class CreateTaskPage extends StatefulWidget {
  final CreateTaskPageArgs? args;

  const CreateTaskPage({super.key, this.args});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TeamEntity? _selectedTeam;
  List<String> _assigneeIds = [];
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _startDate;
  DateTime? _dueDate;
  bool _isRecurring = false;

  bool get _isEditingDraft => widget.args?.draftTask != null;
  bool get _isEditingActiveTask => widget.args?.activeTaskToEdit != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teamsState = context.read<TeamsCubit>().state;
      if (teamsState is! TeamsLoaded) {
        final userId = sl<GetCurrentUserIdUseCase>()() ?? '';
        context.read<TeamsCubit>().getTeams(userId);
      }
      _prefillFromArgs();
    });
  }

  /// Pre-fills all form fields from a draft or pre-selects a team.
  void _prefillFromArgs() {
    final taskToEdit = widget.args?.draftTask ?? widget.args?.activeTaskToEdit;
    if (taskToEdit != null) {
      _titleController.text = taskToEdit.title;
      _descriptionController.text = taskToEdit.description;
      _assigneeIds = List<String>.from(taskToEdit.assigneeIds);
      _priority = taskToEdit.priority;
      _startDate = taskToEdit.startDate;
      _dueDate = taskToEdit.dueDate;
      _isRecurring = taskToEdit.isRecurring;

      final teamsState = context.read<TeamsCubit>().state;
      if (teamsState is TeamsLoaded) {
        _selectedTeam = teamsState.teams.where((t) => t.id == taskToEdit.teamId).firstOrNull;
      }
      setState(() {});
      return;
    }

    final presetTeam = widget.args?.presetTeam;
    if (presetTeam != null) {
      setState(() => _selectedTeam = presetTeam);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = sl<GetCurrentUserIdUseCase>()();

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
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(
                color: AppColors.slate500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          leadingWidth: 80,
          title: Text(
            _isEditingActiveTask
                ? AppStrings.editTask
                : _isEditingDraft
                    ? AppStrings.editDraft
                    : AppStrings.newTask,
            style: const TextStyle(
              color: AppColors.slate800,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate800,
                  letterSpacing: -1,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.taskTitle,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.slate200, width: 2),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryBlue,
                      width: 2,
                    ),
                  ),
                  hintStyle: const TextStyle(
                    color: AppColors.slate300,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate800,
                  ),
                  decoration: const InputDecoration(
                    hintText: AppStrings.addDescription,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: AppColors.slate400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(AppStrings.projectTeamLabel),
              BlocBuilder<TeamsCubit, TeamsState>(
                builder: (context, state) {
                  final teams = state is TeamsLoaded
                      ? state.teams
                      : <TeamEntity>[];
                  final adminTeams = _filterAdminTeams(teams, currentUserId);

                  if (_selectedTeam != null &&
                      adminTeams.every(
                        (team) => team.id != _selectedTeam!.id,
                      )) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _selectedTeam = null);
                      }
                    });
                  }

                  return GestureDetector(
                    onTap: adminTeams.isEmpty
                        ? null
                        : () => _showTeamPicker(adminTeams),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.folder_open_rounded,
                              color: AppColors.primaryBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedTeam?.name ??
                                      (adminTeams.isEmpty
                                          ? AppStrings.noAdminTeamAvailable
                                          : AppStrings.selectProject),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: _selectedTeam != null
                                        ? AppColors.slate800
                                        : AppColors.slate400,
                                  ),
                                ),
                                if (_selectedTeam != null)
                                  Text(
                                    _selectedTeam!.category,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                if (_selectedTeam == null &&
                                    adminTeams.isEmpty)
                                  const Text(
                                    'Only team admins can create tasks.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.expand_more,
                            color: AppColors.slate400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(AppStrings.assignToLabel),
              AssigneeChipRow(
                assigneeIds: _assigneeIds,
                onAddTap: _openAssignmentPage,
                onRemoveTag: (uid) => setState(() => _assigneeIds.remove(uid)),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(AppStrings.priorityLabel),
              PrioritySelector(
                selectedPriority: _priority,
                onPriorityChanged: (p) => setState(() => _priority = p),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildDateRow(
                      AppStrings.startDate,
                      _startDate,
                      Icons.calendar_today_rounded,
                      AppColors.primaryBlue,
                      () => _pickDate(true),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: AppColors.slate200),
                    ),
                    _buildDateRow(
                      'Due Date',
                      _dueDate,
                      Icons.calendar_month_rounded,
                      AppColors.red500,
                      () => _pickDate(false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.recurringTask,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800,
                    ),
                  ),
                  Switch(
                    value: _isRecurring,
                    onChanged: (val) => setState(() => _isRecurring = val),
                    activeThumbColor: AppColors.primaryBlue,
                    activeTrackColor: AppColors.primaryBlue.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              if (_isEditingActiveTask)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveActiveTaskChanges,
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
                      AppStrings.saveChanges,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isEditingDraft
                            ? _saveDraftChanges
                            : () => _createOrSaveDraft(isDraft: true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.slate200),
                          ),
                        ),
                        child: Text(
                          _isEditingDraft
                              ? AppStrings.saveDraftChanges
                              : AppStrings.saveDraft,
                          style: const TextStyle(
                            color: AppColors.slate800,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isEditingDraft
                            ? _publishDraft
                            : () => _createOrSaveDraft(isDraft: false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primaryBlue.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _isEditingDraft
                                  ? AppStrings.publishTask
                                  : AppStrings.createTask,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------

  List<TeamEntity> _filterAdminTeams(List<TeamEntity> teams, String? userId) {
    if (userId == null) return const [];
    return teams.where((team) => team.adminId == userId).toList();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.slate500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDateRow(
    String label,
    DateTime? date,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.slate800,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Text(
            date != null
                ? DateFormat('MMM dd, hh:mm a').format(date)
                : AppStrings.setDate,
            style: TextStyle(
              color: date != null ? AppColors.slate800 : AppColors.slate400,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showTeamPicker(List<TeamEntity> teams) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                AppStrings.selectTeam,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate800,
                ),
              ),
            ),
            ...teams.map((team) {
              return ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                title: Text(
                  team.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(team.category),
                trailing: _selectedTeam?.id == team.id
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlue,
                      )
                    : null,
                onTap: () {
                  setState(() => _selectedTeam = team);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _dueDate) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          (isStart ? _startDate : _dueDate) ?? DateTime.now(),
        ),
      );
      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() => isStart ? _startDate = dateTime : _dueDate = dateTime);
      }
    }
  }

  void _openAssignmentPage() async {
    if (_selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pleaseSelectTeamFirst)),
      );
      return;
    }
    final result = await context.push(
      '/tasks/assign',
      extra: {'teamId': _selectedTeam!.id, 'currentAssigneeIds': _assigneeIds},
    );
    if (result != null && result is List<String>) {
      setState(() => _assigneeIds = result);
    }
  }

  /// Validates title + team (required for both draft and publish).
  bool _validate() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.pleaseEnterTitle)));
      return false;
    }
    if (_selectedTeam == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.pleaseSelectTeam)));
      return false;
    }
    final userId = sl<GetCurrentUserIdUseCase>()() ?? '';
    if (_selectedTeam!.adminId != userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only the team admin can create tasks for this team'),
        ),
      );
      return false;
    }
    return true;
  }

  TaskEntity _buildTaskEntity({
    required String userId,
    required bool isDraft,
    String id = '',
    DateTime? createdAt,
    TaskStatus? status,
  }) {
    final finalAssignees = List<String>.from(_assigneeIds);
    if (!finalAssignees.contains(userId)) finalAssignees.add(userId);
    return TaskEntity(
      id: id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      teamId: _selectedTeam!.id,
      teamName: _selectedTeam!.name,
      assigneeIds: finalAssignees,
      creatorId: userId,
      priority: _priority,
      status: status ?? TaskStatus.todo,
      startDate: _startDate,
      dueDate: _dueDate,
      isRecurring: _isRecurring,
      isDraft: isDraft,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Used in new-task mode: creates a brand-new doc (draft or published).
  void _createOrSaveDraft({required bool isDraft}) async {
    if (!_validate()) return;
    final userId = sl<GetCurrentUserIdUseCase>()() ?? '';
    final task = _buildTaskEntity(userId: userId, isDraft: isDraft);
    final taskId = await context.read<TasksCubit>().createTask(task);
    if (taskId != null && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDraft
                ? AppStrings.taskSavedAsDraft
                : AppStrings.taskCreatedSuccess,
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Edit-draft mode: silently updates the existing draft doc.
  void _saveDraftChanges() async {
    if (!_validate()) return;
    final draft = widget.args!.draftTask!;
    final userId = sl<GetCurrentUserIdUseCase>()() ?? '';
    final updatedDraft = _buildTaskEntity(
      userId: userId,
      isDraft: true,
      id: draft.id,
      createdAt: draft.createdAt,
    );
    final success = await context
        .read<TasksCubit>()
        .updateTask(draft.id, updatedDraft);
    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.draftChangesSaved),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Edit-draft mode: publishes the draft (isDraft → false) and fires
  /// notifications.
  void _publishDraft() async {
    if (!_validate()) return;
    final draft = widget.args!.draftTask!;
    final userId = sl<GetCurrentUserIdUseCase>()() ?? '';
    final publishedTask = _buildTaskEntity(
      userId: userId,
      isDraft: false,
      id: draft.id,
      createdAt: draft.createdAt,
    );
    final success = await context
        .read<TasksCubit>()
        .publishDraft(draft.id, publishedTask);
    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.taskPublished),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Edit Active Task mode: saves the active task changes and fires notifications.
  void _saveActiveTaskChanges() async {
    if (!_validate()) return;
    final activeTask = widget.args!.activeTaskToEdit!;
    final userId = sl<GetCurrentUserIdUseCase>()() ?? '';
    final updatedTask = _buildTaskEntity(
      userId: userId,
      isDraft: false,
      id: activeTask.id,
      createdAt: activeTask.createdAt,
      status: activeTask.status,
    );
    final success = await context
        .read<TasksCubit>()
        .updateActiveTaskAndNotify(activeTask.id, updatedTask, updaterId: userId);
    if (success && mounted) {
      context.pop(updatedTask);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.changesSaved),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
