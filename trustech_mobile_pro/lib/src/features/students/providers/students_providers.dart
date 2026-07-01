import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/students_mock.dart';

final studentsProvider = Provider<List<StudentProfile>>((ref) {
  // TODO(backend): replace with /staff/students.
  return StudentsMock.students;
});

final studentProvider = Provider.family<StudentProfile?, String>((
  ref,
  studentId,
) {
  final students = ref.watch(studentsProvider);
  for (final student in students) {
    if (student.id == studentId) return student;
  }
  return students.isEmpty ? null : students.first;
});

final enrollmentsProvider = Provider<List<EnrollmentRecord>>((ref) {
  // TODO(backend): replace with /staff/enrollments.
  return StudentsMock.enrollments;
});

final studentTranscriptProvider =
    Provider.family<List<TranscriptCourse>, String>((ref, studentId) {
      // TODO(backend): replace with /staff/students/{studentId}/transcript.
      return StudentsMock.transcriptCourses;
    });
