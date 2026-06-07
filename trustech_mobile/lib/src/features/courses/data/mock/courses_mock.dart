enum CourseStatus {
  active,
  available,
  enrolled;

  String get label => name.toUpperCase();
}

enum CourseMaterialType {
  document,
  video,
  assignment,
  link,
  syllabus;

  String get label {
    switch (this) {
      case CourseMaterialType.document:
        return 'Document';
      case CourseMaterialType.video:
        return 'Video';
      case CourseMaterialType.assignment:
        return 'Assignment';
      case CourseMaterialType.link:
        return 'Link';
      case CourseMaterialType.syllabus:
        return 'Syllabus';
    }
  }
}

enum AttendanceRecordStatus {
  present,
  late,
  absent,
  excused;

  String get label {
    switch (this) {
      case AttendanceRecordStatus.present:
        return 'Present';
      case AttendanceRecordStatus.late:
        return 'Late';
      case AttendanceRecordStatus.absent:
        return 'Absent';
      case AttendanceRecordStatus.excused:
        return 'Excused';
    }
  }
}

class StudentCourse {
  const StudentCourse({
    required this.id,
    required this.code,
    required this.title,
    required this.lecturer,
    required this.units,
    required this.progress,
    required this.status,
  });

  final String id;
  final String code;
  final String title;
  final String lecturer;
  final int units;
  final double progress;
  final CourseStatus status;
}

class RegistrationWindow {
  const RegistrationWindow({
    required this.isOpen,
    required this.phase,
    required this.semester,
    required this.message,
    required this.secondaryMessage,
  });

  final bool isOpen;
  final String phase;
  final String semester;
  final String message;
  final String secondaryMessage;
}

class AvailableCourse {
  const AvailableCourse({
    required this.id,
    required this.code,
    required this.title,
    required this.lecturer,
    required this.units,
    required this.capacityUsed,
    required this.capacityTotal,
    required this.prerequisite,
  });

  final String id;
  final String code;
  final String title;
  final String lecturer;
  final int units;
  final int capacityUsed;
  final int capacityTotal;
  final String prerequisite;

  double get capacityPercent => capacityUsed / capacityTotal * 100;
}

class CourseDetail {
  const CourseDetail({
    required this.id,
    required this.code,
    required this.title,
    required this.lecturer,
    required this.units,
    required this.semester,
    required this.department,
    required this.description,
    required this.attendancePercent,
    required this.courseProgress,
    required this.currentGrade,
    required this.nextClass,
    required this.nextClassVenue,
    required this.scheduleSummary,
    required this.materialCount,
    required this.enrollmentCount,
    required this.capacity,
    required this.recentMaterials,
  });

  final String id;
  final String code;
  final String title;
  final String lecturer;
  final int units;
  final String semester;
  final String department;
  final String description;
  final double attendancePercent;
  final double courseProgress;
  final String currentGrade;
  final String nextClass;
  final String nextClassVenue;
  final String scheduleSummary;
  final int materialCount;
  final int enrollmentCount;
  final int capacity;
  final List<CourseMaterial> recentMaterials;
}

class CourseMaterial {
  const CourseMaterial({
    required this.id,
    required this.courseId,
    required this.title,
    required this.type,
    required this.group,
    required this.sizeLabel,
    required this.updatedLabel,
    required this.isNew,
  });

  final String id;
  final String courseId;
  final String title;
  final CourseMaterialType type;
  final String group;
  final String sizeLabel;
  final String updatedLabel;
  final bool isNew;
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.dateLabel,
    required this.topic,
    required this.timeLabel,
    required this.status,
  });

  final String id;
  final String dateLabel;
  final String topic;
  final String timeLabel;
  final AttendanceRecordStatus status;
}

class CourseAttendanceSummary {
  const CourseAttendanceSummary({
    required this.courseId,
    required this.percent,
    required this.requiredPercent,
    required this.present,
    required this.late,
    required this.absent,
    required this.excused,
    required this.records,
  });

  final String courseId;
  final double percent;
  final double requiredPercent;
  final int present;
  final int late;
  final int absent;
  final int excused;
  final List<AttendanceRecord> records;

  int get total => present + late + absent + excused;
  bool get isBelowRequirement => percent < requiredPercent;
}

class MyCoursesState {
  const MyCoursesState({
    required this.isLoading,
    required this.semester,
    required this.courses,
  });

  final bool isLoading;
  final String semester;
  final List<StudentCourse> courses;
}

class CoursesMock {
  static const myCourses = [
    StudentCourse(
      id: 'cs302',
      code: 'CS302',
      title: 'Advanced Algorithms and Complexity',
      lecturer: 'Dr. Alan Turing',
      units: 4,
      progress: 75,
      status: CourseStatus.active,
    ),
    StudentCourse(
      id: 'cs315',
      code: 'CS315',
      title: 'Database Systems',
      lecturer: 'Prof. Grace Hopper',
      units: 3,
      progress: 62,
      status: CourseStatus.active,
    ),
    StudentCourse(
      id: 'mth301',
      code: 'MTH301',
      title: 'Numerical Methods',
      lecturer: 'Dr. Katherine Johnson',
      units: 3,
      progress: 48,
      status: CourseStatus.active,
    ),
  ];

