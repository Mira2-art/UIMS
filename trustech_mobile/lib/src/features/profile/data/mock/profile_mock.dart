class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final DateTime birthday;
  final String studentId;
  final String major;
  final String academicAdvisor;
  final String enrollmentYear;
  final String expectedGraduation;
  final String avatarUrl;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.birthday,
    required this.studentId,
    required this.major,
    required this.academicAdvisor,
    required this.enrollmentYear,
    required this.expectedGraduation,
    required this.avatarUrl,
  });
}

class ProfileMock {
  static final currentUser = UserProfile(
    id: 'u1',
    fullName: 'Alex Thompson',
    email: 'a.thompson@trustech.edu',
    phoneNumber: '+1 (555) 234-8842',
    birthday: DateTime(2002, 5, 14),
    studentId: '2024-8842-UT',
    major: 'B.Eng. Computer Science',
    academicAdvisor: 'Dr. Elena Rodriguez',
    enrollmentYear: 'Fall 2024',
    expectedGraduation: 'June 2028',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCw_ktwTi2iX7iEz0mW2okZ-T0_EXfopI3KeMsbhFC7hrk_sStvN_Yc1LzXJ1W4sMSehnx4pCl1zn8fH_2DeD42fIevi4iYajbQY-FhgPlVkvGjEMA-OkrZ74Fu-Dajm-T8ZfMxE4ojuysfzqspywGiGm4KDMSh1w97Y1Ntprc2gyW-K8A-BOP4lcNTO4FBydN860J92aksA_dmdOnCDU3URB5HZoqZtMukCkcMyf9z_c5Z3tg0ChEvGoXdwU9D9zT91j8pTexWvS9T',
  );
}
