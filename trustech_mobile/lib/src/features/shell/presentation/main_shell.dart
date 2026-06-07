import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';

/// Hosts the 5 bottom-nav tabs as a `StatefulShellRoute.indexedStack`, so each
/// tab keeps its own navigation stack and scroll state. The bottom bar is the
/// app's primary navigation; detail/secondary screens are pushed full-screen on
/// the root navigator (no bottom bar) by the router.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab returns it to its root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
