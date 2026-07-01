import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../utils/theme_helper.dart';
import '../display/trustech_avatar.dart';

/// Attendance / bulk-action status for a roster row.
enum RosterStatus { present, absent, late, excused }

extension RosterStatusMeta on RosterStatus {
  String get short => switch (this) {
        RosterStatus.present => 'P',
        RosterStatus.absent => 'A',
        RosterStatus.late => 'L',
        RosterStatus.excused => 'E',
      };
  Color get color => switch (this) {
        RosterStatus.present => TrustechColors.success,
        RosterStatus.absent => TrustechColors.destructive,
        RosterStatus.late => TrustechColors.secondary,
        RosterStatus.excused => TrustechColors.primary,
      };
}

/// Bulk-mark roster row: avatar + name + id, with a P/A/L/E segmented control.
/// Used by Attendance — Mark (and reusable for any per-student bulk action).
class RosterStatusRow extends StatelessWidget {
  const RosterStatusRow({
    super.key,
    required this.name,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.avatarName,
    this.avatarUrl,
  });

  final String name;
  final String? subtitle;
  final String? avatarName;
  final String? avatarUrl;
  final RosterStatus value;
  final ValueChanged<RosterStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrustechAvatar(name: avatarName ?? name, imageUrl: avatarUrl, radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TrustechTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TrustechTypography.caption
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final s in RosterStatus.values) ...[
                Expanded(child: _Segment(status: s, selected: s == value, onTap: () => onChanged(s))),
                if (s != RosterStatus.values.last) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.status, required this.selected, required this.onTap});

  final RosterStatus status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = status.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? c : cs.outlineVariant),
        ),
        child: Text(
          status.short,
          style: TrustechTypography.label.copyWith(
            color: selected ? Colors.white : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
