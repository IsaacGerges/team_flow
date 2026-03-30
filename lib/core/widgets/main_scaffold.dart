import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';

/// Root scaffold that hosts the bottom navigation bar.
class MainScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.slate800.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 14, bottom: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              iconOutlined: Icons.grid_view_rounded,
              iconFilled: Icons.grid_view_rounded,
              label: AppStrings.homeNav,
              isActive: navigationShell.currentIndex == 0,
              onTap: () => _onTap(0),
            ),
            _NavBarItem(
              iconOutlined: Icons.groups_rounded,
              iconFilled: Icons.groups_rounded,
              label: AppStrings.teamsNav,
              isActive: navigationShell.currentIndex == 1,
              onTap: () => _onTap(1),
            ),
            _NavBarItem(
              iconOutlined: Icons.assignment_rounded,
              iconFilled: Icons.assignment_rounded,
              label: AppStrings.tasksNav,
              isActive: navigationShell.currentIndex == 2,
              onTap: () => _onTap(2),
            ),
            _NavBarItem(
              iconOutlined: Icons.person,
              iconFilled: Icons.person,
              label: AppStrings.profileNav,
              isActive: navigationShell.currentIndex == 3,
              onTap: () => _onTap(3),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.iconOutlined,
    required this.iconFilled,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryBlue.withValues(alpha: 0.08)
                  : AppColors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isActive ? iconFilled : iconOutlined,
              color: isActive ? AppColors.primaryBlue : AppColors.slate400,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              color: isActive ? AppColors.primaryBlue : AppColors.slate400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
