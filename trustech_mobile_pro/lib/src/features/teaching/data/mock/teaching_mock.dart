enum TeachingCourseStatus {
  active,
  draft,
  archived;

  String get label => switch (this) {
    TeachingCourseStatus.active => 'ACTIVE',
    TeachingCourseStatus.draft => 'DRAFT',
    TeachingCourseStatus.archived => 'ARCHIVED',
  };
}

enum RosterStanding {
  good,
  watchlist,
  probation;

  String get label => switch (this) {
    RosterStanding.good => 'Good',
    RosterStanding.watchlist => 'Watchlist',
    RosterStanding.probation => 'Probation',
  };
}

class TeachingCourse {
  const TeachingCourse({
    required this.id,
    required this.code,
    required this.title,
    required this.faculty,
    required this.department,
    required this.program,
    required this.level,
    required this.semester,
    required this.creditUnits,
    required this.studentCount,
    required this.capacity,
    required this.averageAttendance,
    required this.gradeCompletion,
    required this.nextClass,
    required this.venue,
    required this.status,
    required this.description,
    required this.outcomes,
  });

  final String id;
  final String code;
  final String title;
  final String faculty;
  final String department;
  final String program;
  final String level;
  final String semester;
  final int creditUnits;
  final int studentCount;
  final int capacity;
  final double averageAttendance;
  final double gradeCompletion;
  final String nextClass;
  final String venue;
  final TeachingCourseStatus status;
  final String description;
  final List<String> outcomes;
}

class CourseRosterStudent {
  const CourseRosterStudent({
    required this.id,
    required this.name,
    required this.matricNo,
    required this.program,
    required this.level,
    required this.attendanceRate,
    required this.currentScore,
    required this.standing,
    required this.lastSeen,
  });

  final String id;
  final String name;
  final String matricNo;
  final String program;
  final String level;
  final double attendanceRate;
  final double currentScore;
  final RosterStanding standing;
  final String lastSeen;
}

class CourseMaterial {
  const CourseMaterial({
    required this.id,
    required this.courseId,
    required this.title,
    required this.type,
    required this.sizeLabel,
    required this.publishedAt,
    required this.downloads,
    required this.isPublished,
  });

  final String id;
  final String courseId;
  final String title;
  final String type;
  final String sizeLabel;
  final String publishedAt;
  final int downloads;
  final bool isPublished;
}

class CourseTimetableEntry {
  const CourseTimetableEntry({
    required this.id,
    required this.courseId,
    required this.day,
    required this.time,
    required this.venue,
    required this.type,
    required this.note,
  });

  final String id;
  final String courseId;
  final String day;
  final String time;
  final String venue;
  final String type;
  final String note;
}

class AttendanceSession {
  const AttendanceSession({
    required this.id,
    required this.courseId,
    required this.title,
    required this.date,
    required this.time,
    required this.present,
    required this.late,
    required this.absent,
    required this.status,
  });

  final String id;
  final String courseId;
  final String title;
  final String date;
  final String time;
  final int present;
  final int late;
  final int absent;
  final String status;

  int get total => present + late + absent;

  double get attendanceRate =>
      total == 0 ? 0 : ((present + late) / total) * 100;
}

/// Grade components: CA is the lecturer's continuous assessment (caps at 30);
/// EXAM is the written exam (70), entered by the Faculty Dean / Secretariat.
enum GradeComponent { ca, exam }

class GradebookAssessment {
  const GradebookAssessment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.type,
    required this.maxScore,
    required this.weightPercent,
    required this.dueDate,
    required this.enteredCount,
    required this.totalStudents,
    required this.isPublished,
    this.component = GradeComponent.ca,
  });

  final String id;
  final String courseId;
  final String title;
  final String type;
  final double maxScore;
  final double weightPercent;
  final String dueDate;
  final int enteredCount;
  final int totalStudents;
  final bool isPublished;
  final GradeComponent component;

  bool get isExam => component == GradeComponent.exam;

  double get completionRate =>
      totalStudents == 0 ? 0 : (enteredCount / totalStudents) * 100;
}

