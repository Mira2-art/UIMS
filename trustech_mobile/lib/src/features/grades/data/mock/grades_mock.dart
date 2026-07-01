// Student grades model — mirrors the backend grading scheme:
// final course mark = CA (/30) + EXAM (/70) = /100 → letter; GPA on a 4.0 scale.
// Students only see a component once it is PUBLISHED. A semester's GPA shows once
// its exams are published (results finalized). CGPA is cumulative (from sem 2).

enum StandingStatus {
  goodStanding,
  deansList,
  probation;

  String get label {
    switch (this) {
      case StandingStatus.goodStanding:
        return 'GOOD STANDING';
      case StandingStatus.deansList:
        return "DEAN'S LIST";
      case StandingStatus.probation:
        return 'PROBATION';
    }
  }
}

/// Letter grade from a combined mark out of 100 (CA/30 + EXAM/70).
String gradeLetter(double total) {
  if (total >= 96) return 'A+';
  if (total >= 80) return 'A';
  if (total >= 70) return 'B+';
  if (total >= 60) return 'B';
  if (total >= 55) return 'C+';
  if (total >= 50) return 'C';
  if (total >= 45) return 'D+';
  if (total >= 40) return 'D';
  return 'F';
}

/// Grade point on a 4.0 scale.
double gradePoint(String letter) {
  switch (letter) {
    case 'A+':
    case 'A':
      return 4.0;
    case 'B+':
      return 3.5;
    case 'B':
      return 3.0;
    case 'C+':
      return 2.5;
    case 'C':
      return 2.0;
    case 'D+':
      return 1.5;
    case 'D':
      return 1.0;
    default:
      return 0.0;
  }
}

class CourseResult {
  const CourseResult({
    required this.courseId,
    required this.code,
    required this.title,
    required this.credits,
    required this.caScore,
    required this.examScore,
    this.caPublished = true,
    this.examPublished = false,
  });

  final String courseId;
  final String code;
  final String title;
  final int credits;
  final double caScore; // out of 30
  final double examScore; // out of 70
  final bool caPublished;
  final bool examPublished;

  /// A course is finalized once both components are published.
  bool get isFinalized => caPublished && examPublished;

  /// Combined mark out of 100 — only once finalized.
  double? get total => isFinalized ? caScore + examScore : null;
  String? get letter => total == null ? null : gradeLetter(total!);
  double? get gradePointValue => letter == null ? null : gradePoint(letter!);
}

class TermResult {
  const TermResult({
    required this.id,
    required this.number,
    required this.label,
    required this.courses,
  });

  final String id;
  final int number; // 1 or 2
  final String label; // e.g. 'First Semester'
  final List<CourseResult> courses;

  /// The semester is published (GPA visible) once every course is finalized.
  bool get isPublished =>
      courses.isNotEmpty && courses.every((c) => c.isFinalized);

  int get credits =>
      courses.where((c) => c.isFinalized).fold(0, (s, c) => s + c.credits);

  /// Semester GPA (4.0) — null until results are published.
  double? get gpa {
    if (!isPublished) return null;
    final finalized = courses.where((c) => c.isFinalized);
    var points = 0.0;
    var creditSum = 0;
    for (final c in finalized) {
      points += c.gradePointValue! * c.credits;
      creditSum += c.credits;
    }
    return creditSum == 0 ? null : points / creditSum;
  }
}

class AcademicYearResult {
  const AcademicYearResult({required this.year, required this.terms});

  final String year; // e.g. '2025/2026'
  final List<TermResult> terms;
}

class AcademicStandingSummary {
  const AcademicStandingSummary({
    required this.status,
    required this.currentGpa,
    required this.cgpa,
    required this.gpaChange,
    required this.creditsAttempted,
    required this.creditsEarned,
    required this.creditsRequired,
    required this.cohortRankLabel,
    required this.reason,
    required this.history,
  });

  final StandingStatus status;
  final double currentGpa;
  final double cgpa;
  final double gpaChange;
  final int creditsAttempted;
  final int creditsEarned;
  final int creditsRequired;
  final String cohortRankLabel;
  final String reason;
  final List<StandingHistoryItem> history;

  double get graduationProgress => creditsEarned / creditsRequired * 100;
}

class StandingHistoryItem {
  const StandingHistoryItem({
    required this.semester,
    required this.gpa,
    required this.credits,
    required this.status,
  });

  final String semester;
  final double gpa;
  final int credits;
  final StandingStatus status;
}

