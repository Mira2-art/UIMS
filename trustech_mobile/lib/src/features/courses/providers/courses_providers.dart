import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/courses_mock.dart';

final myCoursesProvider = Provider<MyCoursesState>((ref) {
  // TODO(backend): replace with /courses/my-current-semester
  return CoursesMock.myCoursesState;
});

final registrationWindowProvider = Provider<RegistrationWindow>((ref) {
  // TODO(backend): replace with /courses/registration-window
  return CoursesMock.registrationWindow;
});

final availableCoursesProvider = Provider<List<AvailableCourse>>((ref) {
  // TODO(backend): replace with /courses/available-for-registration
  return CoursesMock.availableCourses;
});

final courseDetailProvider = Provider.family<CourseDetail?, String>((ref, id) {
  // TODO(backend): replace with /courses/{id}
  return _findById(CoursesMock.courseDetails, id, (course) => course.id);
});

final courseMaterialsProvider = Provider.family<List<CourseMaterial>, String>((
  ref,
  id,
) {
  // TODO(backend): replace with /courses/{id}/materials
  return CoursesMock.courseMaterials
      .where((material) => material.courseId == id)
      .toList(growable: false);
});

final courseAttendanceProvider =
    Provider.family<CourseAttendanceSummary?, String>((ref, id) {
      // TODO(backend): replace with /courses/{id}/attendance
      return _findById(
        CoursesMock.attendanceSummaries,
        id,
        (summary) => summary.courseId,
      );
    });

T? _findById<T>(Iterable<T> records, String id, String Function(T record) key) {
  for (final record in records) {
    if (key(record) == id) return record;
  }
  return null;
}
