class HomeSummary {
  const HomeSummary({
    required this.studentName,
    required this.program,
    required this.level,
    required this.gpa,
    required this.standing,
    required this.outstandingBalance,
    required this.todaysClasses,
    required this.announcements,
  });

  final String studentName;
  final String program;
  final String level;
  final double gpa;
  final String standing;
  final double outstandingBalance;
  final List<TodayClass> todaysClasses;
  final List<HomeAnnouncement> announcements;
}

class TodayClass {
  const TodayClass({
    required this.courseId,
    required this.code,
    required this.title,
    required this.time,
    required this.venue,
    required this.type,
  });

  final String courseId;
  final String code;
  final String title;
  final String time;
  final String venue;
  final String type;
}

class HomeAnnouncement {
  const HomeAnnouncement({
    required this.id,
    required this.category,
    required this.title,
    required this.excerpt,
  });

  final String id;
  final String category;
  final String title;
  final String excerpt;
}

class HomeMock {
  static const summary = HomeSummary(
    studentName: 'John Doe',
    program: 'Computer Science',
    level: '300 Level',
    gpa: 3.85,
    standing: 'Good Standing',
    outstandingBalance: 1250,
    todaysClasses: [
      TodayClass(
        courseId: 'cs302',
        code: 'CS302',
        title: 'Advanced Algorithms',
        time: '09:00 - 10:30',
        venue: 'LT 204',
        type: 'Lecture',
      ),
      TodayClass(
        courseId: 'cs315',
        code: 'CS315',
        title: 'Database Systems Lab',
        time: '13:00 - 15:00',
        venue: 'Lab 3B',
        type: 'Lab',
      ),
    ],
    announcements: [
      HomeAnnouncement(
        id: 'orientation-week',
        category: 'Academic',
        title: 'Mid-semester orientation briefing',
        excerpt:
            'Join the department briefing on academic standing and course planning.',
      ),
      HomeAnnouncement(
        id: 'library-hours',
        category: 'Campus',
        title: 'Library opens late this week',
        excerpt: 'Extended evening access is available during assessment week.',
      ),
      HomeAnnouncement(
        id: 'fees-reminder',
        category: 'Finance',
        title: 'Fee payment reminder',
        excerpt:
            'Outstanding balances should be settled before registration closes.',
      ),
    ],
  );
}
