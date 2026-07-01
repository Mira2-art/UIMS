// Roles: REGISTRAR, ADMIN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/students/data/mock/students_mock.dart';
import 'package:trustech_mobile_pro/src/features/students/providers/students_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class EnrollmentsScreen extends ConsumerWidget {
  const EnrollmentsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollments = ref.watch(enrollmentsProvider);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Enrollments'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Row(
              children: [
                Expanded(
                  child: _FilterInput(
                    icon: Icons.person,
                    label: 'Student name or ID',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _FilterInput(icon: Icons.menu_book, label: 'Program'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TrustechButton(
              label: 'Apply Filters',
              icon: Icons.filter_list,
              onPressed: () {},
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'STUDENT',
                    style: TrustechTypography.overline.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'STATUS',
                    style: TrustechTypography.overline.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 54),
              ],
            ),
            const SizedBox(height: 8),
            ...enrollments.map((r) => _EnrollmentRow(record: r)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chevron_left, color: cs.outline),
                const SizedBox(width: 8),
                const StatusChip(label: '1', kind: StatusKind.info),
                const SizedBox(width: 8),
                Text(
                  '2  3',
                  style: TrustechTypography.label.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: cs.outline),
              ],
            ),
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentRow extends StatelessWidget {
  const _EnrollmentRow({required this.record});
  final EnrollmentRecord record;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.studentName,
                  style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                ),
                Text(
                  '${record.program} · ${record.credits} credits',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(label: record.status, kind: StatusKind.success),
          IconButton(
            icon: Icon(Icons.edit_note, color: cs.outline),
            onPressed: () => _confirm(context, 'Change Status'),
          ),
          IconButton(
            icon: Icon(Icons.cancel_outlined, color: cs.error),
            onPressed: () => _confirm(context, 'Drop Enrollment'),
          ),
        ],
      ),
    );
  }

  void _confirm(BuildContext context, String action) {
    final c = TextEditingController();
    showAppSheet<void>(
      context,
      (ctx) => SheetScaffold(
        title: action,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TrustechTextField(
              controller: c,
              label: 'Reason',
              hintText: 'Required audit reason',
            ),
            const SizedBox(height: 16),
            TrustechButton(
              label: 'Confirm',
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    ).whenComplete(c.dispose);
  }
}

class _FilterInput extends StatelessWidget {
  const _FilterInput({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.outline, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TrustechTypography.caption.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
