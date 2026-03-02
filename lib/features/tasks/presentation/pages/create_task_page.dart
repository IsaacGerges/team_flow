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
    final userId = FirebaseAuth.instance.currentUser!.uid;
    context.read<TeamsCubit>().getTeams(userId);
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
        if (state is TaskCreatedSuccess || state is TaskDraftSaved) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is TaskDraftSaved
                    ? 'Task saved as draft'
                    : 'Task created successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is TasksError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Create New Task',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Task Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textHint),
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Add a description...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.textHint),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('PROJECT / TEAM'),
              BlocBuilder<TeamsCubit, TeamsState>(
                builder: (context, state) {
                  List<TeamEntity> teams = [];
                  if (state is TeamsLoaded) {
                    teams = state.teams;
                  }
                  return DropdownButtonFormField<TeamEntity>(
                    value: _selectedTeam,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.group_work_outlined,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    hint: const Text('Select Team'),
                    items: teams.map((team) {
                      return DropdownMenuItem(
                        value: team,
                        child: Text(team.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTeam = val),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('ASSIGN TO'),
              AssigneeChipRow(
                assigneeIds: _assigneeIds,
                onAddTap: _openAssignmentPage,
                onRemoveTag: (uid) => setState(() => _assigneeIds.remove(uid)),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('PRIORITY'),
              PrioritySelector(
                selectedPriority: _priority,
                onPriorityChanged: (p) => setState(() => _priority = p),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      'START DATE',
                      _startDate,
                      (date) => setState(() => _startDate = date),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      'DUE DATE',
                      _dueDate,
                      (date) => setState(() => _dueDate = date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECURRING TASK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Switch(
                    value: _isRecurring,
                    onChanged: (val) => setState(() => _isRecurring = val),
                    activeColor: AppColors.primaryBlue,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _createTask(isDraft: true),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      child: const Text(
                        'Save Draft',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _createTask(isDraft: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create Task',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onChanged,
  ) {
    final displayDate = value != null
        ? DateFormat('MMM dd, yyyy').format(value)
        : 'Select';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  displayDate,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

  void _createTask({required bool isDraft}) {
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
    final task = TaskEntity(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      teamId: _selectedTeam!.id,
      teamName: _selectedTeam!.name,
      assigneeIds: _assigneeIds,
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

    context.read<TasksCubit>().createTask(task);
  }
}
