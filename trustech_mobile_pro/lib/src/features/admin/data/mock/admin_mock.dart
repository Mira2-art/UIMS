enum UserStatus {
  active,
  suspended,
  deactivated;

  String get label => name.toUpperCase();
}

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final UserStatus status;
  final DateTime lastActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastActive,
  });
}

class Role {
  final String id;
  final String name;
  final List<String> permissions;
  final int userCount;
  final String category;

  const Role({
    required this.id,
    required this.name,
    required this.permissions,
    this.userCount = 0,
    this.category = 'General',
  });
}

class AuditLog {
  final String id;
  final String action;
  final String user;
  final DateTime timestamp;
  final String severity; // 'Info', 'Warning', 'Critical'

  const AuditLog({
    required this.id,
    required this.action,
    required this.user,
    required this.timestamp,
    required this.severity,
  });
}

class SystemConfig {
  final String id;
  final String name;
  final String value;
  final String description;

  const SystemConfig({
    required this.id,
    required this.name,
    required this.value,
    required this.description,
  });
}

class EmailLog {
  final String id;
  final String recipient;
  final String subject;
  final String status; // 'Delivered', 'Failed'
  final DateTime timestamp;

  const EmailLog({
    required this.id,
    required this.recipient,
    required this.subject,
    required this.status,
    required this.timestamp,
  });
}

class AdminMock {
  static final users = [
    User(
      id: 'u1',
      name: 'Alex Thompson',
      email: 'alex@trustech.edu',
      role: 'Finance Officer',
      status: UserStatus.active,
      lastActive: DateTime(2023, 10, 26),
    ),
    User(
      id: 'u2',
      name: 'Maria Chen',
      email: 'maria@trustech.edu',
      role: 'Registrar',
      status: UserStatus.active,
      lastActive: DateTime(2023, 10, 25),
    ),
    User(
      id: 'u3',
      name: 'Julian Martinez',
      email: 'julian@trustech.edu',
      role: 'Teaching Staff',
      status: UserStatus.suspended,
      lastActive: DateTime(2023, 9, 15),
    ),
  ];

  static const roles = [
    Role(id: 'r1', name: 'Senior Administrator', userCount: 4, category: 'System', permissions: ['admin:all', 'users:manage', 'configs:manage']),
    Role(id: 'r2', name: 'Registrar', userCount: 12, category: 'Academic', permissions: ['academics:view', 'students:view']),
    Role(id: 'r3', name: 'Finance Officer', userCount: 2, category: 'Management', permissions: ['finance:view', 'finance:manage', 'reports:view']),
    Role(id: 'r4', name: 'Department Head', userCount: 18, category: 'Management', permissions: ['reports:view', 'staff:view']),
  ];

  static final auditLogs = [
    AuditLog(id: 'a1', action: 'User suspension: Julian Martinez', user: 'Admin User', timestamp: DateTime.now().subtract(const Duration(hours: 1)), severity: 'Warning'),
    AuditLog(id: 'a2', action: 'System configuration update: Fee Structure', user: 'Admin User', timestamp: DateTime.now().subtract(const Duration(hours: 3)), severity: 'Info'),
    AuditLog(id: 'a3', action: 'Unauthorized access attempt', user: 'System', timestamp: DateTime.now().subtract(const Duration(days: 1)), severity: 'Critical'),
  ];

  static const systemConfigs = [
    SystemConfig(id: 'c1', name: 'App Version', value: '2.4.1', description: 'Current production version'),
    SystemConfig(id: 'c2', name: 'Max File Upload Size', value: '10MB', description: 'Limit for student file attachments'),
    SystemConfig(id: 'c3', name: 'Maintenance Mode', value: 'Disabled', description: 'System-wide maintenance status'),
  ];

  static final emailLogs = [
    EmailLog(id: 'e1', recipient: 'student1@trustech.edu', subject: 'Registration Confirmed', status: 'Delivered', timestamp: DateTime.now()),
    EmailLog(id: 'e2', recipient: 'student2@trustech.edu', subject: 'Waitlist Notification', status: 'Failed', timestamp: DateTime.now().subtract(const Duration(minutes: 30))),
  ];
}
