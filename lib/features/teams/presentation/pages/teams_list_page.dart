import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/features/teams/presentation/widgets/team_card.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:team_flow/features/tasks/presentation/cubit/task_state.dart';
import 'package:team_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:team_flow/core/helpers/progress_helper.dart';

class TeamsListPage extends StatefulWidget {
  const TeamsListPage({super.key});

  @override
  State<TeamsListPage> createState() => _TeamsListPageState();
}

class _TeamsListPageState extends State<TeamsListPage> {
  bool _isSearching = false;
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    context.read<TeamsCubit>().getTeams(userId);
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF2B6CEE);

    return BlocListener<TeamsCubit, TeamsState>(
      listener: (context, state) {
        if (state is TeamDeletedSuccess) {
          _showSnackBar(
            context,
            'Team removed successfully',
            AppColors.success,
          );
        } else if (state is TeamsError) {
          _showSnackBar(context, state.message, AppColors.error);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F8),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<TeamsCubit, TeamsState>(
                  builder: (context, state) {
                    if (state is TeamsLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryBlue),
                      );
                    }
                    if (state is TeamsLoaded) {
                      if (state.teams.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildTeamsList(state.teams);
                    }
                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => context.push('/teams/create'),
            backgroundColor: primaryBlue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8).withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: Color(0x1A2B6CEE))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _isSearching
                  ? Expanded(
                      child: Container(
                        height: 70,
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Search teams...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0F172A),
                          ),
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                        ),
                      ),
                    )
                  : const Text(
                      'My Teams',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
              Row(
                children: [
                  _buildHeaderAction(
                    _isSearching ? Icons.close : Icons.search,
                    onTap: () {
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
                  _buildHeaderAction(
                    Icons.filter_list,
                    onTap: () => _showFilterSheet(),
                    color: _selectedCategory != null
                        ? const Color(0xFF2B6CEE)
                        : const Color(0xFF475569),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(
    IconData icon, {
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color ?? const Color(0xFF475569), size: 24),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    final teamsState = context.read<TeamsCubit>().state;
    if (teamsState is! TeamsLoaded) return;

    final categories = teamsState.teams
        .map((t) => t.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

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
                    'Filter by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildFilterChip(null, 'All', setSheetState),
                      ...categories.map(
                        (cat) => _buildFilterChip(cat, cat, setSheetState),
                      ),
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
    String? category,
    String label,
    StateSetter setSheetState,
  ) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedCategory = category);
        setSheetState(() {});
        Navigator.pop(context);
      },
      selectedColor: const Color(0xFF2B6CEE),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF475569),
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildTeamsList(List<TeamEntity> teams) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final filteredTeams = teams.where((team) {
      final matchesSearch = team.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == null || team.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filteredTeams.isEmpty) return _buildEmptyState();

    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, tasksState) {
        List<TaskEntity> allTasks = [];
        if (tasksState is TasksLoaded) {
          allTasks = tasksState.tasks;
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: filteredTeams.length,
          itemBuilder: (context, index) {
            final team = filteredTeams[index];

            final teamTasks = allTasks
                .where((t) => t.teamId == team.id)
                .toList();
            final activeCount = teamTasks
                .where((t) => t.status != TaskStatus.done)
                .length;
            final progress = ProgressHelper.calculateTasksProgress(teamTasks);

            return TeamCard(
              team: team,
              isAdmin: team.adminId == currentUserId,
              activeTaskCount: activeCount,
              progressPercent: progress,
              onTap: () => context.push('/teams/details', extra: team),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final primaryBlue = const Color(0xFF2B6CEE);
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                        style: BorderStyle.none,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.groups,
                        size: 64,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  // Dashed circle decoration (simplified as Border)
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'No teams yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "You aren't part of any team yet. Create one to get started collaborating.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.push('/teams/create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Create Team',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
