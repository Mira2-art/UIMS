import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/grades_mock.dart';

final academicYearsProvider = Provider<List<AcademicYearResult>>((ref) {
  // TODO(backend): GET /students/me/transcript (grouped by academic year/semester).
  return GradesMock.academicYears;
});

/// Number of fully-published (finalized) semesters — CGPA is shown from 2 up.
final finalizedTermCountProvider = Provider<int>((ref) {
  final years = ref.watch(academicYearsProvider);
  return years
      .expand((y) => y.terms)
      .where((t) => t.isPublished)
      .length;
});

/// Cumulative GPA (4.0) across every finalized course.
final cgpaProvider = Provider<double?>((ref) {
  final years = ref.watch(academicYearsProvider);
  var points = 0.0;
  var credits = 0;
  for (final year in years) {
    for (final term in year.terms) {
      for (final course in term.courses) {
        if (course.isFinalized) {
          points += course.gradePointValue! * course.credits;
          credits += course.credits;
        }
      }
    }
  }
  return credits == 0 ? null : points / credits;
});

final standingProvider = Provider<AcademicStandingSummary>((ref) {
  // TODO(backend): GET /students/me/academic-standing
  return GradesMock.standing;
});
