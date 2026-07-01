import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/shell/presentation/staff_drawer.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff. Tab root.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: const StaffDrawer(selectedRoute: '/profile'),
      appBar: AppHeaderBar.menu(
        title: 'Trustech Staff Pro',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Center(
            child: Column(
              children: [
                const TrustechAvatar(name: 'Marcus Wright', radius: 48),
                const SizedBox(height: 12),
                Text('Marcus Wright',
                    style: TrustechTypography.h1.copyWith(color: cs.onSurface)),
                const SizedBox(height: 2),
                Text('marcus.wright@trustech.edu',
                    style: TrustechTypography.bodySmall
                        .copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    RoleBadge(label: 'Senior Educator'),
                    StatusChip(label: 'Math Dept', kind: StatusKind.neutral),
                    StatusChip(label: '+1 (555) 012-3456', kind: StatusKind.info),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TrustechButton(
            label: 'Edit Profile',
            icon: Icons.edit_outlined,
            onPressed: () {},
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Personal Information'),
          const SizedBox(height: 4),
          const InfoListCard(
            children: [
              InfoListRow(title: 'Staff ID', subtitle: '8842', icon: Icons.badge_outlined),
              InfoListRow(title: 'Department', subtitle: 'Academics', icon: Icons.account_tree_outlined),
              InfoListRow(title: 'Role', subtitle: 'Senior Educator', icon: Icons.workspace_premium_outlined),
              InfoListRow(title: 'Specialization', subtitle: 'Advanced Calculus & Statistical Analysis', icon: Icons.functions_outlined),
            ],
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Contact Details'),
          const SizedBox(height: 4),
          const InfoListCard(
            children: [
              InfoListRow(title: 'Work Email', subtitle: 'marcus.wright@trustech.edu', icon: Icons.mail_outline),
              InfoListRow(title: 'Mobile Number', subtitle: '+1 (555) 012-3456', icon: Icons.call_outlined),
              InfoListRow(title: 'Office Location', subtitle: 'Building C, Room 402', icon: Icons.location_on_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.calendar_month_outlined,
                  label: 'Schedule',
                  value: 'View',
                  onTap: () => context.push('/courses'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.folder_outlined,
                  label: 'Documents',
                  value: 'Open',
                  accent: cs.secondary,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
