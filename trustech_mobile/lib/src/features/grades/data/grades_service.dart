import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/client/dio_provider.dart';
import 'mock/grades_mock.dart';

/// Result of GET /students/{id}/results — grouped years + cumulative CGPA.
class TranscriptData {
  const TranscriptData({required this.years, required this.cgpa});
  final List<AcademicYearResult> years;
  final double? cgpa;

  int get finalizedTermCount =>
      years.expand((y) => y.terms).where((t) => t.isPublished).length;
}

class GradesService {
  GradesService(this._dio);
  final Dio _dio;

  Future<TranscriptData> results(String studentId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.studentResults(studentId),
    );
    final data = res.data ?? const {};
    final semesters = (data['semesters'] as List? ?? const []);

    // Group semesters by academic_year (newest first).
    final byYear = <String, List<TermResult>>{};
    for (final s in semesters.cast<Map<String, dynamic>>()) {
      final year = (s['academic_year'] ?? '') as String;
      final number = (s['semester_number'] ?? 0) as int;
      final courses = (s['courses'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(_course)
          .toList(growable: false);
      byYear.putIfAbsent(year, () => []).add(
            TermResult(
              id: (s['semester_id'] ?? '') as String,
              number: number,
              label: number == 2 ? 'Second Semester' : 'First Semester',
              courses: courses,
            ),
          );
    }
    final years = byYear.entries
        .map((e) => AcademicYearResult(
              year: e.key,
              terms: e.value..sort((a, b) => b.number.compareTo(a.number)),
            ))
        .toList()
      ..sort((a, b) => b.year.compareTo(a.year));

    return TranscriptData(years: years, cgpa: _toDouble(data['cgpa']));
  }

  Future<AcademicStandingSummary> standing(String studentId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.studentStanding(studentId),
    );
    final d = res.data;
    if (d == null || d.isEmpty) {
      return const AcademicStandingSummary(
        status: StandingStatus.goodStanding,
        currentGpa: 0,
        cgpa: 0,
        gpaChange: 0,
        creditsAttempted: 0,
        creditsEarned: 0,
        creditsRequired: 120,
        cohortRankLabel: '—',
        reason: 'No academic standing recorded yet.',
        history: [],
      );
    }
    final cgpa = _toDouble(d['cgpa']) ?? 0;
    final status = _standing(d['standing'] as String?);
    return AcademicStandingSummary(
      status: status,
      currentGpa: _toDouble(d['gpa']) ?? 0,
      cgpa: cgpa,
      gpaChange: 0,
      creditsAttempted: (d['total_credits_attempted'] ?? 0) as int,
      creditsEarned: (d['total_credits_earned'] ?? 0) as int,
      creditsRequired: 120,
      cohortRankLabel: status == StandingStatus.deansList
          ? "Dean's List"
          : 'In good standing',
      reason: (d['standing_reason'] as String?) ??
          'Your CGPA is $cgpa on a 4.0 scale.',
      history: const [],
    );
  }

  CourseResult _course(Map<String, dynamic> c) {
    final ca = _toDouble(c['ca_score']);
    final exam = _toDouble(c['exam_score']);
    return CourseResult(
      courseId: (c['course_id'] ?? '') as String,
      code: (c['code'] ?? '') as String,
      title: (c['title'] ?? '') as String,
      credits: (c['credit_units'] ?? 0) as int,
      caScore: ca ?? 0,
      examScore: exam ?? 0,
      caPublished: ca != null,
      examPublished: exam != null,
    );
  }

  StandingStatus _standing(String? s) {
    switch (s) {
      case 'DEANS_LIST':
        return StandingStatus.deansList;
      case 'PROBATION':
        return StandingStatus.probation;
      default:
        return StandingStatus.goodStanding;
    }
  }

  double? _toDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

final gradesServiceProvider =
    Provider<GradesService>((ref) => GradesService(ref.watch(dioProvider)));
