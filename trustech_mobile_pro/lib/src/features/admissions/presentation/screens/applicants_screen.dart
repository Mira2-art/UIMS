// Roles: REGISTRAR, ADMIN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/admissions/data/mock/admissions_mock.dart';
import 'package:trustech_mobile_pro/src/features/admissions/providers/admissions_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicants = ref.watch(applicantsProvider);
    final cs = Theme.of(context).colorScheme;
    final accepted = applicants
        .where((applicant) => applicant.status == ApplicantStatus.accepted)
        .length;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Trustech Staff Pro'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _ApplicantFilters(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.assignment_ind_outlined,
                    label: 'Applications',
                    value: applicants.length.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.verified_outlined,
                    label: 'Accepted',
                    value: accepted.toString(),
                    accent: cs.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Applications'),
            ...applicants.map(
              (applicant) => _ApplicantCard(
                applicant: applicant,
                onTap: () => context.push('/applicants/${applicant.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicantFilters extends StatelessWidget {
  const _ApplicantFilters();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SearchBox(label: 'Search applicants by name...'),
        const SizedBox(height: 12),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(label: 'All Applicants', selected: true),
              _FilterChip(label: 'New'),
              _FilterChip(label: 'Under Review'),
              _FilterChip(label: 'Accepted'),
              _FilterChip(label: 'Rejected'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FILTERING BY PROGRAM:',
              style: TrustechTypography.overline.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            Row(
              children: [
                Text(
                  'All Programs',
                  style: TrustechTypography.label.copyWith(color: cs.primary),
                ),
                Icon(Icons.expand_more, size: 18, color: cs.primary),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({required this.applicant, required this.onTap});

  final ApplicantProfile applicant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrustechAvatar(name: applicant.name, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: TrustechTypography.h3.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      'Applied ${applicant.submittedAt}',
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
          const SizedBox(height: 10),
          Text(
            applicant.program,
            style: TrustechTypography.bodySmall.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  applicant.applicationNo,
                  style: TrustechTypography.caption.copyWith(color: cs.outline),
                ),
              ),
              Icon(Icons.chevron_right, color: cs.primary),
            ],
          ),
        ],
      ),
    );
  }

  StatusKind _kind(ApplicantStatus status) {
    return switch (status) {
      ApplicantStatus.accepted => StatusKind.success,
      ApplicantStatus.rejected => StatusKind.error,
      ApplicantStatus.waitlisted => StatusKind.warning,
      ApplicantStatus.review => StatusKind.info,
      ApplicantStatus.submitted => StatusKind.neutral,
    };
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TrustechTypography.bodyLarge.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer : cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? cs.primaryContainer : cs.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TrustechTypography.label.copyWith(
          color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
