import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock/profile_mock.dart';

final userProfileProvider = Provider((ref) {
  // TODO(backend): replace with /auth/profile
  return ProfileMock.currentUser;
});
