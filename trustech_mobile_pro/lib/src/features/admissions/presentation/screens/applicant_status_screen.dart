// Roles: REGISTRAR, ADMIN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/admissions/data/mock/admissions_mock.dart';
import 'package:trustech_mobile_pro/src/features/admissions/providers/admissions_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class ApplicantStatusScreen extends ConsumerStatefulWidget {
  const ApplicantStatusScreen({super.key, required this.applicantId});
  final String applicantId;
  @override
  ConsumerState<ApplicantStatusScreen> createState() =>
      _ApplicantStatusScreenState();
}

class _ApplicantStatusScreenState extends ConsumerState<ApplicantStatusScreen> {
  ApplicantStatus _selected = ApplicantStatus.review;
  final _notes = TextEditingController();
  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicant = ref.watch(applicantProvider(widget.applicantId));
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Status Update'),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TrustechButton(
            label: 'Save Status',
            icon: Icons.save,
            onPressed: () {},
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            TrustechCard(
              child: Row(
                children: [
                  TrustechAvatar(
                    name: applicant?.name ?? 'Applicant',
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant?.name ?? 'Applicant',
                          style: TrustechTypography.h2.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          applicant?.applicationNo ?? '',
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
            const SizedBox(height: 18),
            Text(
              'SELECT ADMISSION STATUS',
              style: TrustechTypography.caption.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.7,
              children: [
                for (final s in ApplicantStatus.values)
                  _StatusTile(
                    status: s,
                    selected: _selected == s,
                    onTap: () => setState(() => _selected = s),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TrustechTextField(
              controller: _notes,
              label: 'Decision Reason / Notes',
              hintText: 'Enter detailed notes regarding this status change...',
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            TrustechCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Status changes are audited and may trigger applicant notifications.',
                      style: TrustechTypography.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
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

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.status,
    required this.selected,
    required this.onTap,
  });
  final ApplicantStatus status;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon(status),
              color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              status.label,
              textAlign: TextAlign.center,
              style: TrustechTypography.label.copyWith(
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(ApplicantStatus s) => switch (s) {
    ApplicantStatus.submitted => Icons.fiber_new,
    ApplicantStatus.review => Icons.pageview,
    ApplicantStatus.waitlisted => Icons.hourglass_top,
    ApplicantStatus.accepted => Icons.check_circle,
    ApplicantStatus.rejected => Icons.cancel,
  };
}
