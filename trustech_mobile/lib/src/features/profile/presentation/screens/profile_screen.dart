import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/ui_kit/ui_kit.dart';
import '../../../../shared/utils/theme_helper.dart';
import '../../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppHeaderBar.home(
        title: 'Profile',
        avatarName: profile.fullName,
        avatarUrl: profile.avatarUrl,
        onNotification: () => context.push('/notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identity Header Card
            _IdentityHeaderCard(
              name: profile.fullName,
              studentId: profile.studentId,
              major: profile.major,
              avatarUrl: profile.avatarUrl,
            ),
            const SizedBox(height: 24),

            // Personal Information
            const _SectionTitle(title: 'PERSONAL INFORMATION'),
            const SizedBox(height: 8),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Full Name',
                  subtitle: profile.fullName,
                  icon: Icons.person_outline,
                ),
                InfoListRow(
                  title: 'Email Address',
                  subtitle: profile.email,
                  icon: Icons.mail_outline,
                ),
                InfoListRow(
                  title: 'Phone Number',
                  subtitle: profile.phoneNumber,
                  icon: Icons.call_outlined,
                ),
                InfoListRow(
                  title: 'Birthday',
                  subtitle: DateFormat('MMMM dd, yyyy').format(profile.birthday),
                  icon: Icons.cake_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Academic Information
            const _SectionTitle(title: 'ACADEMIC INFORMATION'),
            const SizedBox(height: 8),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Academic Advisor',
                  subtitle: profile.academicAdvisor,
                  icon: Icons.supervisor_account_outlined,
                  iconAccent: cs.secondary,
                  showChevron: true,
                  onTap: () {},
                ),
                InfoListRow(
                  title: 'Enrollment Year',
                  subtitle: profile.enrollmentYear,
                  icon: Icons.calendar_today_outlined,
                  iconAccent: cs.secondary,
                ),
                InfoListRow(
                  title: 'Expected Graduation',
                  subtitle: profile.expectedGraduation,
                  icon: Icons.event_available_outlined,
                  iconAccent: cs.secondary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Support & Legal
            const _SectionTitle(title: 'SUPPORT & LEGAL'),
            const SizedBox(height: 8),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Help Center',
                  icon: Icons.help_outline,
                  trailing: Icon(Icons.open_in_new, size: 18, color: cs.outline),
                  onTap: () {},
                ),
                InfoListRow(
                  title: 'Terms of Service',
                  icon: Icons.gavel_outlined,
                  showChevron: true,
                  onTap: () {},
                ),
                InfoListRow(
                  title: 'Privacy Policy',
                  icon: Icons.lock_outline,
                  showChevron: true,
                  onTap: () {},
                ),
                InfoListRow(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  showChevron: true,
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Logout Action
            TrustechButton(
              label: 'Logout from Trustech',
              icon: Icons.logout,
              variant: TrustechButtonVariant.outline,
              onPressed: () {
                // TODO(backend): implement logout
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Version 2.4.1 (Stable Build)',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _IdentityHeaderCard extends StatelessWidget {
  const _IdentityHeaderCard({
    required this.name,
    required this.studentId,
    required this.major,
    required this.avatarUrl,
  });

  final String name;
  final String studentId;
  final String major;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.primaryContainer, width: 2),
                ),
                padding: const EdgeInsets.all(4),
                child: TrustechAvatar(
                  imageUrl: avatarUrl,
                  name: name,
                  radius: 44,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: cs.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.cCard, width: 2),
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Student ID: $studentId',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.primaryContainer.withValues(alpha: 0.2)),
            ),
            child: Text(
              major,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.outline,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
