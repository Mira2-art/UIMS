enum LecturerStatus {
  active,
  leave,
  sabbatical;

  String get label => switch (this) {
    LecturerStatus.active => 'Active',
    LecturerStatus.leave => 'On Leave',
    LecturerStatus.sabbatical => 'Sabbatical',
  };
}

class LecturerProfile {
  const LecturerProfile({
    required this.id,
    required this.name,
    required this.staffId,
    required this.email,
    required this.phone,
    required this.department,
    required this.title,
    required this.rank,
    required this.courseLoad,
    required this.specialization,
    required this.status,
    required this.hireDate,
  });

  final String id;
  final String name;
  final String staffId;
  final String email;
  final String phone;
  final String department;
  final String title;
  final String rank;
  final int courseLoad;
  final String specialization;
  final LecturerStatus status;
  final String hireDate;
}

class PeopleMock {
  static const lecturers = [
    LecturerProfile(
      id: 'lec-001',
      name: 'Dr. Alan Turing',
      staffId: 'TRU/STAFF/001',
      email: 'alan.turing@example.edu',
      phone: '+233 24 200 0001',
      department: 'Computer Science',
      title: 'Dr.',
      rank: 'Senior Lecturer',
      courseLoad: 3,
      specialization: 'Algorithms and Computability',
      status: LecturerStatus.active,
      hireDate: '01 Sep 2020',
    ),
    LecturerProfile(
      id: 'lec-002',
      name: 'Prof. Grace Hopper',
      staffId: 'TRU/STAFF/002',
      email: 'grace.hopper@example.edu',
      phone: '+233 24 200 0002',
      department: 'Computer Science',
      title: 'Prof.',
      rank: 'Professor',
      courseLoad: 2,
      specialization: 'Compilers and Programming Languages',
      status: LecturerStatus.active,
      hireDate: '15 Jan 2018',
    ),
    LecturerProfile(
      id: 'lec-003',
      name: 'Dr. Katherine Johnson',
      staffId: 'TRU/STAFF/003',
      email: 'katherine.johnson@example.edu',
      phone: '+233 24 200 0003',
      department: 'Mathematics',
      title: 'Dr.',
      rank: 'Lecturer I',
      courseLoad: 1,
      specialization: 'Numerical Methods',
      status: LecturerStatus.leave,
      hireDate: '10 Mar 2021',
    ),
  ];
}
