import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/core/helpers/progress_helper.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../create_task_page_args.dart';
import '../widgets/task_card.dart';
import '../widgets/velocity_stat_card.dart';
import '../../../teams/presentation/cubit/team_cubit.dart';
import '../../../teams/presentation/cubit/team_state.dart';

/// Page that displays the current user's tasks grouped by due date,
/// with filters for priority and status, and a dedicated Drafts tab.
class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'All Tasks',
    'To Do',
    'In Progress',
    'Review',
    'Done',
    AppStrings.drafts,
  ];

  bool _isSearching = false;
  String _searchQuery = '';
  TaskPriority? _selectedPriority;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTasksFromTeams();
    });
    _tabController.addListener(() {
      setState(() {});
    });
  }

  void _syncTasksFromTeams() {
    if (!mounted) return;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final teamsState = context.read<TeamsCubit>().state;
    if (teamsState is TeamsLoaded) {
      final teamIds = teamsState.teams.map((t) => t.id).toList();
      context.read<TasksCubit>().loadTasksForTeams(
        teamIds,
        viewerId: userId,
      );
    } else {
      context.read<TeamsCubit>().getTeams(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// All published tasks cached across state updates.
  List<TaskEntity>? _lastPublished;

  /// Creator-owned drafts cached across state updates.
  List<TaskEntity>? _lastDrafts;

  bool get _isDraftsTabActive =>
      _tabs[_tabController.index] == AppStrings.drafts;

  @override
  Widget build(BuildContext context) {
    final teamsState = context.watch<TeamsCubit>().state;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final canCreateTask = teamsState is TeamsLoaded &&
        currentUserId != null &&
        teamsState.teams.any((team) => team.adminId == currentUserId);

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.slate50,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
              )
            : const Text(
                AppStrings.myTasks,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: AppColors.slate800,
                  letterSpacing: -1,
                ),
              ),
        actions: [
          if (!_isDraftsTabActive)
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: AppColors.slate500,
              ),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
          if (!_isDraftsTabActive)
            IconButton(
              icon: Icon(
                Icons.tune,
                color: _selectedPriority != null
                    ? AppColors.primaryBlue
                    : AppColors.slate500,
              ),
              onPressed: () => _showFilterSheet(),
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              dividerColor: AppColors.transparent,
              indicatorColor: AppColors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              tabs: _tabs.map((tab) {
                final isSelected = _tabs[_tabController.index] == tab;
                final int badgeCount = _getCountForTab(tab);
                final bool hasBadge = badgeCount > 0;
                return Tab(
                  height: 44,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.slate200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tab,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.slate500,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (hasBadge && !isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.slate100,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.slate500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: BlocListener<TeamsCubit, TeamsState>(
        listener: (context, state) {
          if (state is TeamsLoaded) {
            final userId = FirebaseAuth.instance.currentUser!.uid;
            final teamIds = state.teams.map((t) => t.id).toList();
            context.read<TasksCubit>().loadTasksForTeams(
              teamIds,
              viewerId: userId,
            );
          }
        },
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            if (state is TasksLoaded) {
              _lastPublished = state.tasks.where((t) => !t.isDraft).toList();
              _lastDrafts = state.tasks.where((t) => t.isDraft).toList();
            }

            if (state is TasksLoading &&
                _lastPublished == null &&
                _lastDrafts == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            if (_isDraftsTabActive) {
              return _buildDraftsTab();
            }

            if (_lastPublished != null) {
              final filteredTasks = _filterTasks(_lastPublished!);
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildStats(_lastPublished!),
                  const SizedBox(height: 32),
                  ..._buildGroupedTasks(filteredTasks),
                  const SizedBox(height: 100),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: canCreateTask
          ? FloatingActionButton(
              heroTag: 'my_tasks_fab',
              onPressed: () => context.push('/tasks/create'),
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: const Icon(Icons.add, color: AppColors.white, size: 30),
            )
          : null,
    );
  }

  // ----------------------------------------------------------
  // Drafts tab
  // ----------------------------------------------------------

  Widget _buildDraftsTab() {
    final drafts = _lastDrafts ?? [];
    if (drafts.isEmpty) {
      return _buildDraftsEmptyState();
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...drafts.map(
          (draft) => TaskCard(
            task: draft,
            isDraftCard: true,
            onTap: () => context.push(
              '/tasks/create',
              extra: CreateTaskPageArgs(draftTask: draft),
            ),
            onCheckboxChanged: (_) {},
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDraftsEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                size: 36,
                color: AppColors.slate400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              AppStrings.noDraftsYet,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.noDraftsHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.slate500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Published tasks tab
  // ----------------------------------------------------------

  List<Widget> _buildGroupedTasks(List<TaskEntity> tasks) {
    if (tasks.isEmpty) {
      return [const Center(child: Text(AppStrings.noTasksFound))];
    }

    final Map<String, List<TaskEntity>> grouped = {};
    for (var task in tasks) {
      String key = 'Other';
      if (task.dueDate != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final taskDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );

        if (taskDate == today) {
          key = AppStrings.today;
        } else if (taskDate == tomorrow) {
          key = 'Tomorrow';
        } else {
          key = DateFormat('MMM d').format(task.dueDate!);
        }
      }
      grouped.putIfAbsent(key, () => []).add(task);
    }

    final List<Widget> widgets = [];
    final sortedKeys = grouped.keys.toList();

    for (var key in sortedKeys) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Text(
                key,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${grouped[key]!.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate500,
                  ),
                ),
              ),
              const Spacer(),
              if (key == AppStrings.today || key == 'Tomorrow')
                Text(
                  DateFormat('MMM d').format(grouped[key]!.first.dueDate!),
                  style: const TextStyle(
                    color: AppColors.slate400,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      );
      widgets.addAll(
        grouped[key]!.map(
          (task) => TaskCard(
            task: task,
            onTap: () => context.push('/tasks/details', extra: task),
            onCheckboxChanged: (val) {
              final newStatus = (val ?? false)
                  ? TaskStatus.done
                  : TaskStatus.todo;
              context.read<TasksCubit>().updateTaskStatus(
                task.id,
                newStatus,
                task,
              );
            },
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildStats(List<TaskEntity> tasks) {
    final velocity = ProgressHelper.calculateTasksProgress(tasks);
    final pending = tasks.where((t) => t.status != TaskStatus.done).length;
    final highPriority = tasks
        .where((t) => t.priority == TaskPriority.high)
        .length;

    return Row(
      children: [
        Expanded(
          child: VelocityStatCard(velocityPercent: velocity, trend: 12.0),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PENDING',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$pending',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.slate800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Tasks',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.assignment_late_rounded,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$highPriority High Priority',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<TaskEntity> _filterTasks(List<TaskEntity> tasks) {
    Iterable<TaskEntity> filtered = tasks;

    final selectedTab = _tabs[_tabController.index];
    if (selectedTab != 'All Tasks' && selectedTab != AppStrings.drafts) {
      filtered = filtered.where(
        (t) =>
            t.status.name.toLowerCase() ==
            selectedTab.replaceAll(' ', '').toLowerCase(),
      );
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where(
        (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()),
      );
    }

    if (_selectedPriority != null) {
      filtered = filtered.where((t) => t.priority == _selectedPriority);
    }

    return filtered.toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Priority',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildFilterChip(null, 'All', setSheetState),
                      _buildFilterChip(
                        TaskPriority.high,
                        'High',
                        setSheetState,
                      ),
                      _buildFilterChip(
                        TaskPriority.medium,
                        'Medium',
                        setSheetState,
                      ),
                      _buildFilterChip(TaskPriority.low, 'Low', setSheetState),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(
    TaskPriority? priority,
    String label,
    StateSetter setSheetState,
  ) {
    final isSelected = _selectedPriority == priority;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedPriority = priority);
        setSheetState(() {});
        Navigator.pop(context);
      },
      selectedColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.slate500,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  int _getCountForTab(String tab) {
    if (tab == AppStrings.drafts) return _lastDrafts?.length ?? 0;
    if (_lastPublished == null) return 0;
    if (tab == 'All Tasks') return _lastPublished!.length;
    return _lastPublished!
        .where(
          (t) =>
              t.status.name.toLowerCase() ==
              tab.replaceAll(' ', '').toLowerCase(),
        )
        .length;
  }
}
