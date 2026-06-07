/// Authenticated user profile, mirroring the backend `UserRead` schema
/// (`GET /users/me`).
class User {
  const User({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.status,
    required this.emailVerified,
  });

  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String status; // ACTIVE | INACTIVE | SUSPENDED | PENDING
  final bool emailVerified;

  String get fullName => '$firstName $lastName'.trim();

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['user_id'] as String,
        email: json['email'] as String,
        firstName: (json['first_name'] ?? '') as String,
        lastName: (json['last_name'] ?? '') as String,
        phone: json['phone'] as String?,
        status: (json['status'] ?? 'PENDING') as String,
        emailVerified: (json['email_verified'] ?? false) as bool,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'status': status,
        'email_verified': emailVerified,
      };
}
