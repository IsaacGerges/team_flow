import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_strings.dart';

class MainScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withValues(alpha: 0.08),
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
              hasBadge: true,
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
  final bool hasBadge;

  const _NavBarItem({
    required this.iconOutlined,
    required this.iconFilled,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF2563EB);
    final inactiveColor = const Color(0xFF94A3B8);

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
                  ? activeColor.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? iconFilled : iconOutlined,
                  color: isActive ? activeColor : inactiveColor,
                  size: 24,
                ),
                // if (hasBadge)
                //   Positioned(
                //     top: -2,
                //     right: -2,
                //     child: Container(
                //       width: 10,
                //       height: 10,
                //       decoration: BoxDecoration(
                //         color: const Color(0xFFEF4444),
                //         shape: BoxShape.circle,
                //         border: Border.all(color: Colors.white, width: 2),
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              color: isActive ? activeColor : inactiveColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