  static const myCoursesState = MyCoursesState(
    isLoading: false,
    semester: 'Fall 2024',
    courses: myCourses,
  );

  static const registrationWindow = RegistrationWindow(
    isOpen: true,
    phase: 'Enrollment Phase 1',
    semester: "Summer Semester '24",
    message: 'Open now - closes in 4 days',
    secondaryMessage: 'Deadline: July 28, 11:59 PM',
  );

  static const availableCourses = [
    AvailableCourse(
      id: 'cs402',
      code: 'CS402',
      title: 'Software Engineering',
      lecturer: 'Dr. Sarah Smith',
      units: 3,
      capacityUsed: 85,
      capacityTotal: 100,
      prerequisite: 'CS302',
    ),
    AvailableCourse(
      id: 'cs420',
      code: 'CS420',
      title: 'Machine Learning',
      lecturer: 'Dr. Eleanor Vance',
      units: 4,
      capacityUsed: 42,
      capacityTotal: 60,
      prerequisite: 'MTH301',
    ),
    AvailableCourse(
      id: 'cs410',
      code: 'CS410',
      title: 'Cloud Computing',
      lecturer: 'Prof. Ada Lovelace',
      units: 3,
      capacityUsed: 56,
      capacityTotal: 80,
      prerequisite: 'CS315',
    ),
  ];

  static const courseMaterials = [
    CourseMaterial(
      id: 'mat-cs302-1',
      courseId: 'cs302',
      title: 'Course Syllabus and Assessment Guide',
      type: CourseMaterialType.syllabus,
      group: 'Course Essentials',
      sizeLabel: '1.2 MB',
      updatedLabel: 'Updated yesterday',
      isNew: true,
    ),
    CourseMaterial(
      id: 'mat-cs302-2',
      courseId: 'cs302',
      title: 'Week 01 - Graph Traversal Notes',
      type: CourseMaterialType.document,
      group: 'Lecture Notes',
      sizeLabel: '2.8 MB',
      updatedLabel: 'Jul 12',
      isNew: false,
    ),
    CourseMaterial(
      id: 'mat-cs302-3',
      courseId: 'cs302',
      title: 'Dynamic Programming Walkthrough',
      type: CourseMaterialType.video,
      group: 'Lecture Recordings',
      sizeLabel: '48 min',
      updatedLabel: 'Jul 15',
      isNew: false,
    ),
    CourseMaterial(
      id: 'mat-cs302-4',
      courseId: 'cs302',
      title: 'Assignment 2 - Complexity Proofs',
      type: CourseMaterialType.assignment,
      group: 'Assignments',
      sizeLabel: 'Due Jul 28',
      updatedLabel: 'Opened today',
      isNew: true,
    ),
    CourseMaterial(
      id: 'mat-cs315-1',
      courseId: 'cs315',
      title: 'Relational Model Quick Reference',
      type: CourseMaterialType.document,
      group: 'Lecture Notes',
      sizeLabel: '900 KB',
      updatedLabel: 'Jul 09',
      isNew: false,
    ),
    CourseMaterial(
      id: 'mat-mth301-1',
      courseId: 'mth301',
      title: 'Numerical Integration Practice Sheet',
      type: CourseMaterialType.assignment,
      group: 'Assignments',
      sizeLabel: 'Due Aug 02',
      updatedLabel: 'Jul 18',
      isNew: true,
    ),
  ];

