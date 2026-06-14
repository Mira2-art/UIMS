enum AcademicStatus {
  active,
  inactive;

  String get label => name.toUpperCase();
}

enum CourseStatus {
  open,
  full,
  waitlist;

  String get label => name.toUpperCase();
}

class Faculty {
  final String id;
  final String name;
  final String code;
  final String dean;
  final AcademicStatus status;

  const Faculty({
    required this.id,
    required this.name,
    required this.code,
    required this.dean,
    this.status = AcademicStatus.active,
  });
}

class Department {
  final String id;
  final String name;
  final String code;
  final String facultyId;
  final String hod;
  final AcademicStatus status;

  const Department({
    required this.id,
    required this.name,
    required this.code,
    required this.facultyId,
    required this.hod,
    this.status = AcademicStatus.active,
  });
}

class Program {
  final String id;
  final String name;
  final String code;
  final String deptId;
  final int duration;
  final int totalCredits;
  final String awardType;
  final AcademicStatus status;

  const Program({
    required this.id,
    required this.name,
    required this.code,
    required this.deptId,
    required this.duration,
    required this.totalCredits,
    required this.awardType,
    this.status = AcademicStatus.active,
  });
}

class CurriculumCourse {
  final String code;
  final String title;
  final int units;
  final bool isCore;

  const CurriculumCourse({
    required this.code,
    required this.title,
    required this.units,
    this.isCore = true,
  });
}

class CurriculumSemester {
  final int number;
  final List<CurriculumCourse> courses;

  const CurriculumSemester({
    required this.number,
    required this.courses,
  });

  int get totalUnits => courses.fold(0, (sum, c) => sum + c.units);
}

class CurriculumLevel {
  final int level;
  final String description;
  final List<CurriculumSemester> semesters;

  const CurriculumLevel({
    required this.level,
    required this.description,
    required this.semesters,
  });
}

class ProgramCurriculum {
  final String programId;
  final String year;
  final List<CurriculumLevel> levels;

  const ProgramCurriculum({
    required this.programId,
    required this.year,
    required this.levels,
  });
}

class CatalogSlot {
  final String day;
  final String time;
  final String venue;
  final String type;

  const CatalogSlot({
    required this.day,
    required this.time,
    required this.venue,
    required this.type,
  });
}

class CatalogPrereq {
  final String code;
  final String label;

  const CatalogPrereq({required this.code, required this.label});
}

class CatalogCourse {
  final String id;
  final String code;
  final String title;
  final double units;
  final String programName;
  final int capacity;
  final int availableSeats;
  final String lecturer;
  final CourseStatus status;
  final String? description;
  final String? syllabus;
  final List<String> outcomes;
  final List<CatalogSlot> timetable;
  final List<CatalogPrereq> prerequisites;
  final String? lecturerTitle;
  final String? lecturerBio;
  final String? lecturerEmail;

  const CatalogCourse({
    required this.id,
    required this.code,
    required this.title,
    required this.units,
    required this.programName,
    required this.capacity,
    required this.availableSeats,
    required this.lecturer,
    this.status = CourseStatus.open,
    this.description,
    this.syllabus,
    this.outcomes = const [],
    this.timetable = const [],
    this.prerequisites = const [],
    this.lecturerTitle,
    this.lecturerBio,
    this.lecturerEmail,
  });
}

class AcademicsMock {
  static const faculties = [
    Faculty(
      id: 'f1',
      name: 'Faculty of Engineering',
      code: 'ENG',
      dean: 'Prof. John Smith',
    ),
    Faculty(
      id: 'f2',
      name: 'Faculty of Science',
      code: 'SCI',
      dean: 'Prof. Sarah Jenkins',
    ),
    Faculty(
      id: 'f3',
      name: 'Faculty of Arts & Humanities',
      code: 'ART',
      dean: 'Prof. Michael Brown',
    ),
  ];

  static const departments = [
    Department(
      id: 'd1',
      name: 'Computer Science',
      code: 'CS',
      facultyId: 'f2',
      hod: 'Dr. Alan Turing',
    ),
    Department(
      id: 'd2',
      name: 'Electrical Engineering',
      code: 'EE',
      facultyId: 'f1',
      hod: 'Dr. Nikola Tesla',
    ),
    Department(
      id: 'd3',
      name: 'Mechanical Engineering',
      code: 'ME',
      facultyId: 'f1',
      hod: 'Dr. James Watt',
    ),
  ];

