// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class AttendanceMarkScreen extends ConsumerStatefulWidget {
  const AttendanceMarkScreen({
    super.key,
    required this.courseId,
    required this.sessionId,
  });

  final String courseId;
  final String sessionId;

  @override
  ConsumerState<AttendanceMarkScreen> createState() =>
      _AttendanceMarkScreenState();
}

class _AttendanceMarkScreenState extends ConsumerState<AttendanceMarkScreen> {
  final Map<String, RosterStatus> _marks = {};

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(teachingCourseProvider(widget.courseId));
    final session = ref.watch(
      attendanceSessionProvider((
        courseId: widget.courseId,
        sessionId: widget.sessionId,
      )),
    );
    final roster = ref.watch(courseRosterProvider(widget.courseId));
    final cs = Theme.of(context).colorScheme;

    if (_marks.isEmpty && roster.isNotEmpty) {
      for (var index = 0; index < roster.length; index++) {
        final student = roster[index];
        _marks[student.id] = switch (index % 6) {
          1 => RosterStatus.late,
          3 => RosterStatus.absent,
          _ => RosterStatus.present,
        };
      }
    }

    final presentLike = _marks.values
        .where(
          (status) =>
              status == RosterStatus.present || status == RosterStatus.late,
        )
        .length;
    final rate = roster.isEmpty ? 0.0 : (presentLike / roster.length) * 100;

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Mark Attendance'),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            children: [
              ProgressRing(percent: rate, size: 52, strokeWidth: 5),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$presentLike/${roster.length} marked present or late',
                  style: TrustechTypography.bodyMedium.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TrustechButton(
                label: 'Save',
                icon: Icons.save_outlined,
                expand: false,
                onPressed: () {
                  // TODO(backend): persist attendance marks for this session.
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              course?.code ?? 'Course',
              style: TrustechTypography.overline.copyWith(color: cs.primary),
            ),
            const SizedBox(height: 6),
            Text(
              session?.title ?? 'Attendance session',
              style: TrustechTypography.h1.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              session == null
                  ? 'Session details pending'
                  : '${session.date} · ${session.time}',
              style: TrustechTypography.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TrustechButton(
                    label: 'All Present',
                    icon: Icons.done_all,
                    variant: TrustechButtonVariant.outline,
                    onPressed: () => _markAll(
                      roster.map((student) => student.id),
                      RosterStatus.present,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TrustechButton(
                    label: 'All Absent',
                    icon: Icons.block_outlined,
                    variant: TrustechButtonVariant.outline,
                    onPressed: () => _markAll(
                      roster.map((student) => student.id),
                      RosterStatus.absent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Roster'),
            if (roster.isEmpty)
              const TrustechEmptyState(
                title: 'No students to mark',
                message: 'Registered students will appear here.',
              )
            else
              ...roster.map(
                (student) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RosterStatusRow(
                    name: student.name,
                    subtitle: '${student.matricNo} · ${student.level}',
                    avatarName: student.name,
                    value: _marks[student.id] ?? RosterStatus.absent,
                    onChanged: (status) =>
                        setState(() => _marks[student.id] = status),
                  ),
                ),
              ),
            const SizedBox(height: 92),
          ],
        ),
      ),
    );
  }

  void _markAll(Iterable<String> ids, RosterStatus status) {
    setState(() {
      for (final id in ids) {
        _marks[id] = status;
      }
    });
  }
}