  static const courseDetails = [
    CourseDetail(
      id: 'cs302',
      code: 'CS302',
      title: 'Advanced Algorithms and Complexity',
      lecturer: 'Dr. Alan Turing',
      units: 4,
      semester: 'Fall 2024',
      department: 'Computer Science',
      description:
          'A rigorous study of algorithm design patterns, asymptotic analysis, graph algorithms, dynamic programming and computational complexity.',
      attendancePercent: 72,
      courseProgress: 75,
      currentGrade: 'B+',
      nextClass: 'Tue, 9:00 AM',
      nextClassVenue: 'LT 2, Science Block',
      scheduleSummary: 'Tue / Thu, 9:00 AM - 10:30 AM',
      materialCount: 4,
      enrollmentCount: 82,
      capacity: 100,
      recentMaterials: [
        CourseMaterial(
          id: 'mat-cs302-1',
          courseId: 'cs302',
          title: 'Course Syllabus and Assessment Guide',
          type: CourseMaterialType.syllabus,
          group: 'Course Essentials',
          sizeLabel: '1.2 MB',
          updatedLabel: 'Updated yesterday',
          isNew: true,
        ),
        CourseMaterial(
          id: 'mat-cs302-4',
          courseId: 'cs302',
          title: 'Assignment 2 - Complexity Proofs',
          type: CourseMaterialType.assignment,
          group: 'Assignments',
          sizeLabel: 'Due Jul 28',
          updatedLabel: 'Opened today',
          isNew: true,
        ),
      ],
    ),
    CourseDetail(
      id: 'cs315',
      code: 'CS315',
      title: 'Database Systems',
      lecturer: 'Prof. Grace Hopper',
      units: 3,
      semester: 'Fall 2024',
      department: 'Computer Science',
      description:
          'Database design, SQL, normalization, indexing, transactions, relational constraints and practical PostgreSQL-backed application design.',
      attendancePercent: 88,
      courseProgress: 62,
      currentGrade: 'A-',
      nextClass: 'Wed, 11:00 AM',
      nextClassVenue: 'Database Lab 1',
      scheduleSummary: 'Mon / Wed, 11:00 AM - 12:30 PM',
      materialCount: 1,
      enrollmentCount: 76,
      capacity: 90,
      recentMaterials: [
        CourseMaterial(
          id: 'mat-cs315-1',
          courseId: 'cs315',
          title: 'Relational Model Quick Reference',
          type: CourseMaterialType.document,
          group: 'Lecture Notes',
          sizeLabel: '900 KB',
          updatedLabel: 'Jul 09',
          isNew: false,
        ),
      ],
    ),
    CourseDetail(
      id: 'mth301',
      code: 'MTH301',
      title: 'Numerical Methods',
      lecturer: 'Dr. Katherine Johnson',
      units: 3,
      semester: 'Fall 2024',
      department: 'Mathematics',
      description:
          'Numerical approximation methods, error analysis, linear systems, interpolation, differentiation and integration for applied computing.',
      attendancePercent: 69,
      courseProgress: 48,
      currentGrade: 'C+',
      nextClass: 'Fri, 8:00 AM',
      nextClassVenue: 'Math Hall A',
      scheduleSummary: 'Wed / Fri, 8:00 AM - 9:30 AM',
      materialCount: 1,
      enrollmentCount: 58,
      capacity: 70,
      recentMaterials: [
        CourseMaterial(
          id: 'mat-mth301-1',
          courseId: 'mth301',
          title: 'Numerical Integration Practice Sheet',
          type: CourseMaterialType.assignment,
          group: 'Assignments',
          sizeLabel: 'Due Aug 02',
          updatedLabel: 'Jul 18',
          isNew: true,
        ),
      ],
    ),
  ];

  static const attendanceSummaries = [
    CourseAttendanceSummary(
      courseId: 'cs302',
      percent: 72,
      requiredPercent: 75,
      present: 13,
      late: 2,
      absent: 5,
      excused: 1,
      records: [
        AttendanceRecord(
          id: 'att-cs302-1',
          dateLabel: 'Jul 22',
          topic: 'Complexity Classes',
          timeLabel: '9:00 AM',
          status: AttendanceRecordStatus.present,
        ),
        AttendanceRecord(
          id: 'att-cs302-2',
          dateLabel: 'Jul 18',
          topic: 'Dynamic Programming Review',
          timeLabel: '9:00 AM',
          status: AttendanceRecordStatus.late,
        ),
        AttendanceRecord(
          id: 'att-cs302-3',
          dateLabel: 'Jul 15',
          topic: 'Greedy Algorithms',
          timeLabel: '9:00 AM',
          status: AttendanceRecordStatus.absent,
        ),
        AttendanceRecord(
          id: 'att-cs302-4',
          dateLabel: 'Jul 11',
          topic: 'Graph Traversal',
          timeLabel: '9:00 AM',
          status: AttendanceRecordStatus.present,
        ),
      ],
    ),
    CourseAttendanceSummary(
      courseId: 'cs315',
      percent: 88,
      requiredPercent: 75,
      present: 16,
      late: 1,
      absent: 2,
      excused: 0,
      records: [
        AttendanceRecord(
          id: 'att-cs315-1',
          dateLabel: 'Jul 23',
          topic: 'Transactions and Locks',
          timeLabel: '11:00 AM',
          status: AttendanceRecordStatus.present,
        ),
        AttendanceRecord(
          id: 'att-cs315-2',
          dateLabel: 'Jul 21',
          topic: 'Indexing Strategies',
          timeLabel: '11:00 AM',
          status: AttendanceRecordStatus.present,
        ),
      ],
    ),
    CourseAttendanceSummary(
      courseId: 'mth301',
      percent: 69,
      requiredPercent: 75,
      present: 11,
      late: 2,
      absent: 6,
      excused: 0,
      records: [
        AttendanceRecord(
          id: 'att-mth301-1',
          dateLabel: 'Jul 19',
          topic: 'Numerical Integration',
          timeLabel: '8:00 AM',
          status: AttendanceRecordStatus.absent,
        ),
        AttendanceRecord(
          id: 'att-mth301-2',
          dateLabel: 'Jul 17',
          topic: 'Error Bounds',
          timeLabel: '8:00 AM',
          status: AttendanceRecordStatus.present,
        ),
      ],
    ),
  ];
}
