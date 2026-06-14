// Roles: REGISTRAR (ADMIN: view)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class SemestersScreen extends ConsumerStatefulWidget {
  const SemestersScreen({super.key});

  @override
  ConsumerState<SemestersScreen> createState() => _SemestersScreenState();
}

class _SemestersScreenState extends ConsumerState<SemestersScreen> {
  bool _isCalendarView = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Academic Semesters',
        actions: [
          _ViewToggle(
            isCalendar: _isCalendarView,
            onChanged: (val) => setState(() => _isCalendarView = val),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Stats
            const Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'CURRENT SESSION',
                    value: 'Fall 2024',
                    status: 'Active',
                    statusKind: StatusKind.success,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    label: 'OPEN REGISTRATIONS',
                    value: '1',
                    subtitle: 'Spring 2025',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AddSemesterButton(),
            const SizedBox(height: 24),

            if (!_isCalendarView) ...[
              const SectionHeader(title: 'Academic Sessions'),
              const SizedBox(height: 12),
              const _SemesterCard(
                title: 'Fall 2024',
                status: 'CURRENT',
                description: 'Main undergraduate and graduate academic session for the autumn period.',
                startDate: 'Sep 01, 2024',
                endDate: 'Dec 20, 2024',
                regStatus: 'Closed (Ended Aug 15)',
                isRegOpen: false,
                isActive: true,
              ),
              const SizedBox(height: 16),
              const _SemesterCard(
                title: 'Spring 2025',
                status: 'UPCOMING',
                description: 'Main session focusing on core curriculum and final year projects.',
                startDate: 'Jan 15, 2025',
                endDate: 'May 10, 2025',
                regStatus: 'Open until Dec 15, 2024',
                isRegOpen: true,
                isActive: false,
              ),
              const SizedBox(height: 16),
              const _SemesterCard(
                title: 'Summer 2025',
                status: 'PLANNED',
                description: 'Specialized intensive courses and vocational training workshops.',
                startDate: 'TBD (Jun 2025)',
                endDate: 'TBD (Aug 2025)',
                regStatus: 'Scheduled for April 2025',
                isRegOpen: false,
                isActive: false,
                opacity: 0.8,
              ),
            ]
 else
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: TrustechEmptyState(
                    title: 'Calendar View',
                    message: 'Interactive calendar view is under development.',
                    icon: Icons.calendar_month_outlined,
                  ),
                ),
              ),
            const SizedBox(height: 100),
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

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    this.status,
    this.statusKind,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? status;
  final StatusKind? statusKind;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TrustechTypography.h2.copyWith(color: cs.primary, fontSize: 24),
                ),
              ),
              if (status != null)
                StatusChip(label: status!, kind: statusKind ?? StatusKind.neutral),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TrustechTypography.caption.copyWith(fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddSemesterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, size: 32, color: cs.onPrimary),
            const SizedBox(height: 8),
            Text(
              'Add New Semester',
              style: TrustechTypography.h3.copyWith(color: cs.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({
    required this.title,
    required this.status,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.regStatus,
    required this.isRegOpen,
    required this.isActive,
    this.opacity = 1.0,
  });

  final String title;
  final String status;
  final String description;
  final String startDate;
  final String endDate;
  final String regStatus;
  final bool isRegOpen;
  final bool isActive;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Opacity(
      opacity: opacity,
      child: TrustechCard(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isActive)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TrustechTypography.h2.copyWith(color: cs.onSurface),
                          ),
                          const SizedBox(width: 12),
                          _Badge(label: status, color: _getStatusColor(status, cs)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _DetailInfo(label: 'START DATE', value: startDate),
                          const SizedBox(width: 24),
                          _DetailInfo(label: 'END DATE', value: endDate),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REGISTRATION WINDOW',
                            style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant),
                          ),
                          Row(
                            children: [
                              Icon(
                                isRegOpen ? Icons.event_available : Icons.lock_outline,
                                size: 14,
                                color: isRegOpen ? cs.primary : cs.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                regStatus,
                                style: TrustechTypography.label.copyWith(
                                  fontSize: 12,
                                  color: isRegOpen ? cs.onSurface : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 60,
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: cs.outlineVariant, width: 0.5)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch.adaptive(
                      value: isActive,
                      onChanged: (v) {},
                      activeTrackColor: cs.primary,
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () {},
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme cs) {
    if (status == 'CURRENT') return Colors.green;
    if (status == 'UPCOMING') return cs.secondary;
    return cs.onSurfaceVariant;
  }
}

class _DetailInfo extends StatelessWidget {
  const _DetailInfo({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TrustechTypography.overline.copyWith(color: cs.onSurfaceVariant),
        ),
        Text(
          value,
          style: TrustechTypography.label.copyWith(color: cs.onSurface),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TrustechTypography.overline.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isCalendar, required this.onChanged});
  final bool isCalendar;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          _ToggleItem(
            icon: Icons.list,
            label: 'List',
            isSelected: !isCalendar,
            onTap: () => onChanged(false),
          ),
          _ToggleItem(
            icon: Icons.calendar_today,
            label: 'Calendar',
            isSelected: isCalendar,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TrustechTypography.label.copyWith(
                fontSize: 12,
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
