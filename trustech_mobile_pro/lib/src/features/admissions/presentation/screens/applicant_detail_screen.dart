// Roles: REGISTRAR, ADMIN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/admissions/data/mock/admissions_mock.dart';
import 'package:trustech_mobile_pro/src/features/admissions/providers/admissions_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class ApplicantDetailScreen extends ConsumerWidget {
  const ApplicantDetailScreen({super.key, required this.applicantId});
  final String applicantId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicant = ref.watch(applicantProvider(applicantId));
    final cs = Theme.of(context).colorScheme;
    if (applicant == null) {
      return const Scaffold(
        appBar: AppHeaderBar.back(title: 'Applicant Detail'),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: TrustechEmptyState(title: 'Applicant unavailable'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Trustech Staff Pro'),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TrustechButton(
                  label: 'Update Status',
                  icon: Icons.update,
                  onPressed: () =>
                      context.push('/applicants/${applicant.id}/status'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TrustechButton(
                  label: 'Convert',
                  icon: Icons.person_add,
                  variant: TrustechButtonVariant.outline,
                  onPressed: () =>
                      context.push('/applicants/${applicant.id}/convert'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            TrustechCard(
              child: Row(
                children: [
                  TrustechAvatar(name: applicant.name, radius: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant.name,
                          style: TrustechTypography.h1.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          applicant.applicationNo,
                          style: TrustechTypography.caption.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: applicant.status.label,
                    kind: _kind(applicant.status),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Section(icon: Icons.school, title: 'Academic Program'),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Program',
                  subtitle: applicant.program,
                  icon: Icons.school,
                ),
                InfoListRow(
                  title: 'Application Score',
                  subtitle: applicant.score.toStringAsFixed(0),
                  icon: Icons.fact_check,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Section(icon: Icons.info, title: 'General Information'),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Email',
                  subtitle: applicant.email,
                  icon: Icons.email,
                ),
                InfoListRow(
                  title: 'Submitted',
                  subtitle: applicant.submittedAt,
                  icon: Icons.calendar_month,
                ),
                InfoListRow(
                  title: 'Payment',
                  subtitle: applicant.paymentStatus,
                  icon: Icons.payments,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Section(
              icon: Icons.attach_file,
              title: 'Attached Documents',
            ),
            const InfoListCard(
              children: [
                InfoListRow(
                  title: 'Transcript.pdf',
                  subtitle: 'Verified document',
                  icon: Icons.picture_as_pdf,
                  trailing: Icon(Icons.visibility),
                ),
                InfoListRow(
                  title: 'Certificate.pdf',
                  subtitle: 'Pending review',
                  icon: Icons.picture_as_pdf,
                  trailing: Icon(Icons.download),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Section(icon: Icons.rate_review, title: 'Decision Notes'),
            TrustechCard(
              child: Text(
                'No administrative notes yet. Use status update to add decision rationale.',
                style: TrustechTypography.bodySmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StatusKind _kind(ApplicantStatus s) => switch (s) {
    ApplicantStatus.accepted => StatusKind.success,
    ApplicantStatus.rejected => StatusKind.error,
    ApplicantStatus.waitlisted => StatusKind.warning,
    ApplicantStatus.review => StatusKind.info,
    ApplicantStatus.submitted => StatusKind.neutral,
  };
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TrustechTypography.h3.copyWith(color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}
