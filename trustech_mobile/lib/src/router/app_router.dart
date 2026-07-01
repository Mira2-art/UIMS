import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/session_controller.dart';
import '../features/shell/presentation/main_shell.dart';

// Auth / onboarding
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/verify_email_screen.dart';

// Home / tabs
import '../features/home/presentation/screens/home_screen.dart';
import '../features/timetable/presentation/screens/weekly_timetable_screen.dart';

// Courses
import '../features/courses/presentation/screens/my_courses_screen.dart';
import '../features/courses/presentation/screens/course_registration_screen.dart';
import '../features/courses/presentation/screens/course_detail_screen.dart';
import '../features/courses/presentation/screens/course_materials_screen.dart';
import '../features/courses/presentation/screens/course_attendance_screen.dart';

// Grades
import '../features/grades/presentation/screens/transcript_screen.dart';
import '../features/grades/presentation/screens/academic_standing_screen.dart';

// Finance
import '../features/finance/presentation/screens/finance_overview_screen.dart';
import '../features/finance/presentation/screens/charges_screen.dart';
import '../features/finance/presentation/screens/charge_detail_screen.dart';
import '../features/finance/presentation/screens/payments_screen.dart';
import '../features/finance/presentation/screens/scholarships_screen.dart';

// Communication
import '../features/communication/presentation/screens/announcements_screen.dart';
import '../features/communication/presentation/screens/announcement_detail_screen.dart';
import '../features/communication/presentation/screens/notifications_screen.dart';

// Profile
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';

/// App router.
///
/// Structure:
///  * Auth/onboarding routes render full-screen (outside the shell).
///  * The 5 bottom-nav tabs live in a [StatefulShellRoute.indexedStack] via
///    [MainShell] (each tab keeps its own stack).
///  * Detail / secondary screens are top-level routes on the root navigator, so
///    they push full-screen (back arrow, no bottom bar).
///
const _authLocations = {
  '/splash', '/welcome', '/login', '/forgot-password', '/reset-password', '/verify-email',
};

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirect whenever the session changes (login / logout / bootstrap).
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loc = state.matchedLocation;
      final onAuth = _authLocations.contains(loc);
      // Still bootstrapping → let the splash decide.
      if (session.status == AuthStatus.unknown) return null;
      if (!session.isAuthenticated && !onAuth) return '/welcome';
      if (session.isAuthenticated &&
          (loc == '/login' || loc == '/welcome' || loc == '/splash')) {
        return '/home';
      }
      return null;
    },
    routes: [
      // ── Auth / onboarding (full-screen) ──────────────────────────────────
      GoRoute(path: '/splash', name: 'splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/welcome', name: 'welcome', builder: (c, s) => const WelcomeScreen()),
      GoRoute(path: '/login', name: 'login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/forgot-password', name: 'forgot-password', builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', name: 'reset-password', builder: (c, s) => const ResetPasswordScreen()),
      GoRoute(path: '/verify-email', name: 'verify-email', builder: (c, s) => const VerifyEmailScreen()),

      // ── Bottom-nav shell (5 tabs) ────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', name: 'home', builder: (c, s) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/courses', name: 'courses', builder: (c, s) => const MyCoursesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/grades', name: 'grades', builder: (c, s) => const TranscriptScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/finance', name: 'finance', builder: (c, s) => const FinanceOverviewScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', name: 'profile', builder: (c, s) => const ProfileScreen()),
          ]),
        ],
      ),

      // ── Detail / secondary (full-screen, root navigator) ─────────────────
      GoRoute(path: '/home/timetable', name: 'timetable', builder: (c, s) => const WeeklyTimetableScreen()),

      GoRoute(path: '/courses/register', name: 'course-register', builder: (c, s) => const CourseRegistrationScreen()),
      GoRoute(path: '/courses/:id', name: 'course-detail', builder: (c, s) => CourseDetailScreen(courseId: s.pathParameters['id']!)),
      GoRoute(path: '/courses/:id/materials', name: 'course-materials', builder: (c, s) => CourseMaterialsScreen(courseId: s.pathParameters['id']!)),
      GoRoute(path: '/courses/:id/attendance', name: 'course-attendance', builder: (c, s) => CourseAttendanceScreen(courseId: s.pathParameters['id']!)),

      GoRoute(path: '/grades/standing', name: 'academic-standing', builder: (c, s) => const AcademicStandingScreen()),

      GoRoute(path: '/finance/charges', name: 'charges', builder: (c, s) => const ChargesScreen()),
      GoRoute(path: '/finance/charges/:id', name: 'charge-detail', builder: (c, s) => ChargeDetailScreen(chargeId: s.pathParameters['id']!)),
      GoRoute(path: '/finance/payments', name: 'payments', builder: (c, s) => const PaymentsScreen()),
      GoRoute(path: '/finance/scholarships', name: 'scholarships', builder: (c, s) => const ScholarshipsScreen()),

      GoRoute(path: '/announcements', name: 'announcements', builder: (c, s) => const AnnouncementsScreen()),
      GoRoute(path: '/announcements/:id', name: 'announcement-detail', builder: (c, s) => AnnouncementDetailScreen(announcementId: s.pathParameters['id']!)),
      GoRoute(path: '/notifications', name: 'notifications', builder: (c, s) => const NotificationsScreen()),

      GoRoute(path: '/settings', name: 'settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/change-password', name: 'change-password', builder: (c, s) => const ChangePasswordScreen()),
    ],
  );
});
