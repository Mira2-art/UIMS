import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: STAFF / REGISTRAR / FINANCE / ADMIN.
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  int _filter = 0;
  final _search = TextEditingController();

  static const _filters = ['All', 'Academic', 'Administrative', 'Events'];

  // TODO(backend): GET /communication/announcements.
  static const _items = <_Ann>[
    _Ann('a1', 'HEALTH & SAFETY', 'Emergency Fire Drill: Sector B', 'Please be advised that a mandatory fire drill will commence at 10:30 AM today for all staff in…', 'Security Office', 'Today, 08:45 AM', _Badge.urgent),
    _Ann('a2', 'ACADEMIC', 'End of Term Grade Submission', 'The portal for Q3 grade submissions is now open. Please ensure all student records are finalized…', "Registrar's Dept.", 'Today, 09:12 AM', _Badge.isNew),
    _Ann('a3', 'EVENTS', 'Staff Appreciation Gala Invitation', 'We are excited to invite all Trustech faculty and staff to our annual appreciation evening. RSVP…', "Director's Office", 'Yesterday, 04:30 PM', _Badge.none),
    _Ann('a4', 'ADMIN', 'IT Systems Maintenance Notice', 'The campus Wi-Fi network will undergo scheduled maintenance this Saturday from 12:00…', 'IT Support Team', 'Oct 24', _Badge.none),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Announcements',
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: TrustechAvatar(name: 'Marcus Webb', radius: 16),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/announcements/compose'),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Compose'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          TrustechTextField(
            controller: _search,
            hintText: 'Search by title, keyword, or sender',
            prefixIcon: Icons.search,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _Chip(
                label: _filters[i],
                selected: _filter == i,
                onTap: () => setState(() => _filter = i),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final a in _items) _AnnCard(a: a),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: StatCard(
                  icon: Icons.campaign_outlined,
                  label: 'New This Week',
                  value: '12',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.priority_high,
                  label: 'Urgent Alerts',
                  value: '02',
                  accent: cs.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _Badge { none, urgent, isNew }

class _Ann {
  const _Ann(this.id, this.category, this.title, this.body, this.sender, this.time, this.badge);
  final String id;
  final String category;
  final String title;
  final String body;
  final String sender;
  final String time;
  final _Badge badge;
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: cs.outlineVariant),
        ),
        child: Text(label,
            style: TrustechTypography.caption.copyWith(
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}

class _AnnCard extends StatelessWidget {
  const _AnnCard({required this.a});
  final _Ann a;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TrustechCard(
        onTap: () => context.push('/announcements/${a.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(a.category,
                    style: TrustechTypography.overline.copyWith(color: cs.secondary)),
                const Spacer(),
                if (a.badge == _Badge.urgent)
                  const StatusChip(label: 'URGENT', kind: StatusKind.error),
                if (a.badge == _Badge.isNew)
                  const StatusChip(label: 'NEW', kind: StatusKind.info),
              ],
            ),
            const SizedBox(height: 6),
            Text(a.title,
                style: TrustechTypography.h3.copyWith(color: cs.onSurface)),
            const SizedBox(height: 6),
            Text(a.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TrustechTypography.bodySmall
                    .copyWith(color: cs.onSurfaceVariant, height: 1.4)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.account_circle_outlined, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(a.sender,
                    style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                const Spacer(),
                Text(a.time,
                    style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
