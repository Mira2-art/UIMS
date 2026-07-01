import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

/// Hosts the 4 bottom-nav tabs (Home · Workspace · Alerts · Profile) for the
/// authenticated staff app via [StatefulShellRoute.indexedStack]. Each tab keeps
/// its own navigation stack; module routes push inside the Workspace branch so
/// the bottom bar stays visible.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<AppNavItem> _items = [
    AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    AppNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Workspace',
    ),
    AppNavItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Alerts',
    ),
    AppNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        items: _items,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
