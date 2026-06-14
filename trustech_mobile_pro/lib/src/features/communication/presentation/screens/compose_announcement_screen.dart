import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: STAFF / REGISTRAR / FINANCE / ADMIN.
class ComposeAnnouncementScreen extends StatefulWidget {
  const ComposeAnnouncementScreen({super.key});

  @override
  State<ComposeAnnouncementScreen> createState() => _ComposeAnnouncementScreenState();
}

class _ComposeAnnouncementScreenState extends State<ComposeAnnouncementScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  int _priority = 0;
  final _audience = {'All Staff Members': true, 'Faculty Only': false, 'Administrative Staff': false};
  bool _schedule = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Compose Announcement',
        actions: [
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Discard'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          TrustechTextField(
            controller: _title,
            label: 'ANNOUNCEMENT TITLE',
            hintText: 'e.g., Annual Faculty Symposium 2026',
          ),
          const SizedBox(height: 16),
          const _Label('CATEGORY'),
          const SizedBox(height: 6),
          InfoListCard(
            children: [
              InfoListRow(
                title: 'Academic Affairs',
                icon: Icons.category_outlined,
                trailing: Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _Label('PRIORITY LEVEL'),
          const SizedBox(height: 6),
          SegmentedControl(
            options: const ['Standard', 'High', 'Critical'],
            selected: _priority,
            onChanged: (i) => setState(() => _priority = i),
          ),
          const SizedBox(height: 16),
          const _Label('BODY CONTENT'),
          const SizedBox(height: 6),
          TrustechTextField(
            controller: _body,
            hintText: 'Write your announcement message here…',
            maxLines: 6,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.groups_outlined, color: cs.primary),
              const SizedBox(width: 8),
              Text('Target Audience',
                  style: TrustechTypography.h3.copyWith(color: cs.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          for (final entry in _audience.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CheckTile(
                label: entry.key,
                value: entry.value,
                onChanged: (v) => setState(() => _audience[entry.key] = v),
              ),
            ),
          const SizedBox(height: 12),
          TrustechCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: cs.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Publishing',
                        style: TrustechTypography.bodyLarge
                            .copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                    const Spacer(),
                    Switch.adaptive(
                      value: _schedule,
                      onChanged: (v) => setState(() => _schedule = v),
                    ),
                  ],
                ),
                if (_schedule) ...[
                  const SizedBox(height: 8),
                  Text('Release scheduling enabled (date/time pickers — UI only).',
                      style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          TrustechButton(
            label: _schedule ? 'Schedule' : 'Publish',
            icon: Icons.send_outlined,
            onPressed: () {
              // TODO(backend): POST /communication/announcements (+ publish).
              AppSnackbar.success(context, 'Announcement ${_schedule ? 'scheduled' : 'published'}.');
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: TrustechTypography.overline
          .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant));
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value ? cs.primary : cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(value ? Icons.check_box : Icons.check_box_outline_blank,
                color: value ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(label, style: TrustechTypography.bodyMedium.copyWith(color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}
