import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/people_mock.dart';

final lecturersProvider = Provider<List<LecturerProfile>>((ref) {
  // TODO(backend): replace with /staff/people/lecturers.
  return PeopleMock.lecturers;
});

final lecturerProvider = Provider.family<LecturerProfile?, String>((
  ref,
  lecturerId,
) {
  final lecturers = ref.watch(lecturersProvider);
  for (final lecturer in lecturers) {
    if (lecturer.id == lecturerId) return lecturer;
  }
  return lecturers.isEmpty ? null : lecturers.first;
});
