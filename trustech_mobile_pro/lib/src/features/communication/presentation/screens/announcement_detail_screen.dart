import 'package:flutter/material.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff (read).
class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key, required this.announcementId});

  final String announcementId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // TODO(backend): GET /communication/announcements/$announcementId.
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Announcement',
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Row(
            children: [
              const StatusChip(label: 'FACULTY AFFAIRS', kind: StatusKind.neutral),
              const SizedBox(width: 8),
              Text('12 min read',
                  style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Academic Calendar Update: Semester II Final Examinations Schedule',
              style: TrustechTypography.h1.copyWith(color: cs.onSurface, height: 1.2)),
          const SizedBox(height: 14),
          Row(
            children: [
              const TrustechAvatar(name: 'Elena Rodriguez', radius: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dr. Elena Rodriguez',
                      style: TrustechTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                  Text('Office of Academic Affairs · Oct 24, 2026',
                      style: TrustechTypography.caption
                          .copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D5A68), Color(0xFF3D7A8C)],
              ),
            ),
            child: const Center(child: Icon(Icons.campaign, color: Colors.white24, size: 64)),
          ),
          const SizedBox(height: 16),
          Text(
            'Dear Faculty and Staff Members,\n\nFollowing the recent Academic Board meeting, we are pleased to announce the finalized schedule for the Semester II Final Examinations. This year, we have implemented a new modular feedback system to streamline the grading process for our educators.',
            style: TrustechTypography.bodyMedium.copyWith(color: cs.onSurface, height: 1.6),
          ),
          const SizedBox(height: 14),
          const InfoListCard(
            children: [
              InfoListRow(title: 'Submission of finalized question papers', subtitle: 'November 5th', icon: Icons.event_outlined),
              InfoListRow(title: 'Commencement of examination period', subtitle: 'November 20th', icon: Icons.event_outlined),
              InfoListRow(title: 'Final grade entry deadline', subtitle: 'December 15th', icon: Icons.event_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: cs.primary, width: 3)),
            ),
            child: Text(
              '"Our priority remains the integrity of the assessment process while ensuring our staff members have the resources needed to provide quality feedback to our students."',
              style: TrustechTypography.bodySmall.copyWith(
                  color: cs.onSurface, fontStyle: FontStyle.italic, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Attached Documents (3)'),
          const SizedBox(height: 4),
          const InfoListCard(
            children: [
              InfoListRow(title: 'Full_Exam_Schedule_V2.pdf', subtitle: 'PDF · 1.4 MB', icon: Icons.picture_as_pdf_outlined, trailingText: 'Open'),
              InfoListRow(title: 'Grading_Policy_Update.docx', subtitle: 'DOCX · 452 KB', icon: Icons.description_outlined, trailingText: 'Open'),
              InfoListRow(title: 'Invigilation_Roster_Draft.xlsx', subtitle: 'XLSX · 88 KB', icon: Icons.table_chart_outlined, trailingText: 'Open'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TrustechButton(
                  label: 'Share',
                  icon: Icons.share_outlined,
                  variant: TrustechButtonVariant.outline,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TrustechButton(
                  label: 'Reply to Office',
                  icon: Icons.reply_outlined,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
