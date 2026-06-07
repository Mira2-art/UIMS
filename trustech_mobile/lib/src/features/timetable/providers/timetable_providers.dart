import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/timetable_mock.dart';

final timetableProvider = Provider<TimetableWeek>((ref) {
  // TODO(backend): replace with /students/me/timetable/current-week
  return TimetableMock.week;
});
