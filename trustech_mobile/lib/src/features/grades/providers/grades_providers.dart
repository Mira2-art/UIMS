import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/grades_mock.dart';

final transcriptProvider = Provider<TranscriptSummary>((ref) {
  // TODO(backend): replace with /students/me/transcript
  return GradesMock.transcript;
});

final standingProvider = Provider<AcademicStandingSummary>((ref) {
  // TODO(backend): replace with /students/me/academic-standing
  return GradesMock.standing;
});
