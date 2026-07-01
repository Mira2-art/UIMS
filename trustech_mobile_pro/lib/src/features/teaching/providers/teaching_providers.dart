import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/teaching_mock.dart';

final teachingCoursesProvider = Provider<List<TeachingCourse>>((ref) {
  // TODO(backend): replace with /staff/teaching/courses.
  return TeachingMock.courses;
});

final teachingCourseProvider = Provider.family<TeachingCourse?, String>((
  ref,
  courseId,
) {
  final courses = ref.watch(teachingCoursesProvider);
  for (final course in courses) {
    if (course.id == courseId) return course;
  }
  return courses.isEmpty ? null : courses.first;
});

final courseRosterProvider = Provider.family<List<CourseRosterStudent>, String>(
  (ref, courseId) {
    // TODO(backend): replace with /staff/teaching/courses/{courseId}/roster.
    return TeachingMock.roster;
  },
);

final courseMaterialsProvider = Provider.family<List<CourseMaterial>, String>((
  ref,
  courseId,
) {
  // TODO(backend): replace with /staff/teaching/courses/{courseId}/materials.
  return TeachingMock.materials
      .where((material) => material.courseId == courseId)
      .toList();
});

final courseTimetableProvider =
    Provider.family<List<CourseTimetableEntry>, String>((ref, courseId) {
      // TODO(backend): replace with /staff/teaching/courses/{courseId}/timetable.
      return TeachingMock.timetable
          .where((entry) => entry.courseId == courseId)
          .toList();
    });

final attendanceSessionsProvider =
    Provider.family<List<AttendanceSession>, String>((ref, courseId) {
      // TODO(backend): replace with /staff/teaching/courses/{courseId}/attendance.
      return TeachingMock.attendanceSessions
          .where((session) => session.courseId == courseId)
          .toList();
    });

final attendanceSessionProvider =
    Provider.family<AttendanceSession?, ({String courseId, String sessionId})>((
      ref,
      args,
    ) {
      final sessions = ref.watch(attendanceSessionsProvider(args.courseId));
      for (final session in sessions) {
        if (session.id == args.sessionId) return session;
      }
      return sessions.isEmpty ? null : sessions.first;
    });

final gradebookAssessmentsProvider =
    Provider.family<List<GradebookAssessment>, String>((ref, courseId) {
      // TODO(backend): replace with /staff/teaching/courses/{courseId}/gradebook.
      return TeachingMock.assessments
          .where((assessment) => assessment.courseId == courseId)
          .toList();
    });

final gradebookAssessmentProvider =
    Provider.family<
      GradebookAssessment?,
      ({String courseId, String assessmentId})
    >((ref, args) {
      final assessments = ref.watch(
        gradebookAssessmentsProvider(args.courseId),
      );
      for (final assessment in assessments) {
        if (assessment.id == args.assessmentId) return assessment;
      }
      return assessments.isEmpty ? null : assessments.first;
    });
