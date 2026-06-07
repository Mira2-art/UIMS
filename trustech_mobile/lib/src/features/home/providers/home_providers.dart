import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/home_mock.dart';

final homeSummaryProvider = Provider<HomeSummary>((ref) {
  // TODO(backend): replace with standing, timetable, finance and announcements summary endpoints.
  return HomeMock.summary;
});
