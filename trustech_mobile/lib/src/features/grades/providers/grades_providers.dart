import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';
import '../data/grades_service.dart';
import '../data/mock/grades_mock.dart';

/// GET /students/{id}/results — grouped academic years + CGPA.
final transcriptProvider = FutureProvider<TranscriptData>((ref) async {
  final sid = ref.watch(studentIdProvider);
  if (sid == null) throw StateError('No active student session');
  return ref.watch(gradesServiceProvider).results(sid);
});

/// GET /students/{id}/standing.
final standingProvider = FutureProvider<AcademicStandingSummary>((ref) async {
  final sid = ref.watch(studentIdProvider);
  if (sid == null) throw StateError('No active student session');
  return ref.watch(gradesServiceProvider).standing(sid);
});
