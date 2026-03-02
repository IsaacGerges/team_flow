import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/task_card.dart';
import '../widgets/velocity_stat_card.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All Tasks', 'To Do', 'In Progress', 'Done'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    context.read<TasksCubit>().loadMyTasks(userId);

    _tabController.addListener(() {
      setState(() {}); // Rebuild to filter list
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundScreen,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: _tabs.map((tab) {
                final isSelected = _tabs[_tabController.index] == tab;
                return Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }
          if (state is TasksError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
          if (state is TasksLoaded) {
            final filteredTasks = _filterTasks(state.tasks);
            if (filteredTasks.isEmpty) {
              return const Center(child: Text('No tasks found.'));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStats(state.tasks),
                const SizedBox(height: 24),
                const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...filteredTasks
                    .map(
                      (task) => TaskCard(
                        task: task,
                        onTap: () =>
                            context.push('/tasks/details', extra: task),
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
                    )
                    .toList(),
                const SizedBox(height: 80), // Space for FAB
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/create'),
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<TaskEntity> _filterTasks(List<TaskEntity> tasks) {
    final selectedTab = _tabs[_tabController.index];
    if (selectedTab == 'All Tasks') return tasks;
    if (selectedTab == 'To Do')
      return tasks.where((t) => t.status == TaskStatus.todo).toList();
    if (selectedTab == 'In Progress')
      return tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    if (selectedTab == 'Done')
      return tasks.where((t) => t.status == TaskStatus.done).toList();
    return tasks;
  }

  Widget _buildStats(List<TaskEntity> tasks) {
    final doneCount = tasks.where((t) => t.status == TaskStatus.done).length;
    final total = tasks.length;
    final velocity = total > 0 ? doneCount / total : 0.0;
    final pending = tasks.where((t) => t.status != TaskStatus.done).length;
    final highPriority = tasks
        .where((t) => t.priority == TaskPriority.high)
        .length;

    return Row(
      children: [
        Expanded(
          child: VelocityStatCard(
            velocityPercent: velocity,
            trend: 12.0, // Mocked trend
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'PENDING',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pending Tasks',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.priorityHigh,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$highPriority High Priority',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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
}
