enum StudentStatus {
  active,
  probation,
  suspended,
  alumni;

  String get label => switch (this) {
    StudentStatus.active => 'Active',
    StudentStatus.probation => 'Probation',
    StudentStatus.suspended => 'Suspended',
    StudentStatus.alumni => 'Alumni',
  };
}

class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.name,
    required this.matricNo,
    required this.email,
    required this.phone,
    required this.program,
    required this.department,
    required this.level,
    required this.cgpa,
    required this.attendanceRate,
    required this.feeStatus,
    required this.status,
    required this.enrollmentDate,
  });

  final String id;
  final String name;
  final String matricNo;
  final String email;
  final String phone;
  final String program;
  final String department;
  final String level;
  final double cgpa;
  final double attendanceRate;
  final String feeStatus;
  final StudentStatus status;
  final String enrollmentDate;
}

class EnrollmentRecord {
  const EnrollmentRecord({
    required this.id,
    required this.studentName,
    required this.program,
    required this.semester,
    required this.status,
    required this.credits,
  });

  final String id;
  final String studentName;
  final String program;
  final String semester;
  final String status;
  final int credits;
}

class TranscriptCourse {
  const TranscriptCourse({
    required this.code,
    required this.title,
    required this.credits,
    required this.grade,
    required this.points,
  });

  final String code;
  final String title;
  final int credits;
  final String grade;
  final double points;
}

class StudentsMock {
  static const students = [
    StudentProfile(
      id: 'stu-001',
      name: 'Amara Okafor',
      matricNo: 'TRU/CSC/23/001',
      email: 'amara.okafor@example.edu',
      phone: '+233 24 100 0101',
      program: 'B.Sc. Computer Science',
      department: 'Computer Science',
      level: '300 Level',
      cgpa: 4.23,
      attendanceRate: 96,
      feeStatus: 'Cleared',
      status: StudentStatus.active,
      enrollmentDate: '14 Sep 2023',
    ),
    StudentProfile(
      id: 'stu-002',
      name: 'Kelvin Mensah',
      matricNo: 'TRU/CSC/23/014',
      email: 'kelvin.mensah@example.edu',
      phone: '+233 24 100 0140',
      program: 'B.Sc. Computer Science',
      department: 'Computer Science',
      level: '300 Level',
      cgpa: 2.48,
      attendanceRate: 72,
      feeStatus: 'Partial',
      status: StudentStatus.probation,
      enrollmentDate: '14 Sep 2023',
    ),
    StudentProfile(
      id: 'stu-003',
      name: 'Fatima Bello',
      matricNo: 'TRU/CSC/23/026',
      email: 'fatima.bello@example.edu',
      phone: '+233 24 100 0260',
      program: 'B.Sc. Computer Science',
      department: 'Computer Science',
      level: '300 Level',
      cgpa: 3.86,
      attendanceRate: 89,
      feeStatus: 'Cleared',
      status: StudentStatus.active,
      enrollmentDate: '14 Sep 2023',
    ),
  ];

  static const enrollments = [
    EnrollmentRecord(
      id: 'enr-001',
      studentName: 'Amara Okafor',
      program: 'B.Sc. Computer Science',
      semester: '2026/2027 First Semester',
      status: 'Active',
      credits: 18,
    ),
    EnrollmentRecord(
      id: 'enr-002',
      studentName: 'Kelvin Mensah',
      program: 'B.Sc. Computer Science',
      semester: '2026/2027 First Semester',
      status: 'Active',
      credits: 15,
    ),
  ];

  static const transcriptCourses = [
    TranscriptCourse(
      code: 'CSC 301',
      title: 'Data Structures & Algorithms',
      credits: 3,
      grade: 'A',
      points: 5.0,
    ),
    TranscriptCourse(
      code: 'CSC 305',
      title: 'Operating Systems',
      credits: 3,
      grade: 'B+',
      points: 4.0,
    ),
    TranscriptCourse(
      code: 'MTH 301',
      title: 'Numerical Methods',
      credits: 2,
      grade: 'A',
      points: 5.0,
    ),
  ];
}
