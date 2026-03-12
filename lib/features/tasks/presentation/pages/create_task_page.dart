import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../teams/domain/entities/team_entity.dart';
import '../../../teams/presentation/cubit/team_cubit.dart';
import '../../../teams/presentation/cubit/team_state.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/assignee_chip_row.dart';
import '../widgets/priority_selector.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teamsState = context.read<TeamsCubit>().state;
      if (teamsState is! TeamsLoaded) {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        context.read<TeamsCubit>().getTeams(userId);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          leadingWidth: 80,
          title: const Text(
            'New Task',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFF2563EB),
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
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
                  color: Color(0xFF1E293B),
                  letterSpacing: -1,
                ),
                decoration: InputDecoration(
                  hintText: 'Task Title',
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 2),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                  hintStyle: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Add a description...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('PROJECT / TEAM'),
              BlocBuilder<TeamsCubit, TeamsState>(
                builder: (context, state) {
                  List<TeamEntity> teams = state is TeamsLoaded
                      ? state.teams
                      : [];
                  return GestureDetector(
                    onTap: () => _showTeamPicker(teams),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.folder_open_rounded,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedTeam?.name ?? 'Select Project...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: _selectedTeam != null
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                if (_selectedTeam != null)
                                  Text(
                                    _selectedTeam!.category,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.expand_more,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('ASSIGN TO'),
              AssigneeChipRow(
                assigneeIds: _assigneeIds,
                onAddTap: _openAssignmentPage,
                onRemoveTag: (uid) => setState(() => _assigneeIds.remove(uid)),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('PRIORITY'),
              PrioritySelector(
                selectedPriority: _priority,
                onPriorityChanged: (p) => setState(() => _priority = p),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildDateRow(
                      'Start Date',
                      _startDate,
                      Icons.calendar_today_rounded,
                      const Color(0xFF3B82F6),
                      () => _pickDate(true),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFFE2E8F0)),
                    ),
                    _buildDateRow(
                      'Due Date',
                      _dueDate,
                      Icons.calendar_month_rounded,
                      const Color(0xFFEF4444),
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
                    'Recurring Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Switch(
                    value: _isRecurring,
                    onChanged: (val) => setState(() => _isRecurring = val),
                    activeThumbColor: const Color(0xFF2563EB),
                    activeTrackColor: const Color(
                      0xFF2563EB,
                    ).withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _createTask(isDraft: true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: const Text(
                        'Save Draft',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _createTask(isDraft: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: const Color(
                          0xFF2563EB,
                        ).withValues(alpha: 0.3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Create Task',
                            style: TextStyle(
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Color(0xFF64748B),
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
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Text(
            date != null
                ? DateFormat('MMM dd, hh:mm a').format(date)
                : 'Set date',
            style: TextStyle(
              color: date != null
                  ? const Color(0xFF1E293B)
                  : const Color(0xFF94A3B8),
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
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
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
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Select Team',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            ...teams.map((team) {
              return ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                title: Text(
                  team.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(team.category),
                trailing: _selectedTeam?.id == team.id
                    ? const Icon(Icons.check_circle, color: Color(0xFF2563EB))
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
        const SnackBar(content: Text('Please select a team first')),
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

  void _createTask({required bool isDraft}) async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    if (_selectedTeam == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a team')));
      return;
    }
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final finalAssignees = List<String>.from(_assigneeIds);
    if (!finalAssignees.contains(userId)) finalAssignees.add(userId);

    final task = TaskEntity(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      teamId: _selectedTeam!.id,
      teamName: _selectedTeam!.name,
      assigneeIds: finalAssignees,
      creatorId: userId,
      priority: _priority,
      status: TaskStatus.todo,
      startDate: _startDate,
      dueDate: _dueDate,
      isRecurring: _isRecurring,
      isDraft: isDraft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final taskId = await context.read<TasksCubit>().createTask(task);
    if (taskId != null && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDraft ? 'Task saved as draft' : 'Task created successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
