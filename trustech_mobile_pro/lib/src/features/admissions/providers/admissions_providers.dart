import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/admissions_mock.dart';

final applicantsProvider = Provider<List<ApplicantProfile>>((ref) {
  // TODO(backend): replace with /staff/admissions/applicants.
  return AdmissionsMock.applicants;
});

final applicantProvider = Provider.family<ApplicantProfile?, String>((
  ref,
  applicantId,
) {
  final applicants = ref.watch(applicantsProvider);
  for (final applicant in applicants) {
    if (applicant.id == applicantId) return applicant;
  }
  return applicants.isEmpty ? null : applicants.first;
});
