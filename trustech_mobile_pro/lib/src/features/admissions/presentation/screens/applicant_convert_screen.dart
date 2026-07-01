// Roles: REGISTRAR, ADMIN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/admissions/data/mock/admissions_mock.dart';
import 'package:trustech_mobile_pro/src/features/admissions/providers/admissions_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class ApplicantConvertScreen extends ConsumerWidget {
  const ApplicantConvertScreen({super.key, required this.applicantId});
  final String applicantId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicant = ref.watch(applicantProvider(applicantId));
    final cs = Theme.of(context).colorScheme;
    final can = applicant?.status == ApplicantStatus.accepted;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Trustech Staff Pro'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Convert to Student',
              style: TrustechTypography.displayLarge.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (!can)
              const TrustechEmptyState(
                title: 'Applicant not accepted',
                message:
                    'Only accepted applicants can be converted into students.',
                icon: Icons.lock_outline,
              )
            else ...[
              TrustechCard(
                child: Row(
                  children: [
                    TrustechAvatar(name: applicant!.name, radius: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            applicant.name,
                            style: TrustechTypography.h2.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            applicant.program,
                            style: TrustechTypography.caption.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Student Identity',
                actionLabel: 'Generate',
                onAction: () {},
              ),
              const InfoListCard(
                children: [
                  InfoListRow(
                    title: 'Matric Number',
                    subtitle: 'TRU/2024/SE/0492',
                    icon: Icons.badge,
                    trailing: Icon(Icons.verified),
                  ),
                  InfoListRow(
                    title: 'Program & Level',
                    subtitle: 'B.Sc. Computer Science · 100L',
                    icon: Icons.school,
                  ),
                  InfoListRow(
                    title: 'Academic Session',
                    subtitle: '2026/2027 First Semester',
                    icon: Icons.calendar_month,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Compliance Checklist'),
              const InfoListCard(
                children: [
                  InfoListRow(
                    title: 'Admission offer accepted',
                    subtitle: 'Checked',
                    icon: Icons.check_box,
                  ),
                  InfoListRow(
                    title: 'Application payment verified',
                    subtitle: 'Checked',
                    icon: Icons.check_box,
                  ),
                  InfoListRow(
                    title: 'Final documents verified',
                    subtitle: 'Pending',
                    icon: Icons.check_box_outline_blank,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TrustechButton(
                label: 'Convert Applicant',
                icon: Icons.how_to_reg,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              Text(
                'Converting an applicant is permanent. A student portal account will be automatically provisioned.',
                style: TrustechTypography.caption.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