class GradesMock {
  // Newest year first. 2025/2026 S1 is published; S2 is current (CA only, exams
  // pending). 2024/2025 is fully published.
  static const academicYears = [
    AcademicYearResult(
      year: '2025/2026',
      terms: [
        TermResult(
          id: 'ay2025-s2',
          number: 2,
          label: 'Second Semester',
          courses: [
            CourseResult(
              courseId: 'cs420',
              code: 'CS420',
              title: 'Machine Learning',
              credits: 4,
              caScore: 25,
              examScore: 0,
              caPublished: true,
              examPublished: false,
            ),
            CourseResult(
              courseId: 'cs430',
              code: 'CS430',
              title: 'Information Security',
              credits: 3,
              caScore: 22,
              examScore: 0,
              caPublished: true,
              examPublished: false,
            ),
            CourseResult(
              courseId: 'gns402',
              code: 'GNS402',
              title: 'Entrepreneurship',
              credits: 2,
              caScore: 18,
              examScore: 0,
              caPublished: true,
              examPublished: false,
            ),
          ],
        ),
        TermResult(
          id: 'ay2025-s1',
          number: 1,
          label: 'First Semester',
          courses: [
            CourseResult(
              courseId: 'cs401',
              code: 'CS401',
              title: 'Advanced Artificial Intelligence',
              credits: 4,
              caScore: 27,
              examScore: 56,
              caPublished: true,
              examPublished: true,
            ),
            CourseResult(
              courseId: 'cs415',
              code: 'CS415',
              title: 'Distributed Systems',
              credits: 3,
              caScore: 24,
              examScore: 48,
              caPublished: true,
              examPublished: true,
            ),
            CourseResult(
              courseId: 'mth401',
              code: 'MTH401',
              title: 'Optimization Methods',
              credits: 3,
              caScore: 20,
              examScore: 41,
              caPublished: true,
              examPublished: true,
            ),
          ],
        ),
      ],
    ),
    AcademicYearResult(
      year: '2024/2025',
      terms: [
        TermResult(
          id: 'ay2024-s2',
          number: 2,
          label: 'Second Semester',
          courses: [
            CourseResult(
              courseId: 'cs320',
              code: 'CS320',
              title: 'Object-Oriented Programming',
              credits: 4,
              caScore: 25,
              examScore: 58,
              caPublished: true,
              examPublished: true,
            ),
            CourseResult(
              courseId: 'phy210',
              code: 'PHY210',
              title: 'Computational Physics',
              credits: 3,
              caScore: 21,
              examScore: 47,
              caPublished: true,
              examPublished: true,
            ),
            CourseResult(
              courseId: 'mth210',
              code: 'MTH210',
              title: 'Linear Algebra',
              credits: 3,
              caScore: 22,
              examScore: 50,
              caPublished: true,
              examPublished: true,
            ),
          ],
        ),
        TermResult(
          id: 'ay2024-s1',
          number: 1,
          label: 'First Semester',
          courses: [
            CourseResult(
              courseId: 'cs301',
              code: 'CS301',
              title: 'Data Structures & Algorithms',
              credits: 4,
              caScore: 26,
              examScore: 60,
              caPublished: true,
              examPublished: true,
            ),
            CourseResult(
              courseId: 'cs315',
              code: 'CS315',
              title: 'Database Systems',
              credits: 3,
              caScore: 23,
              examScore: 52,
              caPublished: true,
              examPublished: true,
            ),
            CourseResult(
              courseId: 'sta204',
              code: 'STA204',
              title: 'Applied Statistics',
              credits: 3,
              caScore: 19,
              examScore: 40,
              caPublished: true,
              examPublished: true,
            ),
          ],
        ),
      ],
    ),
  ];

  static const standing = AcademicStandingSummary(
    status: StandingStatus.goodStanding,
    currentGpa: 3.85,
    cgpa: 3.72,
    gpaChange: 0.05,
    creditsAttempted: 108,
    creditsEarned: 104,
    creditsRequired: 120,
    cohortRankLabel: 'Top 10% of cohort',
    reason:
        'Your CGPA remains above the good standing threshold and you are 16 credits away from graduation requirements.',
    history: [
      StandingHistoryItem(
        semester: 'Semester 1 - 2025/2026',
        gpa: 3.55,
        credits: 10,
        status: StandingStatus.goodStanding,
      ),
      StandingHistoryItem(
        semester: 'Semester 2 - 2024/2025',
        gpa: 3.60,
        credits: 10,
        status: StandingStatus.goodStanding,
      ),
      StandingHistoryItem(
        semester: 'Semester 1 - 2024/2025',
        gpa: 3.50,
        credits: 10,
        status: StandingStatus.goodStanding,
      ),
    ],
  );
}
