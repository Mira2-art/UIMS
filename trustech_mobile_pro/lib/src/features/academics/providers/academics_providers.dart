import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock/academics_mock.dart';

final facultiesProvider = Provider<List<Faculty>>((ref) {
  // TODO(backend): replace with /academics/faculties
  return AcademicsMock.faculties;
});

final departmentsProvider = Provider<List<Department>>((ref) {
  // TODO(backend): replace with /academics/departments
  return AcademicsMock.departments;
});

final programsProvider = Provider<List<Program>>((ref) {
  // TODO(backend): replace with /academics/programs
  return AcademicsMock.programs;
});

final filteredDepartmentsProvider = Provider.family<List<Department>, String?>((ref, facultyId) {
  final all = ref.watch(departmentsProvider);
  if (facultyId == null) return all;
  return all.where((d) => d.facultyId == facultyId).toList();
});

final curriculaProvider = Provider<List<ProgramCurriculum>>((ref) {
  // TODO(backend): replace with /academics/curricula
  return AcademicsMock.curricula;
});

final programCurriculumProvider = Provider.family<ProgramCurriculum?, String>((ref, programId) {
  final all = ref.watch(curriculaProvider);
  final matches = all.where((c) => c.programId == programId);
  return matches.isEmpty ? null : matches.first;
});

final catalogCoursesProvider = Provider<List<CatalogCourse>>((ref) {
  // TODO(backend): replace with /academics/courses
  return AcademicsMock.catalogCourses;
});

final catalogCourseDetailProvider = Provider.family<CatalogCourse?, String>((ref, id) {
  final all = ref.watch(catalogCoursesProvider);
  final matches = all.where((c) => c.id == id);
  return matches.isEmpty ? null : matches.first;
});

final filteredProgramsProvider = Provider.family<List<Program>, String?>((ref, deptId) {
  final all = ref.watch(programsProvider);
  if (deptId == null) return all;
  return all.where((p) => p.deptId == deptId).toList();
});
