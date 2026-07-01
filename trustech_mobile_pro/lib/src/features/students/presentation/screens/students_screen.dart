// Roles: REGISTRAR, ADMIN, FINANCE, LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/students/data/mock/students_mock.dart';
import 'package:trustech_mobile_pro/src/features/students/presentation/student_status_ext.dart';
import 'package:trustech_mobile_pro/src/features/students/providers/students_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider);
    final cs = Theme.of(context).colorScheme;
    final probation = students
        .where((student) => student.status == StudentStatus.probation)
        .length;

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Trustech Staff Pro',
        actions: [
          IconButton(
            tooltip: 'Add student',
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () => context.push('/students/new'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SearchAndFilters(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.school_outlined,
                    label: 'Students',
                    value: students.length.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.warning_amber_outlined,
                    label: 'Probation',
                    value: probation.toString(),
                    accent: cs.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: '${students.length} Results',
              actionLabel: 'Sort',
              onAction: () {},
            ),
            if (students.isEmpty)
              const TrustechEmptyState(
                title: 'No student records',
                message:
                    'Converted applicants and imported students will appear here.',
              )
            else
              ...students.map(
                (student) => _StudentCard(
                  student: student,
                  onTap: () => context.push('/students/${student.id}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SearchBox(label: 'Search students, matric, or program...'),
        SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All Levels',
                selected: true,
                icon: Icons.keyboard_arrow_down,
              ),
              _FilterChip(label: 'Program', icon: Icons.keyboard_arrow_down),
              _FilterChip(label: 'Status', icon: Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, required this.onTap});

  final StudentProfile student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          TrustechAvatar(name: student.name, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                ),
                Text(
                  '${student.matricNo} · ${student.program}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusChip(
                label: student.status.label,
                kind: student.status.chipKind,
              ),
              const SizedBox(height: 6),
              Text(
                student.level,
                style: TrustechTypography.caption.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
          Icon(Icons.search, color: cs.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TrustechTypography.bodyLarge.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.filter_list, color: cs.primary, size: 20),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false, this.icon});

  final String label;
  final bool selected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? cs.primaryContainer : cs.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TrustechTypography.label.copyWith(
              color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 4),
            Icon(
              icon,
              size: 18,
              color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }
}