class TeachingMock {
  static const courses = [
    TeachingCourse(
      id: 'csc301',
      code: 'CSC 301',
      title: 'Data Structures & Algorithms',
      faculty: 'Faculty of Science',
      department: 'Computer Science',
      program: 'B.Sc. Computer Science',
      level: '300 Level',
      semester: '2026/2027 First Semester',
      creditUnits: 3,
      studentCount: 84,
      capacity: 96,
      averageAttendance: 88,
      gradeCompletion: 62,
      nextClass: 'Mon, 09:00',
      venue: 'LT Block B',
      status: TeachingCourseStatus.active,
      description:
          'Analysis and implementation of core data structures, algorithmic strategies, and complexity trade-offs for production software.',
      outcomes: [
        'Model common data structures and justify trade-offs.',
        'Evaluate algorithm complexity using Big-O notation.',
        'Implement searching, sorting, trees, graphs, and hashing.',
      ],
    ),
    TeachingCourse(
      id: 'csc405',
      code: 'CSC 405',
      title: 'Distributed Systems',
      faculty: 'Faculty of Science',
      department: 'Computer Science',
      program: 'B.Sc. Computer Science',
      level: '400 Level',
      semester: '2026/2027 First Semester',
      creditUnits: 3,
      studentCount: 47,
      capacity: 60,
      averageAttendance: 74,
      gradeCompletion: 48,
      nextClass: 'Wed, 13:00',
      venue: 'Lab 3',
      status: TeachingCourseStatus.active,
      description:
          'Design of fault-tolerant distributed applications, messaging, consistency models, and service coordination.',
      outcomes: [
        'Explain consistency, consensus, and coordination trade-offs.',
        'Design resilient service boundaries and message flows.',
        'Evaluate distributed failures and recovery strategies.',
      ],
    ),
    TeachingCourse(
      id: 'csc212',
      code: 'CSC 212',
      title: 'Database Systems',
      faculty: 'Faculty of Science',
      department: 'Computer Science',
      program: 'B.Sc. Computer Science',
      level: '200 Level',
      semester: '2026/2027 First Semester',
      creditUnits: 2,
      studentCount: 112,
      capacity: 120,
      averageAttendance: 91,
      gradeCompletion: 79,
      nextClass: 'Fri, 11:00',
      venue: 'Auditorium 2',
      status: TeachingCourseStatus.active,
      description:
          'Relational database modelling, normalization, SQL querying, transactions, indexing, and application persistence.',
      outcomes: [
        'Design normalized relational schemas.',
        'Write safe transactional SQL for common workloads.',
        'Explain indexes, query plans, and integrity constraints.',
      ],
    ),
  ];

  static const roster = [
    CourseRosterStudent(
      id: 'stu-001',
      name: 'Amara Okafor',
      matricNo: 'TRU/CSC/23/001',
      program: 'B.Sc. Computer Science',
      level: '300 Level',
      attendanceRate: 96,
      currentScore: 82,
      standing: RosterStanding.good,
      lastSeen: 'Present last class',
    ),
    CourseRosterStudent(
      id: 'stu-002',
      name: 'Kelvin Mensah',
      matricNo: 'TRU/CSC/23/014',
      program: 'B.Sc. Computer Science',
      level: '300 Level',
      attendanceRate: 72,
      currentScore: 58,
      standing: RosterStanding.watchlist,
      lastSeen: 'Late last class',
    ),
    CourseRosterStudent(
      id: 'stu-003',
      name: 'Fatima Bello',
      matricNo: 'TRU/CSC/23/026',
      program: 'B.Sc. Computer Science',
      level: '300 Level',
      attendanceRate: 89,
      currentScore: 76,
      standing: RosterStanding.good,
      lastSeen: 'Present last class',
    ),
    CourseRosterStudent(
      id: 'stu-004',
      name: 'Daniel Njoroge',
      matricNo: 'TRU/CSC/23/031',
      program: 'B.Sc. Computer Science',
      level: '300 Level',
      attendanceRate: 61,
      currentScore: 44,
      standing: RosterStanding.probation,
      lastSeen: 'Absent last class',
    ),
    CourseRosterStudent(
      id: 'stu-005',
      name: 'Esi Boateng',
      matricNo: 'TRU/CSC/23/049',
      program: 'B.Sc. Computer Science',
      level: '300 Level',
      attendanceRate: 93,
      currentScore: 88,
      standing: RosterStanding.good,
      lastSeen: 'Present last class',
    ),
    CourseRosterStudent(
      id: 'stu-006',
      name: 'Samuel Adeyemi',
      matricNo: 'TRU/CSC/23/057',
      program: 'B.Sc. Computer Science',
      level: '300 Level',
      attendanceRate: 78,
      currentScore: 64,
      standing: RosterStanding.watchlist,
      lastSeen: 'Present last class',
    ),
  ];

