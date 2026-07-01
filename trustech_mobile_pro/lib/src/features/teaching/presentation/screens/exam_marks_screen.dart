// Roles: DEAN, SECRETARIAT, ADMIN  (faculty-affiliated exam entry only)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/data/mock/teaching_mock.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

/// Exam marks entry for a course. Exam is scored out of [_examMax] (70) and is
/// entered by the Faculty Dean / School Secretariat / Admin — not the lecturer
/// (who enters CA/30). Empty cells read **N/A** until a 0–70 mark is given.
const double _examMax = 70;

class ExamMarksScreen extends ConsumerStatefulWidget {
  const ExamMarksScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<ExamMarksScreen> createState() => _ExamMarksScreenState();
}

class _ExamMarksScreenState extends ConsumerState<ExamMarksScreen> {
  /// studentId → exam mark (0–70). Absent / null ⇒ N/A (not yet entered).
  final Map<String, double> _marks = {};

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(teachingCourseProvider(widget.courseId));
    final roster = ref.watch(courseRosterProvider(widget.courseId));
    final cs = Theme.of(context).colorScheme;

    final entered = roster.where((s) => _marks.containsKey(s.id)).length;
    final average = entered == 0
        ? 0.0
        : roster
                  .where((s) => _marks.containsKey(s.id))
                  .fold<double>(0, (sum, s) => sum + _marks[s.id]!) /
              entered;

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Exam Marks',
        actions: [
          IconButton(
            tooltip: 'Download Excel template',
            icon: const Icon(Icons.download_outlined),
            onPressed: _downloadTemplate,
          ),
          IconButton(
            tooltip: 'Upload filled sheet',
            icon: const Icon(Icons.upload_file_outlined),
            onPressed: () => _uploadSheet(roster),
          ),
        ],
      ),
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
              Expanded(
                child: Text(
                  '$entered/${roster.length} entered · ${roster.length - entered} N/A',
                  style: TrustechTypography.bodyMedium.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
              TrustechButton(
                label: 'Submit marks',
                icon: Icons.send_outlined,
                expand: false,
                onPressed: entered == 0
                    ? null
                    : () => _submit(entered, roster.length),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CourseHeader(course: course, average: average, entered: entered),
            const SizedBox(height: 12),
            _ExcelActions(
              onDownload: _downloadTemplate,
              onUpload: () => _uploadSheet(roster),
            ),
            const SizedBox(height: 18),
            const _ListHeader(),
            if (roster.isEmpty)
              const TrustechEmptyState(
                title: 'No students enrolled',
                message: 'Enrolled students will appear here for exam entry.',
              )
            else
              ...roster.map(
                (student) => _MarkRow(
                  student: student,
                  mark: _marks[student.id],
                  onTap: () => _editMark(student),
                ),
              ),
            const SizedBox(height: 92),
          ],
        ),
      ),
    );
  }

  // ── Per-student entry popup ────────────────────────────────────────────────
  Future<void> _editMark(CourseRosterStudent student) async {
    final controller = TextEditingController(
      text: _marks[student.id]?.toStringAsFixed(0) ?? '',
    );
    String? error;
    await showAppSheet<void>(
      context,
      (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SheetScaffold(
          title: 'Exam mark · ${student.name}',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${student.matricNo} · out of ${_examMax.toStringAsFixed(0)}',
                style: TrustechTypography.caption.copyWith(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              TrustechTextField(
                controller: controller,
                label: 'Exam mark (0–70)',
                hintText: 'e.g. 58',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: Icons.edit_outlined,
                errorText: error,
                onChanged: (_) {
                  if (error != null) setSheetState(() => error = null);
                },
              ),
              const SizedBox(height: 16),
              TrustechButton(
                label: 'Save mark',
                icon: Icons.check,
                onPressed: () {
                  final value = double.tryParse(controller.text.trim());
                  if (value == null || value < 0 || value > _examMax) {
                    setSheetState(
                      () => error = 'Enter a number from 0 to '
                          '${_examMax.toStringAsFixed(0)}.',
                    );
                    return;
                  }
                  setState(() => _marks[student.id] = value);
                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 8),
              TrustechButton(
                label: 'Clear (set N/A)',
                variant: TrustechButtonVariant.text,
                onPressed: () {
                  setState(() => _marks.remove(student.id));
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
  }

  // ── Excel template + bulk upload (UI-only mock) ────────────────────────────
  void _downloadTemplate() {
    // TODO(backend): generate an .xlsx with [Matric No, Name, Exam Mark (/70)].
    AppSnackbar.info(
      context,
      'Exam template (Matric · Name · Mark /70) export coming soon.',
    );
  }

  void _uploadSheet(List<CourseRosterStudent> roster) {
    // TODO(backend): parse the uploaded .xlsx and map Matric No → mark.
    // Mock: fill every student so the sheet "shows same for all" after upload.
    setState(() {
      for (var i = 0; i < roster.length; i++) {
        _marks[roster[i].id] = (40 + (i * 7) % 31).toDouble().clamp(0, _examMax);
      }
    });
    AppSnackbar.success(
      context,
      'Sheet imported · ${roster.length} marks filled (mock).',
    );
  }

  void _submit(int entered, int total) {
    // TODO(backend): POST exam scores (0–70) for this course's enrollments.
    AppSnackbar.success(
      context,
      'Submitted $entered marks · ${total - entered} left as N/A.',
    );
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({
    required this.course,
    required this.average,
    required this.entered,
  });

  final TeachingCourse? course;
  final double average;
  final int entered;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TrustechCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course == null
                      ? 'Exam Marks'
                      : '${course!.code}: ${course!.title}',
                  style: TrustechTypography.h2.copyWith(color: cs.onSurface),
                ),
              ),
              const StatusChip(label: 'EXAM · /70', kind: StatusKind.info),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.account_balance_outlined, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  course?.faculty ?? 'Faculty',
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (entered > 0)
                Text(
                  'Avg ${average.toStringAsFixed(1)}/70',
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Exam entry is restricted to staff affiliated with this faculty.',
            style: TrustechTypography.caption.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }
}

class _ExcelActions extends StatelessWidget {
  const _ExcelActions({required this.onDownload, required this.onUpload});

  final VoidCallback onDownload;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TrustechButton(
            label: 'Download template',
            icon: Icons.download_outlined,
            variant: TrustechButtonVariant.outline,
            onPressed: onDownload,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TrustechButton(
            label: 'Upload sheet',
            icon: Icons.upload_file_outlined,
            variant: TrustechButtonVariant.outline,
            onPressed: onUpload,
          ),
        ),
      ],
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'STUDENT',
              style: TrustechTypography.overline.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            'MARK /70',
            style: TrustechTypography.overline.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkRow extends StatelessWidget {
  const _MarkRow({required this.student, required this.mark, required this.onTap});

  final CourseRosterStudent student;
  final double? mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasMark = mark != null;
    return TrustechCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          TrustechAvatar(name: student.name, radius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                ),
                Text(
                  student.matricNo,
                  style: TrustechTypography.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 64),
            height: 40,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: hasMark
                  ? cs.primary.withValues(alpha: 0.10)
                  : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasMark ? cs.primary : cs.outlineVariant,
              ),
            ),
            child: Text(
              hasMark ? mark!.toStringAsFixed(0) : 'N/A',
              style: TrustechTypography.label.copyWith(
                color: hasMark ? cs.primary : cs.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(Icons.edit_outlined, size: 18, color: cs.outline),
        ],
      ),
    );
  }
}
