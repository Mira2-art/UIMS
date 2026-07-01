class TimetableDay {
  const TimetableDay({
    required this.id,
    required this.label,
    required this.dateLabel,
    required this.isToday,
    required this.entries,
  });

  final String id;
  final String label;
  final String dateLabel;
  final bool isToday;
  final List<TimetableEntry> entries;
}

class TimetableEntry {
  const TimetableEntry({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.timeRange,
    required this.startTime,
    required this.venue,
    required this.lecturer,
    required this.type,
    required this.isNow,
  });

  final String id;
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final String timeRange;
  final String startTime;
  final String venue;
  final String lecturer;
  final String type;
  final bool isNow;
}

class TimetableWeek {
  const TimetableWeek({
    required this.weekLabel,
    required this.activeDayId,
    required this.days,
  });

  final String weekLabel;
  final String activeDayId;
  final List<TimetableDay> days;
}

class TimetableMock {
  static const week = TimetableWeek(
    weekLabel: 'Week of Jul 18 - Jul 22',
    activeDayId: 'mon',
    days: [
      TimetableDay(
        id: 'mon',
        label: 'Mon',
        dateLabel: '18',
        isToday: true,
        entries: [
          TimetableEntry(
            id: 'tt-cs302-mon',
            courseId: 'cs302',
            courseCode: 'CS302',
            courseTitle: 'Advanced Algorithms and Complexity',
            timeRange: '09:00 - 10:30 AM',
            startTime: '09:00',
            venue: 'Hall B-12',
            lecturer: 'Dr. Alan Turing',
            type: 'Lecture',
            isNow: true,
          ),
          TimetableEntry(
            id: 'tt-mth301-mon',
            courseId: 'mth301',
            courseCode: 'MTH301',
            courseTitle: 'Numerical Methods',
            timeRange: '11:30 - 01:00 PM',
            startTime: '11:30',
            venue: 'Science Wing 4',
            lecturer: 'Dr. Katherine Johnson',
            type: 'Tutorial',
            isNow: false,
          ),
          TimetableEntry(
            id: 'tt-cs315-mon',
            courseId: 'cs315',
            courseCode: 'CS315',
            courseTitle: 'Database Systems Lab',
            timeRange: '02:00 - 04:00 PM',
            startTime: '14:00',
            venue: 'Database Lab 1',
            lecturer: 'Prof. Grace Hopper',
            type: 'Lab',
            isNow: false,
          ),
        ],
      ),
      TimetableDay(
        id: 'tue',
        label: 'Tue',
        dateLabel: '19',
        isToday: false,
        entries: [
          TimetableEntry(
            id: 'tt-cs302-tue',
            courseId: 'cs302',
            courseCode: 'CS302',
            courseTitle: 'Advanced Algorithms and Complexity',
            timeRange: '09:00 - 10:30 AM',
            startTime: '09:00',
            venue: 'LT 2, Science Block',
            lecturer: 'Dr. Alan Turing',
            type: 'Lecture',
            isNow: false,
          ),
        ],
      ),
      TimetableDay(
        id: 'wed',
        label: 'Wed',
        dateLabel: '20',
        isToday: false,
        entries: [
          TimetableEntry(
            id: 'tt-cs315-wed',
            courseId: 'cs315',
            courseCode: 'CS315',
            courseTitle: 'Database Systems',
            timeRange: '11:00 - 12:30 PM',
            startTime: '11:00',
            venue: 'Database Lab 1',
            lecturer: 'Prof. Grace Hopper',
            type: 'Lecture',
            isNow: false,
          ),
          TimetableEntry(
            id: 'tt-mth301-wed',
            courseId: 'mth301',
            courseCode: 'MTH301',
            courseTitle: 'Numerical Methods',
            timeRange: '03:00 - 04:30 PM',
            startTime: '15:00',
            venue: 'Math Hall A',
            lecturer: 'Dr. Katherine Johnson',
            type: 'Lecture',
            isNow: false,
          ),
        ],
      ),
      TimetableDay(
        id: 'thu',
        label: 'Thu',
        dateLabel: '21',
        isToday: false,
        entries: [],
      ),
      TimetableDay(
        id: 'fri',
        label: 'Fri',
        dateLabel: '22',
        isToday: false,
        entries: [
          TimetableEntry(
            id: 'tt-mth301-fri',
            courseId: 'mth301',
            courseCode: 'MTH301',
            courseTitle: 'Numerical Methods',
            timeRange: '08:00 - 09:30 AM',
            startTime: '08:00',
            venue: 'Math Hall A',
            lecturer: 'Dr. Katherine Johnson',
            type: 'Lecture',
            isNow: false,
          ),
        ],
      ),
    ],
  );
}