  static const programs = [
    Program(
      id: 'p1',
      name: 'B.Sc. Computer Science',
      code: 'BSCCS',
      deptId: 'd1',
      duration: 4,
      totalCredits: 120,
      awardType: 'B.Sc.',
    ),
    Program(
      id: 'p2',
      name: 'B.Eng. Electrical Engineering',
      code: 'BEE',
      deptId: 'd2',
      duration: 5,
      totalCredits: 150,
      awardType: 'B.Eng.',
    ),
  ];

  static const curricula = [
    ProgramCurriculum(
      programId: 'p1',
      year: '2024/2025',
      levels: [
        CurriculumLevel(
          level: 100,
          description: 'Foundation Year',
          semesters: [
            CurriculumSemester(
              number: 1,
              courses: [
                CurriculumCourse(code: 'CSC 101', title: 'Introduction to Computing', units: 3),
                CurriculumCourse(code: 'MAT 101', title: 'Algebra & Trigonometry', units: 3),
              ],
            ),
            CurriculumSemester(
              number: 2,
              courses: [
                CurriculumCourse(code: 'CSC 102', title: 'Structured Programming', units: 3),
                CurriculumCourse(code: 'GNS 102', title: 'Communication in English', units: 2, isCore: false),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  static const catalogCourses = [
    CatalogCourse(
      id: 'c1',
      code: 'CS-402',
      title: 'Advanced Machine Learning',
      units: 4.0,
      programName: 'Computer Science',
      capacity: 60,
      availableSeats: 0,
      lecturer: 'Dr. Alex Rivers',
      status: CourseStatus.full,
      description: 'Advanced study of heuristics, neural networks, and logic.',
      syllabus:
          'This course provides a comprehensive introduction to the fundamental principles, '
          'algorithms, and applications of machine learning — spanning classical techniques such '
          'as state-space search and logic-based systems, alongside modern deep learning and '
          'reinforcement learning.',
      outcomes: [
        'Expertise in Search Algorithms',
        'Neural Network Implementation',
        'Ethical Frameworks in AI',
        'Probabilistic Reasoning',
      ],
      timetable: [
        CatalogSlot(day: 'Monday', time: '10:00 - 11:30 AM', venue: 'Science Hall 4A', type: 'Lecture'),
        CatalogSlot(day: 'Wednesday', time: '10:00 - 11:30 AM', venue: 'Science Hall 4A', type: 'Lecture'),
        CatalogSlot(day: 'Friday', time: '02:00 - 04:00 PM', venue: 'CS Lab 02', type: 'Practical'),
      ],
      prerequisites: [
        CatalogPrereq(code: 'CS-201', label: 'Data Structures'),
        CatalogPrereq(code: 'CS-305', label: 'Discrete Math'),
        CatalogPrereq(code: 'MAT-102', label: 'Probability'),
      ],
      lecturerTitle: 'Senior Lecturer',
      lecturerBio:
          'Expert in Computer Vision and Ethics. Previously led the AI Research Wing at TechState University.',
      lecturerEmail: 'a.rivers@school.edu',
    ),
    CatalogCourse(
      id: 'c2',
      code: 'BIO-101',
      title: 'Intro to Cellular Biology',
      units: 3.0,
      programName: 'Natural Sciences',
      capacity: 100,
      availableSeats: 12,
      lecturer: 'Chen, Y.',
      status: CourseStatus.open,
    ),
    CatalogCourse(
      id: 'c3',
      code: 'LIT-220',
      title: 'Victorian Era Prose',
      units: 3.0,
      programName: 'Humanities',
      capacity: 30,
      availableSeats: 0,
      lecturer: 'Unassigned',
      status: CourseStatus.waitlist,
    ),
    CatalogCourse(
      id: 'c4',
      code: 'MAT-500',
      title: 'Stochastic Processes',
      units: 4.0,
      programName: 'Mathematics',
      capacity: 25,
      availableSeats: 5,
      lecturer: 'Sato, K.',
    ),
  ];
}
