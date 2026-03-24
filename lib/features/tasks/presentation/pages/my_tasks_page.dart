import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/core/helpers/progress_helper.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/task_card.dart';
import '../widgets/velocity_stat_card.dart';
import '../../../teams/presentation/cubit/team_cubit.dart';
import '../../../teams/presentation/cubit/team_state.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All Tasks', 'To Do', 'In Progress', 'Review', 'Done'];
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
      context.read<TasksCubit>().loadTasksForTeams(teamIds);
    } else {
      context.read<TeamsCubit>().getTeams(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskEntity>? _lastTasks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), //slate-50
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
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
                'My Tasks',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: Color(0xFF1E293B),
                  letterSpacing: -1,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: const Color(0xFF64748B),
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
          IconButton(
            icon: Icon(
              Icons.tune,
              color: _selectedPriority != null
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
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
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
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
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tab,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
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
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
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
            final teamIds = state.teams.map((t) => t.id).toList();
            context.read<TasksCubit>().loadTasksForTeams(teamIds);
          }
        },
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            if (state is TasksLoaded) _lastTasks = state.tasks;

            if (state is TasksLoading && _lastTasks == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              );
            }

            if (_lastTasks != null) {
              final filteredTasks = _filterTasks(_lastTasks!);
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildStats(_lastTasks!),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/create'),
        backgroundColor: const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  List<Widget> _buildGroupedTasks(List<TaskEntity> tasks) {
    if (tasks.isEmpty) return [const Center(child: Text('No tasks found.'))];

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
          key = 'Today';
        } else if (taskDate == tomorrow) {
          key = 'Tomorrow';
        } else {
          key = DateFormat('MMM d').format(task.dueDate!);
        }
      }
      grouped.putIfAbsent(key, () => []).add(task);
    }

    final List<Widget> widgets = [];
    final sortedKeys = grouped.keys.toList(); // Simplified sorting for now

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
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${grouped[key]!.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const Spacer(),
              if (key == 'Today' || key == 'Tomorrow')
                Text(
                  DateFormat('MMM d').format(grouped[key]!.first.dueDate!),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
                    color: Color(0xFF64748B),
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
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Tasks',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.assignment_late_rounded,
                          color: Color(0xFFF97316),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$highPriority High Priority',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
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

    // 1. Tab filter
    final selectedTab = _tabs[_tabController.index];
    if (selectedTab != 'All Tasks') {
      filtered = filtered.where(
        (t) =>
            t.status.name.toLowerCase() ==
            selectedTab.replaceAll(' ', '').toLowerCase(),
      );
    }

    // 2. Search query filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where(
        (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()),
      );
    }

    // 3. Priority filter
    if (_selectedPriority != null) {
      filtered = filtered.where((t) => t.priority == _selectedPriority);
    }

    return filtered.toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildFilterChip(null, 'All', setSheetState),
                      _buildFilterChip(TaskPriority.high, 'High', setSheetState),
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
      selectedColor: const Color(0xFF2563EB),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF64748B),
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Returns the number of tasks matching the given [tab] filter.
  int _getCountForTab(String tab) {
    if (_lastTasks == null) return 0;
    if (tab == 'All Tasks') return _lastTasks!.length;
    return _lastTasks!
        .where(
          (t) =>
              t.status.name.toLowerCase() ==
              tab.replaceAll(' ', '').toLowerCase(),
        )
        .toList()
        .length;
  }
}
