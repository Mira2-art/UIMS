enum AnnouncementCategory {
  academic,
  event,
  campusLife;

  String get label {
    switch (this) {
      case AnnouncementCategory.academic:
        return 'ACADEMIC';
      case AnnouncementCategory.event:
        return 'EVENT';
      case AnnouncementCategory.campusLife:
        return 'CAMPUS LIFE';
    }
  }
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final DateTime date;
  final AnnouncementCategory category;
  final String? imageUrl;
  final bool isPinned;
  final bool isFeatured;
  final String author;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.date,
    required this.category,
    this.imageUrl,
    this.isPinned = false,
    this.isFeatured = false,
    required this.author,
  });
}

class CommunicationMock {
  static final announcements = [
    Announcement(
      id: '1',
      title: 'Annual Tech Symposium 2024',
      content: 'Register now for the biggest technology event of the semester featuring industry leaders from Google, Microsoft, and local startups. The event will include keynote speeches, workshops, and networking sessions.',
      excerpt: 'Register now for the biggest technology event of the semester featuring industry leaders.',
      date: DateTime(2023, 10, 24),
      category: AnnouncementCategory.event,
      isFeatured: true,
      author: 'Office of Student Affairs',
      imageUrl: 'https://images.unsplash.com/photo-1540575861501-7ad060e39fe5?auto=format&fit=crop&w=800&q=80',
    ),
    Announcement(
      id: '2',
      title: 'Spring Semester Registration',
      content: 'Course registration for the upcoming Spring 2024 semester begins next Monday at 8:00 AM. Please ensure your financial account is settled before attempting to register.',
      excerpt: 'Course registration for the upcoming Spring 2024 semester begins next Monday at 8:00 AM.',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      category: AnnouncementCategory.academic,
      author: 'Registrar Office',
    ),
    Announcement(
      id: '3',
      title: 'New Student Lounge Open',
      content: 'The renovated student hub in Building C is now open for group study and relaxation. Come check out the new ergonomic seating and high-speed Wi-Fi.',
      excerpt: 'The renovated student hub in Building C is now open for group study and relaxation.',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      category: AnnouncementCategory.campusLife,
      author: 'Campus Facilities',
    ),
    Announcement(
      id: '4',
      title: 'Career Fair: Tech Edition',
      content: 'Meet recruiters from top tech firms including Google, Microsoft, and local startups. Bring your CV and prepare for on-the-spot interviews.',
      excerpt: 'Meet recruiters from top tech firms including Google, Microsoft, and local startups.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: AnnouncementCategory.event,
      author: 'Career Center',
    ),
    Announcement(
      id: '5',
      title: 'Late Fee Waiver Period',
      content: 'Final chance to settle outstanding tuition balances without late penalties ends Friday. Please visit the Finance Office or use the app to pay.',
      excerpt: 'Final chance to settle outstanding tuition balances without late penalties ends Friday.',
      date: DateTime(2023, 10, 22),
      category: AnnouncementCategory.academic,
      author: 'Finance Office',
    ),
    Announcement(
      id: '6',
      title: 'Health & Wellness Week',
      content: 'Join us for free yoga sessions, nutrition workshops, and mental health screenings throughout this week in the Main Hall.',
      excerpt: 'Join us for free yoga sessions, nutrition workshops, and mental health screenings.',
      date: DateTime(2023, 10, 21),
      category: AnnouncementCategory.campusLife,
      author: 'Health Services',
    ),
  ];
}
