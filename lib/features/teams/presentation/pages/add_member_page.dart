import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';

/// Screen for searching and adding members to a team.
class AddMemberPage extends StatefulWidget {
  final TeamEntity team;

  const AddMemberPage({super.key, required this.team});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  String _searchQuery = '';
  List<ProfileEntity> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await context.read<TeamsCubit>().getAllUsers();
    if (mounted) {
      setState(() {
        _allUsers = users;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundScreen,
        elevation: 0,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            AppStrings.cancel,
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        ),
        leadingWidth: 80,
        title: const Text(
          AppStrings.addMembersTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<TeamsCubit, TeamsState>(
        listener: (context, state) {
          if (state is TeamMemberAddedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.memberAdded),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is TeamsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SearchBar(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildResultsList(),
            ),
            if (_selectedIds.isNotEmpty)
              _BottomConfirmBar(
                team: widget.team,
                selectedIds: _selectedIds,
                onConfirm: () => _confirmAddMembers(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final filteredUsers = _allUsers.where((user) {
      // Exclude those already in the team
      if (widget.team.membersIds.contains(user.uid)) return false;

      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return user.fullName.toLowerCase().contains(q) ||
          user.email.toLowerCase().contains(q);
    }).toList();

    if (filteredUsers.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_searchQuery.isEmpty) ...[
          const _SectionHeader(
            label: AppStrings.suggestedPeople,
            trailing: 'RECENT',
          ),
          const SizedBox(height: 8),
        ],
        ...filteredUsers.map((user) {
          final isSelected = _selectedIds.contains(user.uid);
          return _MemberSelectionTile(
            user: user,
            isSelected: isSelected,
            onToggle: () => _toggleMember(user.uid),
          );
        }),
        const SizedBox(height: 100),
      ],
    );
  }

  void _toggleMember(String userId) {
    setState(() {
      if (_selectedIds.contains(userId)) {
        _selectedIds.remove(userId);
      } else {
        _selectedIds.add(userId);
      }
    });
  }

  void _confirmAddMembers(BuildContext context) {
    context.read<TeamsCubit>().addMembers(
      widget.team.id,
      _selectedIds.toList(),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: AppStrings.searchByEmailOrName,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String? trailing;

  const _SectionHeader({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
      ],
    );
  }
}

class _MemberSelectionTile extends StatelessWidget {
  final ProfileEntity user;
  final bool isSelected;
  final VoidCallback onToggle;

  const _MemberSelectionTile({
    required this.user,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: AppColors.primaryBlue, width: 2)
            : Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundImage: ImageHelper.getProvider(user.photoUrl),
          backgroundColor: AppColors.primaryBlue,
          child: (user.photoUrl == null || user.photoUrl!.isEmpty)
              ? Text(
                  user.fullName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          user.email,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: isSelected
            ? Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 16,
                ),
              )
            : Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lightGray, width: 2),
                ),
              ),
        onTap: onToggle,
      ),
    );
  }
}

class _BottomConfirmBar extends StatelessWidget {
  final TeamEntity team;
  final Set<String> selectedIds;
  final VoidCallback onConfirm;

  const _BottomConfirmBar({
    required this.team,
    required this.selectedIds,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Assigning ${selectedIds.length} member(s)',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: BlocBuilder<TeamsCubit, TeamsState>(
              builder: (context, state) {
                if (state is TeamsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Confirm Assignment (${selectedIds.length}) →',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
