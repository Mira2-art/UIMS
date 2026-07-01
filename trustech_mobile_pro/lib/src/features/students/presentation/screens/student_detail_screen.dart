// Roles: REGISTRAR, ADMIN, FINANCE, LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/students/presentation/student_status_ext.dart';
import 'package:trustech_mobile_pro/src/features/students/providers/students_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider(studentId));
    final cs = Theme.of(context).colorScheme;
    if (student == null) {
      return const Scaffold(
        appBar: AppHeaderBar.back(title: 'Student Detail'),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: TrustechEmptyState(title: 'Student unavailable'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Student Detail',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/students/${student.id}/edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TrustechCard(
              child: Column(
                children: [
                  TrustechAvatar(name: student.name, radius: 42),
                  const SizedBox(height: 12),
                  Text(
                    student.name,
                    textAlign: TextAlign.center,
                    style: TrustechTypography.h2.copyWith(color: cs.onSurface),
                  ),
                  Text(
                    student.matricNo,
                    style: TrustechTypography.caption.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StatusChip(
                    label: student.status.label,
                    kind: student.status.chipKind,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.school_outlined,
                    label: 'LEVEL',
                    value: student.level,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.trending_up,
                    label: 'CGPA',
                    value: student.cgpa.toStringAsFixed(2),
                    accent: cs.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickLink(
                    label: 'Transcript',
                    icon: Icons.description,
                    onTap: () =>
                        context.push('/students/${student.id}/transcript'),
                  ),
                  _QuickLink(
                    label: 'Enrollments',
                    icon: Icons.how_to_reg,
                    onTap: () => context.push('/enrollments'),
                  ),
                  _QuickLink(label: 'Fees', icon: Icons.payments, onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const SectionHeader(title: 'Personal Information'),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Email',
                  subtitle: student.email,
                  icon: Icons.mail_outline,
                ),
                InfoListRow(
                  title: 'Phone',
                  subtitle: student.phone,
                  icon: Icons.phone_outlined,
                ),
                InfoListRow(
                  title: 'Programme',
                  subtitle: student.program,
                  icon: Icons.school_outlined,
                ),
                InfoListRow(
                  title: 'Department',
                  subtitle: student.department,
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TrustechButton(
              label: 'Send student message',
              icon: Icons.send,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TrustechTypography.label.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
