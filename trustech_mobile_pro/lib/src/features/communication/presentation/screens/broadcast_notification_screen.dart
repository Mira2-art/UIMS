import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: REGISTRAR / FINANCE / ADMIN.
class BroadcastNotificationScreen extends StatefulWidget {
  const BroadcastNotificationScreen({super.key});

  @override
  State<BroadcastNotificationScreen> createState() => _BroadcastNotificationScreenState();
}

class _BroadcastNotificationScreenState extends State<BroadcastNotificationScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _channels = {'Push Notification': true, 'Official Email': false, 'SMS / Text': false};
  final _groups = <String>{'All Faculty'};

  static const _allGroups = ['All Faculty', 'Department Heads', 'Administrative Staff', 'Security Team'];

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Broadcast Center'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          Text('Broadcast Center',
              style: TrustechTypography.h1.copyWith(color: cs.onSurface)),
          const SizedBox(height: 4),
          Text('Configure and dispatch urgent institutional notifications across all channels.',
              style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 18),
          const _Label('DELIVERY CHANNELS'),
          const SizedBox(height: 8),
          TrustechCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, entry) in _channels.entries.indexed) ...[
                  if (i != 0) Divider(height: 1, color: cs.outlineVariant),
                  _ChannelRow(
                    label: entry.key,
                    subtitle: _channelSub(entry.key),
                    icon: _channelIcon(entry.key),
                    value: entry.value,
                    onChanged: (v) => setState(() => _channels[entry.key] = v),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _Label('MESSAGE CONTENT'),
              Text('${_message.text.length} / 280 characters',
                  style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          TrustechTextField(
            controller: _subject,
            label: 'BROADCAST SUBJECT',
            hintText: 'e.g. Urgent: Campus Weather Update',
          ),
          const SizedBox(height: 14),
          TrustechTextField(
            controller: _message,
            label: 'MESSAGE BODY',
            hintText: 'Type your urgent message here…',
            maxLines: 4,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          const _Label('RECIPIENT GROUPS'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in _allGroups)
                _GroupChip(
                  label: g,
                  selected: _groups.contains(g),
                  onTap: () => setState(() =>
                      _groups.contains(g) ? _groups.remove(g) : _groups.add(g)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Estimated reach: 242 recipients across all selected channels.',
                    style: TrustechTypography.caption
                        .copyWith(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Edit')),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TrustechButton(
            label: 'Test Broadcast',
            variant: TrustechButtonVariant.outline,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          TrustechButton(
            label: 'Send Now',
            icon: Icons.send,
            onPressed: () {
              // TODO(backend): POST /communication notification broadcast.
              AppSnackbar.success(context, 'Broadcast sent to ${_groups.length} group(s).');
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  String _channelSub(String k) => switch (k) {
        'Push Notification' => 'Immediate app alert',
        'Official Email' => 'HTML-rich summary',
        _ => 'Standard carrier rates',
      };
  IconData _channelIcon(String k) => switch (k) {
        'Push Notification' => Icons.notifications_active_outlined,
        'Official Email' => Icons.mail_outline,
        _ => Icons.sms_outlined,
      };
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: TrustechTypography.overline
          .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant));
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return InfoListRow(
      title: label,
      subtitle: subtitle,
      icon: icon,
      trailing: Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
      onTap: () => onChanged(!value),
    );
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip({required this.label, required this.selected, required this.onTap});
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.secondary.withValues(alpha: 0.18) : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? cs.secondary : cs.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? Icons.check : Icons.add, size: 14,
                color: selected ? cs.secondary : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label,
                style: TrustechTypography.caption.copyWith(
                  color: selected ? cs.secondary : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}
