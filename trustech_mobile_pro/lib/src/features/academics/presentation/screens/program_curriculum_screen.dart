// Roles: REGISTRAR (ADMIN: view)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/academics/providers/academics_providers.dart';
import 'package:trustech_mobile_pro/src/features/academics/data/mock/academics_mock.dart';

class ProgramCurriculumScreen extends ConsumerWidget {
  const ProgramCurriculumScreen({super.key, required this.programId});

  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curriculum = ref.watch(programCurriculumProvider(programId));
    final cs = Theme.of(context).colorScheme;

    if (curriculum == null) {
      return const TrustechScaffold(
        title: 'Curriculum',
        body: Center(child: Text('Curriculum not found')),
      );
    }

    final programs = ref.watch(programsProvider);
    final program = programs.firstWhere(
      (p) => p.id == curriculum.programId,
      orElse: () => programs.first,
    );
    final departments = ref.watch(departmentsProvider);
    final department = departments.firstWhere(
      (d) => d.id == program.deptId,
      orElse: () => departments.first,
    );

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Program Curriculum'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEPARTMENT OF ${department.name.toUpperCase()}',
                    style: TrustechTypography.overline.copyWith(color: cs.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    program.name,
                    style: TrustechTypography.displayLarge.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _Badge(label: 'Year ${curriculum.year}'),
                        const SizedBox(width: 8),
                        _Badge(label: 'Total Units: ${program.totalCredits}'),
                        const SizedBox(width: 8),
                        const StatusChip(label: 'ACTIVE', kind: StatusKind.success),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Curriculum Levels
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: curriculum.levels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                return _LevelGroup(level: curriculum.levels[index]);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LevelGroup extends StatelessWidget {
  const _LevelGroup({required this.level});
  final CurriculumLevel level;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          // Level Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${level.level} Level',
                      style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                    ),
                    Text(
                      level.description,
                      style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                Icon(Icons.expand_more, color: cs.outline),
              ],
            ),
          ),
          // Semesters
          ...level.semesters.map((s) => _SemesterSection(semester: s)),
          // Add Course Button for Level
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {},
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outlineVariant, width: 2, style: BorderStyle.solid), // Dash is hard in flutter, using solid
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20, color: cs.outline),
                    const SizedBox(width: 8),
                    Text(
                      'Add Course to ${level.level} Level',
                      style: TrustechTypography.label.copyWith(color: cs.outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemesterSection extends StatelessWidget {
  const _SemesterSection({required this.semester});
  final CurriculumSemester semester;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semester ${semester.number}',
                style: TrustechTypography.label.copyWith(color: cs.primary),
              ),
              Text(
                '${semester.totalUnits} UNITS',
                style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        ...semester.courses.map((c) => _CourseRow(course: c)),
        if (semester.number != 2) const Divider(indent: 16, endIndent: 16),
      ],
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({required this.course});
  final CurriculumCourse course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  course.code,
                  style: TrustechTypography.label.copyWith(color: cs.primary, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: course.isCore ? cs.tertiaryContainer.withValues(alpha: 0.2) : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    border: course.isCore ? null : Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(
                    course.isCore ? 'CORE' : 'ELECTIVE',
                    style: TrustechTypography.overline.copyWith(
                      fontSize: 8,
                      color: course.isCore ? cs.onTertiaryContainer : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              course.title,
              style: TrustechTypography.bodyLarge.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${course.units} Units',
                  style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant),
                ),
                Icon(Icons.edit_outlined, size: 16, color: cs.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        label,
        style: TrustechTypography.label.copyWith(color: cs.onSurface, fontSize: 12),
      ),
    );
  }
}
