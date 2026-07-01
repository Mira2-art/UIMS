// Roles: HR, ADMIN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/people/data/mock/people_mock.dart';
import 'package:trustech_mobile_pro/src/features/people/providers/people_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class LecturersScreen extends ConsumerWidget {
  const LecturersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturers = ref.watch(lecturersProvider);
    final cs = Theme.of(context).colorScheme;
    final active = lecturers
        .where((lecturer) => lecturer.status == LecturerStatus.active)
        .length;

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Staff Directory',
        actions: [
          IconButton(
            tooltip: 'Add lecturer',
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () => context.push('/people/lecturers/new'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _DirectoryFilters(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.badge_outlined,
                    label: 'Lecturers',
                    value: lecturers.length.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.verified_outlined,
                    label: 'Active',
                    value: active.toString(),
                    accent: cs.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Directory'),
            ...lecturers.map(
              (lecturer) => _LecturerCard(
                lecturer: lecturer,
                onTap: () => context.push('/people/lecturers/${lecturer.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectoryFilters extends StatelessWidget {
  const _DirectoryFilters();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SearchBox(label: 'Search lecturers by name, ID, or subject...'),
        SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(label: 'All Staff', selected: true),
              _FilterChip(label: 'Mathematics'),
              _FilterChip(label: 'Science'),
              _FilterChip(label: 'Humanities'),
              _FilterChip(label: 'Physical Ed.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _LecturerCard extends StatelessWidget {
  const _LecturerCard({required this.lecturer, required this.onTap});

  final LecturerProfile lecturer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Center(
              child: TrustechAvatar(name: lecturer.name, radius: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        lecturer.name,
                        style: TrustechTypography.h3.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    StatusChip(
                      label: lecturer.status.label,
                      kind: _kind(lecturer.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lecturer.department.toUpperCase(),
                  style: TrustechTypography.overline.copyWith(
                    color: cs.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${lecturer.rank} · ${lecturer.specialization}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TrustechTypography.bodySmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.mail_outline, color: cs.primary, size: 20),
                    const SizedBox(width: 14),
                    Icon(Icons.chevron_right, color: cs.primary, size: 22),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatusKind _kind(LecturerStatus status) {
    return switch (status) {
      LecturerStatus.active => StatusKind.success,
      LecturerStatus.leave => StatusKind.warning,
      LecturerStatus.sabbatical => StatusKind.info,
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
          Icon(Icons.tune, color: cs.primary),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? cs.primary : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? cs.primary : cs.outlineVariant),
      ),
      child: Text(
        label,
        style: TrustechTypography.label.copyWith(
          color: selected ? cs.onPrimary : cs.onSurface,
        ),
      ),
    );
  }
}
