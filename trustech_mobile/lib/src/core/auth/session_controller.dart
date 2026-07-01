import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_service.dart';
import '../../shared/models/user.dart';
import '../network/api_endpoints.dart';
import '../network/client/dio_provider.dart';
import '../storage/secure_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class SessionState {
  const SessionState({this.status = AuthStatus.unknown, this.user, this.studentId});

  final AuthStatus status;
  final User? user;
  final String? studentId;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  SessionState copyWith({AuthStatus? status, User? user, String? studentId}) =>
      SessionState(
        status: status ?? this.status,
        user: user ?? this.user,
        studentId: studentId ?? this.studentId,
      );
}

/// Owns auth state: bootstraps from stored tokens on launch, logs in/out, and
/// resolves the student's identity (`user` + `studentId`) the data layer needs.
class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  /// Called on splash: if a token exists, fetch the profile + student id.
  /// Always resolves to authenticated/unauthenticated — never throws.
  Future<void> bootstrap() async {
    final store = ref.read(tokenStoreProvider);
    try {
      final token = await store.getAccessToken();
      if (token == null) {
        state = const SessionState(status: AuthStatus.unauthenticated);
        return;
      }
      await _loadIdentity();
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (_) {
      try {
        await store.clearTokens();
      } catch (_) {/* ignore storage errors (e.g. tests) */}
      state = const SessionState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    final tokens = await ref.read(authServiceProvider).login(email, password);
    await ref.read(tokenStoreProvider).saveTokens(
          tokens.access,
          refreshToken: tokens.refresh,
        );
    await _loadIdentity();
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    await ref.read(tokenStoreProvider).clearTokens();
    state = const SessionState(status: AuthStatus.unauthenticated);
  }

  /// GET /users/me + GET /students/me → populate the session.
  Future<void> _loadIdentity() async {
    final dio = ref.read(dioProvider);
    final me = await dio.get<Map<String, dynamic>>(ApiEndpoints.me);
    final user = User.fromJson(me.data ?? const {});
    String? studentId;
    try {
      final student = await dio.get<Map<String, dynamic>>(ApiEndpoints.studentMe);
      studentId = student.data?['student_id'] as String?;
    } catch (_) {
      // Non-student account (e.g. staff) — leave studentId null.
    }
    state = state.copyWith(user: user, studentId: studentId);
  }
}

final sessionProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Convenience: the resolved student id (throws-free; null until authenticated).
final studentIdProvider = Provider<String?>((ref) => ref.watch(sessionProvider).studentId);
