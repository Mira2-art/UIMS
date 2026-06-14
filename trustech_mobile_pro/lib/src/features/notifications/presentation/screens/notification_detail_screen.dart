import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff. Renders a notification by type (results · timetable ·
// calendar · course-assignment · announcement). Reached via deep link.
enum _NotifKind { results, timetable, calendar, courseAssignment, announcement }

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key, required this.notificationId});

  final String notificationId;

  // TODO(backend): GET notification by id → resolve kind + payload.
  _NotifKind get _kind {
    const values = _NotifKind.values;
    return values[notificationId.hashCode.abs() % values.length];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = _content(_kind);

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Notification'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: d.accent(cs).withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(d.icon, color: d.accent(cs)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChip(label: d.tag, kind: d.kind),
                    const SizedBox(height: 6),
                    Text('Just now',
                        style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(d.title, style: TrustechTypography.h1.copyWith(color: cs.onSurface, height: 1.2)),
          const SizedBox(height: 12),
          Text(d.body,
              style: TrustechTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant, height: 1.6)),
          const SizedBox(height: 20),
          // Contextual action card
          TrustechCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(d.icon, color: d.accent(cs), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(d.cardTitle,
                          style: TrustechTypography.bodyLarge
                              .copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                    ),
                    StatusChip(label: d.cardBadge, kind: d.kind),
                  ],
                ),
                const SizedBox(height: 12),
                TrustechButton(
                  label: d.primaryCta,
                  icon: d.primaryIcon,
                  onPressed: () => context.push(d.primaryRoute),
                ),
                if (d.secondaryCta != null) ...[
                  const SizedBox(height: 10),
                  TrustechButton(
                    label: d.secondaryCta!,
                    variant: TrustechButtonVariant.outline,
                    onPressed: () => AppSnackbar.info(context, '${d.secondaryCta} (mock).'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _NotifContent _content(_NotifKind k) => switch (k) {
        _NotifKind.results => const _NotifContent(
            tag: 'RESULTS', kind: StatusKind.success, icon: Icons.grading_outlined,
            title: 'Grades Published',
            body: 'The final grades for BIO-101 (Intro to Cellular Biology) have been verified and are ready for distribution.',
            cardTitle: 'BIO-101 Results', cardBadge: 'VERIFIED',
            primaryCta: 'Go to Gradebook', primaryIcon: Icons.book_outlined, primaryRoute: '/courses/bio101/gradebook',
            secondaryCta: 'Notify Students'),
        _NotifKind.timetable => const _NotifContent(
            tag: 'TIMETABLE', kind: StatusKind.info, icon: Icons.schedule_outlined,
            title: 'Timetable Updated',
            body: 'Your teaching schedule for next week has changed. Two sessions were relocated to the Science Wing.',
            cardTitle: 'Weekly Timetable', cardBadge: 'UPDATED',
            primaryCta: 'View Timetable', primaryIcon: Icons.calendar_month_outlined, primaryRoute: '/courses',
            secondaryCta: null),
        _NotifKind.calendar => const _NotifContent(
            tag: 'CALENDAR', kind: StatusKind.warning, icon: Icons.event_outlined,
            title: 'Academic Calendar Update',
            body: 'The Semester II examination window has been adjusted. Review the new key dates and deadlines.',
            cardTitle: 'Semester Calendar', cardBadge: 'CHANGED',
            primaryCta: 'Open Calendar', primaryIcon: Icons.event_note_outlined, primaryRoute: '/academics/semesters',
            secondaryCta: null),
        _NotifKind.courseAssignment => const _NotifContent(
            tag: 'ASSIGNMENT', kind: StatusKind.info, icon: Icons.assignment_ind_outlined,
            title: 'New Course Assignment',
            body: 'You have been assigned to teach CS-305 (Operating Systems) for the upcoming semester.',
            cardTitle: 'CS-305 · Operating Systems', cardBadge: 'NEW',
            primaryCta: 'View Course', primaryIcon: Icons.menu_book_outlined, primaryRoute: '/courses/cs305',
            secondaryCta: 'View Roster'),
        _NotifKind.announcement => const _NotifContent(
            tag: 'ANNOUNCEMENT', kind: StatusKind.neutral, icon: Icons.campaign_outlined,
            title: 'New Institutional Announcement',
            body: 'A new announcement from the Office of Academic Affairs requires your attention.',
            cardTitle: 'Academic Calendar Update', cardBadge: 'FACULTY',
            primaryCta: 'Read Announcement', primaryIcon: Icons.article_outlined, primaryRoute: '/announcements/a1',
            secondaryCta: null),
      };
}

class _NotifContent {
  const _NotifContent({
    required this.tag,
    required this.kind,
    required this.icon,
    required this.title,
    required this.body,
    required this.cardTitle,
    required this.cardBadge,
    required this.primaryCta,
    required this.primaryIcon,
    required this.primaryRoute,
    required this.secondaryCta,
  });
  final String tag;
  final StatusKind kind;
  final IconData icon;
  final String title;
  final String body;
  final String cardTitle;
  final String cardBadge;
  final String primaryCta;
  final IconData primaryIcon;
  final String primaryRoute;
  final String? secondaryCta;

  Color accent(ColorScheme cs) => switch (kind) {
        StatusKind.success => cs.tertiary,
        StatusKind.warning => cs.secondary,
        StatusKind.error => cs.error,
        _ => cs.primary,
      };
}
