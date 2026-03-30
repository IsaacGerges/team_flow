import 'package:flutter/material.dart';
import 'package:team_flow/core/usecases/get_current_user_id_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/profile/domain/entities/profile_entity.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/features/teams/presentation/cubit/add_member_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/add_member_state.dart';
import 'package:team_flow/injection_container.dart';

/// Page for adding new members to a team.
///
/// Displays a list of suggested coworkers by default and allows
/// for a global search of all users in the system.
class AddMemberPage extends StatefulWidget {
  final TeamEntity team;

  const AddMemberPage({super.key, required this.team});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddMemberCubit>(
      create: (context) =>
          sl<AddMemberCubit>()
            ..init(sl<GetCurrentUserIdUseCase>()() ?? '', widget.team),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.slate800,
                  size: 18,
                ),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                AppStrings.addMembersTitle,
                style: TextStyle(
                  color: AppColors.slate800,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
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
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                } else if (state is TeamsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: _buildSearchBar(context),
                  ),
                  Expanded(child: _buildResultsList()),
                  if (_selectedIds.isNotEmpty) _buildBottomBar(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the search bar that triggers the Cubit's search logic.
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => context.read<AddMemberCubit>().search(val),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.slate800,
        ),
        decoration: const InputDecoration(
          hintText: AppStrings.searchByEmailOrName,
          hintStyle: TextStyle(
            color: AppColors.slate400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.slate400,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  /// Builds the list of users provided by the [AddMemberCubit].
  Widget _buildResultsList() {
    return BlocBuilder<AddMemberCubit, AddMemberState>(
      builder: (context, state) {
        if (state is AddMemberLoading || state is AddMemberInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        if (state is AddMemberError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        if (state is AddMemberLoaded) {
          final filteredUsers = state.filteredUsers;
          final isShowingCoworkers = state.isShowingCoworkers;

          if (filteredUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.slate50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_search_rounded,
                      size: 48,
                      color: AppColors.slate400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    AppStrings.noMembersFound,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate800,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: isShowingCoworkers
                ? filteredUsers.length + 1
                : filteredUsers.length,
            itemBuilder: (context, index) {
              if (isShowingCoworkers) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16, top: 8),
                    child: Text(
                      AppStrings.suggestedPeople,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.slate500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }
                final user = filteredUsers[index - 1];
                final isSelected = _selectedIds.contains(user.uid);
                return _buildMemberTile(user, isSelected);
              } else {
                final user = filteredUsers[index];
                final isSelected = _selectedIds.contains(user.uid);
                return _buildMemberTile(user, isSelected);
              }
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Builds a single user tile with selection capability.
  Widget _buildMemberTile(ProfileEntity user, bool isSelected) {
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;
    return GestureDetector(
      onTap: () => _toggleMember(user.uid),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueBg : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.slate200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: hasPhoto
                  ? ImageHelper.getProvider(user.photoUrl)
                  : null,
              backgroundColor: AppColors.slate100,
              child: !hasPhoto
                  ? Text(
                      user.fullName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryBlue : AppColors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.slate300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the bottom bar containing the selection summary and the "Add" button.
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.slate200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedIds.length} ${AppStrings.selected.toLowerCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate600,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIds.clear()),
                child: const Text(
                  AppStrings.clearAll,
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.read<TeamsCubit>().addMembers(
                widget.team.id,
                _selectedIds.toList(),
              ),
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
              child: Text(
                '${AppStrings.addMembersButton} "${widget.team.name}"',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
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
}
