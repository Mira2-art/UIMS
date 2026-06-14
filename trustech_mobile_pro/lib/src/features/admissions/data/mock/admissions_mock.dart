enum ApplicantStatus {
  submitted,
  review,
  accepted,
  rejected,
  waitlisted;

  String get label => switch (this) {
    ApplicantStatus.submitted => 'Submitted',
    ApplicantStatus.review => 'Under Review',
    ApplicantStatus.accepted => 'Accepted',
    ApplicantStatus.rejected => 'Rejected',
    ApplicantStatus.waitlisted => 'Waitlisted',
  };
}

class ApplicantProfile {
  const ApplicantProfile({
    required this.id,
    required this.name,
    required this.applicationNo,
    required this.email,
    required this.program,
    required this.submittedAt,
    required this.status,
    required this.documentsVerified,
    required this.paymentStatus,
    required this.score,
  });

  final String id;
  final String name;
  final String applicationNo;
  final String email;
  final String program;
  final String submittedAt;
  final ApplicantStatus status;
  final int documentsVerified;
  final String paymentStatus;
  final double score;
}

class AdmissionsMock {
  static const applicants = [
    ApplicantProfile(
      id: 'app-001',
      name: 'Nadia Owusu',
      applicationNo: 'APP-2026-0001',
      email: 'nadia.owusu@example.com',
      program: 'B.Sc. Computer Science',
      submittedAt: '02 Jun 2026',
      status: ApplicantStatus.review,
      documentsVerified: 4,
      paymentStatus: 'Paid',
      score: 82,
    ),
    ApplicantProfile(
      id: 'app-002',
      name: 'Peter Chukwu',
      applicationNo: 'APP-2026-0002',
      email: 'peter.chukwu@example.com',
      program: 'B.Eng. Electrical Engineering',
      submittedAt: '04 Jun 2026',
      status: ApplicantStatus.accepted,
      documentsVerified: 5,
      paymentStatus: 'Paid',
      score: 91,
    ),
    ApplicantProfile(
      id: 'app-003',
      name: 'Aisha Kamara',
      applicationNo: 'APP-2026-0003',
      email: 'aisha.kamara@example.com',
      program: 'B.Sc. Data Science',
      submittedAt: '06 Jun 2026',
      status: ApplicantStatus.waitlisted,
      documentsVerified: 3,
      paymentStatus: 'Pending',
      score: 74,
    ),
  ];
}