  static const materials = [
    CourseMaterial(
      id: 'mat-001',
      courseId: 'csc301',
      title: 'Week 1 - Algorithm Analysis Slides',
      type: 'PDF',
      sizeLabel: '2.4 MB',
      publishedAt: '12 Jun 2026',
      downloads: 68,
      isPublished: true,
    ),
    CourseMaterial(
      id: 'mat-002',
      courseId: 'csc301',
      title: 'Binary Search Tree Walkthrough',
      type: 'VIDEO',
      sizeLabel: '18 min',
      publishedAt: '14 Jun 2026',
      downloads: 52,
      isPublished: true,
    ),
    CourseMaterial(
      id: 'mat-003',
      courseId: 'csc301',
      title: 'Assignment 1 - Sorting Benchmarks',
      type: 'ASSIGNMENT',
      sizeLabel: 'Due 28 Jun',
      publishedAt: '16 Jun 2026',
      downloads: 84,
      isPublished: true,
    ),
    CourseMaterial(
      id: 'mat-004',
      courseId: 'csc301',
      title: 'Graph Algorithms Reading Pack',
      type: 'LINK',
      sizeLabel: 'External',
      publishedAt: 'Draft',
      downloads: 0,
      isPublished: false,
    ),
  ];

  static const timetable = [
    CourseTimetableEntry(
      id: 'tt-001',
      courseId: 'csc301',
      day: 'Monday',
      time: '09:00 - 11:00',
      venue: 'LT Block B',
      type: 'Lecture',
      note: 'Core theory and worked examples',
    ),
    CourseTimetableEntry(
      id: 'tt-002',
      courseId: 'csc301',
      day: 'Wednesday',
      time: '14:00 - 16:00',
      venue: 'Lab 4',
      type: 'Practical',
      note: 'Implementation workshop',
    ),
    CourseTimetableEntry(
      id: 'tt-003',
      courseId: 'csc301',
      day: 'Friday',
      time: '10:00 - 11:00',
      venue: 'Tutorial Room 2',
      type: 'Tutorial',
      note: 'Problem-solving clinic',
    ),
  ];

  static const attendanceSessions = [
    AttendanceSession(
      id: 'att-001',
      courseId: 'csc301',
      title: 'Week 1 - Complexity Analysis',
      date: 'Mon, 15 Jun 2026',
      time: '09:00',
      present: 76,
      late: 5,
      absent: 3,
      status: 'Closed',
    ),
    AttendanceSession(
      id: 'att-002',
      courseId: 'csc301',
      title: 'Week 2 - Arrays and Linked Lists',
      date: 'Mon, 22 Jun 2026',
      time: '09:00',
      present: 71,
      late: 8,
      absent: 5,
      status: 'Closed',
    ),
    AttendanceSession(
      id: 'att-003',
      courseId: 'csc301',
      title: 'Week 3 - Stacks and Queues',
      date: 'Mon, 29 Jun 2026',
      time: '09:00',
      present: 0,
      late: 0,
      absent: 84,
      status: 'Open',
    ),
  ];

  // CA components weight to 30 (lecturer); the EXAM weights 70 (Dean/Secretariat).
  static const assessments = [
    GradebookAssessment(
      id: 'ass-001',
      courseId: 'csc301',
      title: 'Quiz 1 - Complexity',
      type: 'CA Quiz',
      maxScore: 10,
      weightPercent: 10,
      dueDate: '18 Jun 2026',
      enteredCount: 84,
      totalStudents: 84,
      isPublished: true,
    ),
    GradebookAssessment(
      id: 'ass-002',
      courseId: 'csc301',
      title: 'Assignment 1 - Sorting Benchmarks',
      type: 'CA Assignment',
      maxScore: 10,
      weightPercent: 10,
      dueDate: '28 Jun 2026',
      enteredCount: 64,
      totalStudents: 84,
      isPublished: false,
    ),
    GradebookAssessment(
      id: 'ass-003',
      courseId: 'csc301',
      title: 'Mid-Semester Test',
      type: 'CA Test',
      maxScore: 10,
      weightPercent: 10,
      dueDate: '10 Jul 2026',
      enteredCount: 0,
      totalStudents: 84,
      isPublished: false,
    ),
    GradebookAssessment(
      id: 'exam-001',
      courseId: 'csc301',
      title: 'Final Examination',
      type: 'EXAM',
      component: GradeComponent.exam,
      maxScore: 70,
      weightPercent: 70,
      dueDate: '02 Aug 2026',
      enteredCount: 0,
      totalStudents: 84,
      isPublished: false,
    ),
  ];
}
