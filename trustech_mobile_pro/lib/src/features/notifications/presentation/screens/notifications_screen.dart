import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/shell/presentation/staff_drawer.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff. Tab root (Alerts).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filter = 0; // 0 All · 1 Unread · 2 Important

  // TODO(backend): GET /communication/notifications.
  static const _items = <_Notif>[
    _Notif('n1', 'Absence Alert: Room 4B', 'Marcus Wright has not arrived for the 09:00 session. Urgent substitute needed.', '2m ago', Icons.warning_amber_rounded, StatusKind.error, true, true, ['URGENT', 'SYSTEM']),
    _Notif('n2', 'Curriculum Update Published', 'The 2026 Science Department framework has been updated by Sarah…', '1h ago', Icons.info_outline, StatusKind.info, true, false, ['ACADEMICS']),
    _Notif('n3', 'Payroll Processed', 'Monthly staff payroll for May has been successfully finalized.', '4h ago', Icons.check_circle_outline, StatusKind.success, false, false, []),
    _Notif('n4', 'Message from Elena Rossi', '"Hi Marcus, I\'ve attached the parent meeting notes for 10th grade…"', '8h ago', Icons.forum_outlined, StatusKind.info, true, false, ['COMMS']),
    _Notif('n5', 'Low Inventory: Station 2', 'Whiteboard marker stock is below 10%. Please approve replenishment…', 'Yesterday', Icons.warning_amber_rounded, StatusKind.warning, true, false, []),
    _Notif('n6', 'Staff Briefing Rescheduled', 'The general staff meeting has been moved to Friday, May 24th at 15:30.', '2 days ago', Icons.event_outlined, StatusKind.warning, false, false, []),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = switch (_filter) {
      1 => _items.where((n) => n.unread).toList(),
      2 => _items.where((n) => n.important).toList(),
      _ => _items,
    };
    final recent = visible.where((n) => !n.time.contains('day')).toList();
    final earlier = visible.where((n) => n.time.contains('day')).toList();

    return Scaffold(
      drawer: const StaffDrawer(selectedRoute: '/notifications'),
      appBar: AppHeaderBar.menu(
        title: 'Trustech Staff Pro',
        actions: [
          IconButton(
            tooltip: 'Mark all read',
            icon: const Icon(Icons.done_all),
            onPressed: () => AppSnackbar.info(context, 'All marked as read.'),
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: visible.isEmpty
          ? const TrustechEmptyState(
              title: 'No notifications',
              message: 'You are all caught up.',
              icon: Icons.notifications_none,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Row(
                  children: [
                    for (final (i, label) in const [(0, 'All'), (1, 'Unread'), (2, 'Important')])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: label,
                          selected: _filter == i,
                          onTap: () => setState(() => _filter = i),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final n in recent) _NotifCard(n: n),
                if (earlier.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Earlier',
                        style: TrustechTypography.label
                            .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  for (final n in earlier) _NotifCard(n: n),
                ],
              ],
            ),
    );
  }
}

class _Notif {
  const _Notif(this.id, this.title, this.message, this.time, this.icon, this.kind,
      this.unread, this.important, this.tags);
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final StatusKind kind;
  final bool unread;
  final bool important;
  final List<String> tags;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          label,
          style: TrustechTypography.caption.copyWith(
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.n});
  final _Notif n;

  Color _accent(BuildContext c) => switch (n.kind) {
        StatusKind.success => Theme.of(c).colorScheme.tertiary,
        StatusKind.warning => Theme.of(c).colorScheme.secondary,
        StatusKind.error => Theme.of(c).colorScheme.error,
        _ => Theme.of(c).colorScheme.primary,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final a = _accent(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TrustechCard(
        onTap: () => context.push('/notifications/${n.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: a.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(n.icon, color: a, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TrustechTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700, color: cs.onSurface)),
                      ),
                      const SizedBox(width: 8),
                      Text(n.time,
                          style: TrustechTypography.caption
                              .copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TrustechTypography.bodySmall
                          .copyWith(color: cs.onSurfaceVariant, height: 1.4)),
                  if (n.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final t in n.tags)
                          StatusChip(
                            label: t,
                            kind: t == 'URGENT' ? StatusKind.error : StatusKind.neutral,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (n.unread)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: a, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
