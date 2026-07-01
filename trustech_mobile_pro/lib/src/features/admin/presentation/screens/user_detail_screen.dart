// Roles: ADMIN (ADMIN: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/admin/providers/admin_providers.dart';
import 'package:trustech_mobile_pro/src/features/admin/data/mock/admin_mock.dart';

class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDetailProvider(userId));
    final cs = Theme.of(context).colorScheme;

    if (user == null) {
      return const TrustechScaffold(
        title: 'User Detail',
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'User Detail'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrustechCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TrustechAvatar(name: user.name, radius: 40),
                  const SizedBox(height: 16),
                  Text(user.name, style: TrustechTypography.h2.copyWith(color: cs.onSurface)),
                  Text(user.email, style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  StatusChip(label: user.status.label, kind: user.status == UserStatus.active ? StatusKind.success : StatusKind.error),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const SectionHeader(title: 'Account Information'),
            const SizedBox(height: 8),
            InfoListCard(
              children: [
                InfoListRow(title: 'Role', subtitle: user.role, icon: Icons.badge_outlined),
                InfoListRow(title: 'Last Active', subtitle: user.lastActive.toString().split(' ')[0], icon: Icons.schedule),
              ],
            ),
            const SizedBox(height: 24),
            
            // Actions
            if (user.status == UserStatus.active)
              TrustechButton(
                label: 'Suspend User',
                variant: TrustechButtonVariant.destructive,
                icon: Icons.block,
                onPressed: () {},
              )
            else
              TrustechButton(
                label: 'Activate User',
                icon: Icons.check_circle_outline,
                onPressed: () {},
              ),
          ],
        ),
      ),
    );
  }
}
