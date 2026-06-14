// Roles: REGISTRAR, ADMIN, LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/students/providers/students_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class StudentTranscriptScreen extends ConsumerWidget {
  const StudentTranscriptScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider(studentId));
    final courses = ref.watch(studentTranscriptProvider(studentId));
    final cs = Theme.of(context).colorScheme;
    final credits = courses.fold<int>(0, (s, c) => s + c.credits);
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Trustech Staff Pro'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TrustechCard(
              child: Column(
                children: [
                  Icon(Icons.school, size: 70, color: cs.primary),
                  const SizedBox(height: 8),
                  Text(
                    student?.name ?? 'Student Transcript',
                    textAlign: TextAlign.center,
                    style: TrustechTypography.displayLarge.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    '${student?.matricNo ?? ''} · Official academic record',
                    style: TrustechTypography.caption.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TrustechButton(
                        label: 'Print',
                        icon: Icons.print,
                        expand: false,
                        height: 40,
                        variant: TrustechButtonVariant.outline,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      TrustechButton(
                        label: 'Share',
                        icon: Icons.share,
                        expand: false,
                        height: 40,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.grade,
                    label: 'CGPA',
                    value: student?.cgpa.toStringAsFixed(2) ?? '0.00',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.menu_book,
                    label: 'Credits',
                    value: credits.toString(),
                    accent: cs.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const SectionHeader(title: 'Fall 2023 Semester'),
            InfoListCard(
              children: [
                for (final c in courses)
                  InfoListRow(
                    title: '${c.code} · ${c.grade}',
                    subtitle: '${c.title} · ${c.credits} credits',
                    icon: Icons.receipt_long,
                    trailingText: c.points.toStringAsFixed(1),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TrustechCard(
              child: Row(
                children: [
                  Icon(Icons.verified, color: cs.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Transcript verified by Trustech academic records office.',
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
