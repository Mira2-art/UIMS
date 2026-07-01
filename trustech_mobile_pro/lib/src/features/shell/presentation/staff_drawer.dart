import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/auth/module_access.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

/// Role-gated navigation drawer (secondary / overflow nav per spec §6.2).
/// Lists every module the signed-in user can access, built from [moduleAccess].
class StaffDrawer extends ConsumerWidget {
  const StaffDrawer({super.key, this.selectedRoute});

  final String? selectedRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(currentRolesProvider);
    final modules = moduleAccess(roles);

    return AppDrawer(
      // TODO(backend:) real user identity + role badges.
      name: 'Marcus Webb',
      subtitle: 'Staff',
      email: 'm.webb@trustech.edu',
      avatarName: 'Marcus Webb',
      onHeaderTap: () {
        Navigator.of(context).pop();
        context.go('/profile');
      },
      items: [
        for (final m in modules)
          AppDrawerItem(
            icon: m.icon,
            label: m.title,
            selected: m.route == selectedRoute,
            onTap: () {
              Navigator.of(context).pop();
              context.push(m.route);
            },
          ),
      ],
      onSignOut: () {
        Navigator.of(context).pop();
        context.go('/welcome');
      },
    );
  }
}
