import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/auth/module_access.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/shell/presentation/staff_drawer.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff. Role-aware module hub (tab root). Grid adapts to moduleAccess.
class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final roles = ref.watch(currentRolesProvider);
    final sections = moduleAccessBySection(roles);

    return Scaffold(
      drawer: const StaffDrawer(selectedRoute: '/workspace'),
      appBar: AppHeaderBar.menu(
        title: 'Workspace',
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: TrustechAvatar(name: 'Marcus Webb', radius: 16),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/announcements/compose'),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
        children: [
          Text('Academic Workspace',
              style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface)),
          const SizedBox(height: 6),
          Text(
            'Hello Marcus — your central hub to manage courses, students, and institutional data.',
            style: TrustechTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          for (final section in sections.entries) ...[
            SectionHeader(title: section.key.label),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final m in section.value)
                  WorkspaceModuleCard(
                    title: m.title,
                    subtitle: m.subtitle,
                    icon: m.icon,
                    onTap: () => context.push(m.route),
                  ),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
