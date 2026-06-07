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

class TranscriptSummary {
  const TranscriptSummary({
    required this.currentGpa,
    required this.cgpa,
    required this.creditsEarned,
    required this.creditsRequired,
    required this.status,
    required this.semesters,
  });

  final double currentGpa;
  final double cgpa;
  final int creditsEarned;
  final int creditsRequired;
  final StandingStatus status;
  final List<TranscriptSemester> semesters;

  double get creditProgress => creditsEarned / creditsRequired * 100;
}

class TranscriptSemester {
  const TranscriptSemester({
    required this.id,
    required this.label,
    required this.gpa,
    required this.credits,
    required this.courses,
  });

  final String id;
  final String label;
  final double gpa;
  final int credits;
  final List<TranscriptCourseGrade> courses;
}

class TranscriptCourseGrade {
  const TranscriptCourseGrade({
    required this.courseId,
    required this.code,
    required this.title,
    required this.credits,
    required this.score,
    required this.letterGrade,
    required this.remark,
  });

  final String courseId;
  final String code;
  final String title;
  final int credits;
  final double score;
  final String letterGrade;
  final String remark;
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
  static const transcript = TranscriptSummary(
    currentGpa: 3.85,
    cgpa: 3.72,
    creditsEarned: 104,
    creditsRequired: 120,
    status: StandingStatus.goodStanding,
    semesters: [
      TranscriptSemester(
        id: 'sem-2024-2',
        label: 'Semester 2 - 2024',
        gpa: 3.85,
        credits: 18,
        courses: [
          TranscriptCourseGrade(
            courseId: 'cs302',
            code: 'CS302',
            title: 'Advanced Algorithms and Complexity',
            credits: 4,
            score: 94,
            letterGrade: 'A',
            remark: 'Excellent',
          ),
          TranscriptCourseGrade(
            courseId: 'cs315',
            code: 'CS315',
            title: 'Database Systems',
            credits: 3,
            score: 89,
            letterGrade: 'A-',
            remark: 'Very Good',
          ),
          TranscriptCourseGrade(
            courseId: 'mth301',
            code: 'MTH301',
            title: 'Numerical Methods',
            credits: 3,
            score: 78,
            letterGrade: 'B+',
            remark: 'Good',
          ),
        ],
      ),
      TranscriptSemester(
        id: 'sem-2024-1',
        label: 'Semester 1 - 2024',
        gpa: 3.68,
        credits: 17,
        courses: [
          TranscriptCourseGrade(
            courseId: 'cs220',
            code: 'CS220',
            title: 'Object-Oriented Programming',
            credits: 4,
            score: 86,
            letterGrade: 'A-',
            remark: 'Very Good',
          ),
          TranscriptCourseGrade(
            courseId: 'sta204',
            code: 'STA204',
            title: 'Applied Statistics',
            credits: 3,
            score: 74,
            letterGrade: 'B',
            remark: 'Good',
          ),
          TranscriptCourseGrade(
            courseId: 'phy210',
            code: 'PHY210',
            title: 'Computational Physics',
            credits: 3,
            score: 81,
            letterGrade: 'B+',
            remark: 'Good',
          ),
        ],
      ),
    ],
  );

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
        'Your GPA remains above the good standing threshold and you are 16 credits away from graduation requirements.',
    history: [
      StandingHistoryItem(
        semester: 'Semester 2 - 2024',
        gpa: 3.85,
        credits: 18,
        status: StandingStatus.goodStanding,
      ),
      StandingHistoryItem(
        semester: 'Semester 1 - 2024',
        gpa: 3.68,
        credits: 17,
        status: StandingStatus.goodStanding,
      ),
      StandingHistoryItem(
        semester: 'Semester 2 - 2023',
        gpa: 3.92,
        credits: 18,
        status: StandingStatus.deansList,
      ),
      StandingHistoryItem(
        semester: 'Semester 1 - 2023',
        gpa: 3.58,
        credits: 15,
        status: StandingStatus.goodStanding,
      ),
    ],
  );
}
