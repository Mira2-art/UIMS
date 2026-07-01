import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';
import '../data/mock/timetable_mock.dart';
import '../data/timetable_service.dart';

/// GET /students/{id}/timetable (grouped into a weekly view).
final timetableProvider = FutureProvider<TimetableWeek>((ref) {
  final sid = ref.watch(studentIdProvider);
  if (sid == null) throw StateError('No active student session');
  return ref.watch(timetableServiceProvider).week(sid);
});
