// Roles: ADMIN (ADMIN: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/admin/providers/admin_providers.dart';

class RolesPermissionsScreen extends ConsumerWidget {
  const RolesPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Roles & Permissions'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Roles & Permissions', style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface)),
            const SizedBox(height: 8),
            Text('Manage system access roles and associated permissions.', style: TrustechTypography.bodyLarge.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: roles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final role = roles[index];
                return TrustechCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(role.name, style: TrustechTypography.h3.copyWith(color: cs.primary)),
                          ),
                          StatusChip(label: role.category.toUpperCase(), kind: StatusKind.info),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${role.userCount} users', style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: role.permissions
                            .map((p) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: BorderRadius.circular(4)),
                                  child: Text(p, style: TrustechTypography.caption),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            TrustechButton(
              label: 'Create New System Role',
              icon: Icons.add,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
