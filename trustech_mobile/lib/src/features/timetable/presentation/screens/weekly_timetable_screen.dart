import 'package:flutter/material.dart';

import 'package:trustech_mobile/src/core/constants/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile/src/features/timetable/data/mock/timetable_mock.dart';
import 'package:trustech_mobile/src/features/timetable/providers/timetable_providers.dart';
import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile/src/shared/utils/theme_helper.dart';

class WeeklyTimetableScreen extends ConsumerStatefulWidget {
  const WeeklyTimetableScreen({super.key});

  @override
  ConsumerState<WeeklyTimetableScreen> createState() =>
      _WeeklyTimetableScreenState();
}

class _WeeklyTimetableScreenState extends ConsumerState<WeeklyTimetableScreen> {
  String? _selectedDayId;

  @override
  Widget build(BuildContext context) {
    final weekAsync = ref.watch(timetableProvider);
    final week = weekAsync.valueOrNull;

    final bar = AppHeaderBar.back(
      title: 'Weekly Timetable',
      actions: [
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.push('/notifications'),
        ),
      ],
    );
    if (week == null) {
      return Scaffold(
        appBar: bar,
        body: weekAsync.hasError
            ? const TrustechEmptyState(
                title: 'Timetable unavailable',
                message: 'Could not load your timetable. Pull to retry.',
                icon: Icons.calendar_today_outlined,
              )
            : const TrustechLoader(),
      );
    }
    final selectedDay = _selectedDay(week);

    return Scaffold(
      appBar: bar,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _WeekHeader(week: week),
          const SizedBox(height: 14),
          _DaySelector(
            days: week.days,
            selectedDayId: selectedDay.id,
            onSelected: (id) => setState(() => _selectedDayId = id),
          ),
          const SizedBox(height: 22),
          SectionHeader(
            title: selectedDay.isToday
                ? 'Today, ${selectedDay.label} ${selectedDay.dateLabel}'
                : '${selectedDay.label} ${selectedDay.dateLabel}',
          ),
          const SizedBox(height: 4),
          if (selectedDay.entries.isEmpty)
            const TrustechEmptyState(
              title: 'No classes scheduled',
              message:
                  'This day is clear. Use it for study blocks, assignments or rest.',
              icon: Icons.event_available_outlined,
            )
          else
            InfoListCard(
              children: selectedDay.entries
                  .map(
                    (entry) => _TimetableEntryRow(
                      entry: entry,
                      onTap: () => context.push('/courses/${entry.courseId}'),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  TimetableDay _selectedDay(TimetableWeek week) {
    final targetId = _selectedDayId ?? week.activeDayId;
    for (final day in week.days) {
      if (day.id == targetId) return day;
    }
    return week.days.first;
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.week});

  final TimetableWeek week;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalClasses = week.days.fold<int>(
      0,
      (count, day) => count + day.entries.length,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cBorder),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            bottom: -40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 124, height: 124),
            ),
          ),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.calendar_month_outlined, color: cs.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT WEEK',
                      style: TextStyle(
                        fontFamily: TrustechTypography.fontFamily,
                        color: cs.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      week.weekLabel,
                      style: TextStyle(
                        fontFamily: TrustechTypography.fontFamily,
                        color: cs.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusChip(
                          label: '$totalClasses classes',
                          kind: StatusKind.info,
                        ),
                        const StatusChip(
                          label: 'Live Week',
                          kind: StatusKind.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.days,
    required this.selectedDayId,
    required this.onSelected,
  });

  final List<TimetableDay> days;
  final String selectedDayId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = days[index];
          return _DayTile(
            day: day,
            isSelected: day.id == selectedDayId,
            onTap: () => onSelected(day.id),
          );
        },
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final TimetableDay day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isSelected ? cs.primaryContainer : context.cCard;
    final border = isSelected ? cs.primary : context.cBorder;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 62,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.label.toUpperCase(),
              style: TextStyle(
                fontFamily: TrustechTypography.fontFamily,
                color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              day.dateLabel,
              style: TextStyle(
                fontFamily: TrustechTypography.fontFamily,
                color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: day.entries.isEmpty
                    ? cs.surface.withValues(alpha: 0)
                    : day.isToday
                    ? cs.secondary
                    : cs.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimetableEntryRow extends StatelessWidget {
  const _TimetableEntryRow({required this.entry, required this.onTap});

  final TimetableEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = entry.type == 'Lab' ? cs.secondary : cs.primary;

    return InfoListRow(
      title: entry.courseTitle,
      subtitle: '${entry.courseCode} · ${entry.venue} · ${entry.lecturer}',
      leading: _TimeBlock(time: entry.startTime, accent: accent),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusChip(
            label: entry.isNow ? 'Now' : entry.type,
            kind: entry.isNow ? StatusKind.success : StatusKind.neutral,
          ),
          const SizedBox(height: 6),
          Text(
            entry.timeRange,
            style: TextStyle(
              fontFamily: TrustechTypography.fontFamily,
              color: cs.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({required this.time, required this.accent});

  final String time;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        time,
        style: TextStyle(
          fontFamily: TrustechTypography.fontFamily,
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
