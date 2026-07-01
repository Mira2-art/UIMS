import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';
import '../data/courses_service.dart';
import '../data/mock/courses_mock.dart';

String _sid(Ref ref) {
  final sid = ref.watch(studentIdProvider);
  if (sid == null) throw StateError('No active student session');
  return sid;
}

/// GET /enrollments?student_id={id} (+ course lookups).
final myCoursesProvider = FutureProvider<MyCoursesState>((ref) =>
    ref.watch(coursesServiceProvider).myCourses(_sid(ref)));

/// GET /courses/{id}.
final courseDetailProvider = FutureProvider.family<CourseDetail?, String>(
    (ref, id) => ref.watch(coursesServiceProvider).detail(id));

/// GET /courses/{id}/materials.
final courseMaterialsProvider = FutureProvider.family<List<CourseMaterial>, String>(
    (ref, id) => ref.watch(coursesServiceProvider).materials(id));

/// No per-course attendance endpoint for students yet → empty until wired.
final courseAttendanceProvider =
    FutureProvider.family<CourseAttendanceSummary?, String>((ref, id) async => null);

/// Registration window has no backend endpoint — static config (allowed: no endpoint).
final registrationWindowProvider = Provider<RegistrationWindow>((ref) {
  return CoursesMock.registrationWindow;
});

/// GET /courses (catalog) — available for registration.
final availableCoursesProvider = FutureProvider<List<AvailableCourse>>((ref) =>
    ref.watch(coursesServiceProvider).available());
