// Roles: HR, ADMIN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/people/providers/people_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class LecturerDetailScreen extends ConsumerWidget {
  const LecturerDetailScreen({super.key, required this.lecturerId});
  final String lecturerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturer = ref.watch(lecturerProvider(lecturerId));
    final cs = Theme.of(context).colorScheme;
    if (lecturer == null) {
      return const Scaffold(
        appBar: AppHeaderBar.back(title: 'Lecturer Detail'),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: TrustechEmptyState(title: 'Lecturer unavailable'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Staff Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.push('/people/lecturers/${lecturer.id}/edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TrustechCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrustechAvatar(name: lecturer.name, radius: 42),
                  const SizedBox(height: 12),
                  Text(
                    lecturer.name,
                    style: TrustechTypography.displayLarge.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    lecturer.rank,
                    style: TrustechTypography.h3.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.work, size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lecturer.department,
                          style: TrustechTypography.caption.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Central Campus',
                        style: TrustechTypography.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TrustechButton(
                          label: 'Email',
                          icon: Icons.mail,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      TrustechButton(
                        label: 'CV',
                        icon: Icons.download,
                        expand: false,
                        variant: TrustechButtonVariant.outline,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Contact Details'),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Email',
                  subtitle: lecturer.email,
                  icon: Icons.alternate_email,
                ),
                InfoListRow(
                  title: 'Phone',
                  subtitle: lecturer.phone,
                  icon: Icons.call,
                ),
                InfoListRow(
                  title: 'Department',
                  subtitle: lecturer.department,
                  icon: Icons.hub,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Teaching History'),
            const InfoListCard(
              children: [
                InfoListRow(
                  title: 'CSC 301',
                  subtitle: 'Data Structures & Algorithms',
                  icon: Icons.menu_book,
                  showChevron: true,
                ),
                InfoListRow(
                  title: 'CSC 405',
                  subtitle: 'Distributed Systems',
                  icon: Icons.menu_book,
                  showChevron: true,
                ),
                InfoListRow(
                  title: 'MTH 301',
                  subtitle: 'Numerical Methods',
                  icon: Icons.menu_book,
                  showChevron: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TrustechCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Publication',
                    style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Applied models for academic scheduling optimization.',
                    style: TrustechTypography.bodySmall.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
