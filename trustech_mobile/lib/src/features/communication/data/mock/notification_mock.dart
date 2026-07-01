enum NotificationCategory {
  courses,
  grades,
  finance,
  security;

  String get label {
    switch (this) {
      case NotificationCategory.courses:
        return 'Courses';
      case NotificationCategory.grades:
        return 'Grades';
      case NotificationCategory.finance:
        return 'Finance';
      case NotificationCategory.security:
        return 'Security';
    }
  }
}

class TrustechNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationCategory category;
  final bool isRead;
  final String? actionLabel;

  const TrustechNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    this.isRead = false,
    this.actionLabel,
  });

  TrustechNotification copyWith({bool? isRead}) {
    return TrustechNotification(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      category: category,
      isRead: isRead ?? this.isRead,
      actionLabel: actionLabel,
    );
  }
}

class NotificationMock {
  static final notifications = [
    TrustechNotification(
      id: '1',
      title: 'New Grade Released',
      message: 'Your final grade for Advanced Microeconomics has been published. You achieved an A-.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: NotificationCategory.grades,
      actionLabel: 'View Feedback',
    ),
    TrustechNotification(
      id: '2',
      title: 'Course Material Added',
      message: 'Professor Aris added "Lecture 12 - Market Equilibrium.pdf" to the course dashboard.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      category: NotificationCategory.courses,
    ),
    TrustechNotification(
      id: '3',
      title: 'Payment Successful',
      message: 'The payment for Semester 2 Library Fees (\$14.50) was processed successfully.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: NotificationCategory.finance,
      isRead: true,
    ),
    TrustechNotification(
      id: '4',
      title: 'Security Alert',
      message: 'Your password was changed successfully. If you did not make this change, contact support immediately.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      category: NotificationCategory.security,
      isRead: true,
    ),
  ];
}
