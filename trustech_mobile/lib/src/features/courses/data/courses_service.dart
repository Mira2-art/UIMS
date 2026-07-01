import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/client/dio_provider.dart';
import 'mock/courses_mock.dart';

class CoursesService {
  CoursesService(this._dio);
  final Dio _dio;

  /// GET /enrollments?student_id={id} → fetch each course → StudentCourse list.
  Future<MyCoursesState> myCourses(String studentId) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.enrollmentsForStudent(studentId),
    );
    final enrollments = (res.data ?? const []).cast<Map<String, dynamic>>();
    final courses = <StudentCourse>[];
    for (final e in enrollments) {
      if ((e['status'] as String?) == 'DROPPED' ||
          (e['status'] as String?) == 'WITHDRAWN') {
        continue;
      }
      final courseId = e['course_id'] as String?;
      if (courseId == null) continue;
      try {
        final c = (await _dio.get<Map<String, dynamic>>(
              ApiEndpoints.course(courseId),
            )).data ??
            const {};
        courses.add(StudentCourse(
          id: courseId,
          code: (c['code'] ?? '') as String,
          title: (c['title'] ?? '') as String,
          lecturer: '—',
          units: (c['credit_units'] ?? 0) as int,
          progress: 0,
          status: CourseStatus.enrolled,
        ));
      } on DioException {
        // Skip a course that can't be loaded.
      }
    }
    return MyCoursesState(isLoading: false, semester: 'Current Semester', courses: courses);
  }

  Future<CourseDetail?> detail(String courseId) async {
    final c = (await _dio.get<Map<String, dynamic>>(
          ApiEndpoints.course(courseId),
        )).data;
    if (c == null) return null;
    final materials = await this.materials(courseId);
    return CourseDetail(
      id: courseId,
      code: (c['code'] ?? '') as String,
      title: (c['title'] ?? '') as String,
      lecturer: '—',
      units: (c['credit_units'] ?? 0) as int,
      semester: '—',
      department: '—',
      description: (c['description'] as String?) ?? '',
      attendancePercent: 0,
      courseProgress: 0,
      currentGrade: '—',
      nextClass: '—',
      nextClassVenue: '—',
      scheduleSummary: '—',
      materialCount: materials.length,
      enrollmentCount: (c['current_enrollment'] ?? 0) as int,
      capacity: (c['max_capacity'] ?? 0) as int,
      recentMaterials: materials.take(3).toList(),
    );
  }

  Future<List<CourseMaterial>> materials(String courseId) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.courseMaterials(courseId),
    );
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map((m) => CourseMaterial(
              id: (m['material_id'] ?? '') as String,
              courseId: courseId,
              title: (m['title'] ?? '') as String,
              type: _materialType(m['material_type'] as String?),
              group: 'Materials',
              sizeLabel: (m['file_size']?.toString()) ?? '',
              updatedLabel: (m['created_at'] as String?)?.split('T').first ?? '',
              isNew: false,
            ))
        .toList();
  }

  /// GET /courses — catalog of courses available for registration.
  Future<List<AvailableCourse>> available() async {
    final res = await _dio.get<List<dynamic>>('/courses');
    return (res.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map((c) => AvailableCourse(
              id: (c['course_id'] ?? '') as String,
              code: (c['code'] ?? '') as String,
              title: (c['title'] ?? '') as String,
              lecturer: '—',
              units: (c['credit_units'] ?? 0) as int,
              capacityUsed: (c['current_enrollment'] ?? 0) as int,
              capacityTotal: (c['max_capacity'] ?? 1) as int,
              prerequisite: '—',
            ))
        .toList();
  }

  CourseMaterialType _materialType(String? t) {
    switch (t?.toUpperCase()) {
      case 'VIDEO':
        return CourseMaterialType.video;
      case 'ASSIGNMENT':
        return CourseMaterialType.assignment;
      case 'LINK':
        return CourseMaterialType.link;
      case 'SYLLABUS':
        return CourseMaterialType.syllabus;
      default:
        return CourseMaterialType.document;
    }
  }
}

final coursesServiceProvider =
    Provider<CoursesService>((ref) => CoursesService(ref.watch(dioProvider)));
