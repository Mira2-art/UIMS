import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';
import '../data/mock/profile_mock.dart';

/// Builds the profile view from the authenticated session (GET /users/me).
/// Fields the backend doesn't expose yet are left as placeholders.
final userProfileProvider = Provider<UserProfile>((ref) {
  final u = ref.watch(sessionProvider).user;
  if (u == null) return ProfileMock.currentUser;
  return UserProfile(
    id: u.userId,
    fullName: u.fullName,
    email: u.email,
    phoneNumber: u.phone ?? '—',
    birthday: DateTime(2000),
    studentId: '—',
    major: '—',
    academicAdvisor: '—',
    enrollmentYear: '—',
    expectedGraduation: '—',
    avatarUrl: '',
  );
});
