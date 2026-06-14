import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/shell/presentation/main_shell.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/communication/presentation/screens/announcement_detail_screen.dart';
import '../features/communication/presentation/screens/announcements_screen.dart';
import '../features/admissions/presentation/screens/applicant_convert_screen.dart';
import '../features/admissions/presentation/screens/applicant_detail_screen.dart';
import '../features/admissions/presentation/screens/applicant_status_screen.dart';
import '../features/admissions/presentation/screens/applicants_screen.dart';
import '../features/teaching/presentation/screens/attendance_mark_screen.dart';
import '../features/teaching/presentation/screens/attendance_records_screen.dart';
import '../features/teaching/presentation/screens/attendance_sessions_screen.dart';
import '../features/admin/presentation/screens/audit_log_detail_screen.dart';
import '../features/admin/presentation/screens/audit_logs_screen.dart';
import '../features/finance/presentation/screens/award_scholarship_screen.dart';
import '../features/finance/presentation/screens/bill_student_screen.dart';
import '../features/communication/presentation/screens/broadcast_notification_screen.dart';
import '../features/auth/presentation/screens/change_password_screen.dart';
import '../features/finance/presentation/screens/charge_detail_screen.dart';
import '../features/finance/presentation/screens/charges_screen.dart';
import '../features/communication/presentation/screens/compose_announcement_screen.dart';
import '../features/teaching/presentation/screens/course_announce_screen.dart';
import '../features/academics/presentation/screens/course_catalog_detail_screen.dart';
import '../features/academics/presentation/screens/course_catalog_screen.dart';
import '../features/teaching/presentation/screens/course_detail_screen.dart';
import '../features/teaching/presentation/screens/course_materials_screen.dart';
import '../features/teaching/presentation/screens/course_roster_screen.dart';
import '../features/teaching/presentation/screens/course_timetable_screen.dart';
import '../features/academics/presentation/screens/departments_screen.dart';
import '../features/admin/presentation/screens/email_logs_screen.dart';
import '../features/students/presentation/screens/enrollments_screen.dart';
import '../features/academics/presentation/screens/faculties_screen.dart';
import '../features/finance/presentation/screens/fee_structures_screen.dart';
import '../features/finance/presentation/screens/finance_reports_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/teaching/presentation/screens/exam_marks_screen.dart';
import '../features/teaching/presentation/screens/gradebook_assessments_screen.dart';
import '../features/teaching/presentation/screens/gradebook_scores_screen.dart';
import '../features/teaching/presentation/screens/grades_publish_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/people/presentation/screens/lecturer_detail_screen.dart';
import '../features/people/presentation/screens/lecturer_form_screen.dart';
import '../features/people/presentation/screens/lecturers_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/teaching/presentation/screens/my_courses_screen.dart';
import '../features/notifications/presentation/screens/notification_detail_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/finance/presentation/screens/payment_detail_screen.dart';
import '../features/finance/presentation/screens/payments_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/academics/presentation/screens/program_curriculum_screen.dart';
import '../features/academics/presentation/screens/programs_screen.dart';
import '../features/finance/presentation/screens/record_payment_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/admin/presentation/screens/roles_permissions_screen.dart';
import '../features/finance/presentation/screens/scholarships_screen.dart';
import '../features/academics/presentation/screens/semesters_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/students/presentation/screens/student_detail_screen.dart';
import '../features/students/presentation/screens/student_form_screen.dart';
import '../features/students/presentation/screens/student_transcript_screen.dart';
import '../features/students/presentation/screens/students_screen.dart';
import '../features/admin/presentation/screens/system_configs_screen.dart';
import '../features/admin/presentation/screens/user_detail_screen.dart';
import '../features/admin/presentation/screens/users_screen.dart';
import '../features/auth/presentation/screens/verify_email_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/workspace/presentation/screens/workspace_screen.dart';

/// Staff (Pro) app router.
///  * Auth routes render full-screen, outside the shell.
///  * ONLY the 4 bottom-nav tabs (Home / Workspace / Alerts / Profile) are
///    branches of a [StatefulShellRoute.indexedStack] — they carry the bottom bar.
///  * Every other module / detail / form screen is a top-level route on the ROOT
///    navigator, so it pushes full-screen (back arrow, no bottom bar) from the
///    Workspace grid or the drawer.
/// TODO(backend:) add an auth + role redirect guard once auth is wired.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    routes: [
      // ── Auth (outside shell) ──────────────────────────────────────────────
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/verify-email', builder: (context, state) => const VerifyEmailScreen()),

      // ── Bottom-nav shell: ONLY the 4 tab roots carry the bottom bar ───────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/workspace', builder: (context, state) => const WorkspaceScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),

      // ── Module / detail / form routes (ROOT navigator → full-screen, back, no bottom bar) ──
      // Teaching
      GoRoute(path: '/courses', builder: (context, state) => const MyCoursesScreen()),
      GoRoute(path: '/courses/:id', builder: (context, state) => CourseDetailScreen(courseId: state.pathParameters['id']!)),
      GoRoute(path: '/courses/:id/roster', builder: (context, state) => CourseRosterScreen(courseId: state.pathParameters['id']!)),
      GoRoute(path: '/courses/:id/materials', builder: (context, state) => CourseMaterialsScreen(courseId: state.pathParameters['id']!)),
      GoRoute(path: '/courses/:id/timetable', builder: (context, state) => CourseTimetableScreen(courseId: state.pathParameters['id']!)),
      GoRoute(path: '/courses/:id/attendance', builder: (context, state) => AttendanceSessionsScreen(courseId: state.pathParameters['id']!)),
      GoRoute(path: '/courses/:id/attendance/:sessionId', builder: (context, state) => AttendanceMarkScreen(courseId: state.pathParameters['id']!, sessionId: state.pathParameters['sessionId']!)),
      GoRoute(path: '/courses/:id/attendance/:sessionId/records', builder: (context, state) => AttendanceRecordsScreen(courseId: state.pathParameters['id']!, sessionId: state.pathParameters['sessionId']!)),
      GoRoute(path: '/courses/:id/gradebook', builder: (context, state) => GradebookAssessmentsScreen(courseId: state.pathParameters['id']!)),
      GoRoute(path: '/courses/:id/gradebook/:assessmentId', builder: (context, state) => GradebookScoresScreen(courseId: state.pathParameters['id']!, assessmentId: state.pathParameters['assessmentId']!)),
      GoRoute(path: '/courses/:id/exam-marks', builder: (context, state) => ExamMarksScreen(courseId: state.pathParameters['id']!)),
      GoRoute(path: '/courses/:id/grades/publish', builder: (context, state) => GradesPublishScreen(courseId: state.pathParameters['id']!)),
      GoRoute(path: '/courses/:id/announce', builder: (context, state) => CourseAnnounceScreen(courseId: state.pathParameters['id']!)),

      // Students & Admissions
      GoRoute(path: '/students', builder: (context, state) => const StudentsScreen()),
      GoRoute(path: '/students/new', builder: (context, state) => const StudentFormScreen()),
      GoRoute(path: '/students/:id', builder: (context, state) => StudentDetailScreen(studentId: state.pathParameters['id']!)),
      GoRoute(path: '/students/:id/edit', builder: (context, state) => StudentFormScreen(studentId: state.pathParameters['id']!)),
      GoRoute(path: '/students/:id/transcript', builder: (context, state) => StudentTranscriptScreen(studentId: state.pathParameters['id']!)),
      GoRoute(path: '/enrollments', builder: (context, state) => const EnrollmentsScreen()),
      GoRoute(path: '/applicants', builder: (context, state) => const ApplicantsScreen()),
      GoRoute(path: '/applicants/:id', builder: (context, state) => ApplicantDetailScreen(applicantId: state.pathParameters['id']!)),
      GoRoute(path: '/applicants/:id/status', builder: (context, state) => ApplicantStatusScreen(applicantId: state.pathParameters['id']!)),
      GoRoute(path: '/applicants/:id/convert', builder: (context, state) => ApplicantConvertScreen(applicantId: state.pathParameters['id']!)),

      // Academics
      GoRoute(path: '/academics/faculties', builder: (context, state) => const FacultiesScreen()),
      GoRoute(path: '/academics/departments', builder: (context, state) => const DepartmentsScreen()),
      GoRoute(path: '/academics/programs', builder: (context, state) => const ProgramsScreen()),
      GoRoute(path: '/academics/programs/:id/curriculum', builder: (context, state) => ProgramCurriculumScreen(programId: state.pathParameters['id']!)),
      GoRoute(path: '/academics/semesters', builder: (context, state) => const SemestersScreen()),
      GoRoute(path: '/academics/catalog', builder: (context, state) => const CourseCatalogScreen()),
      GoRoute(path: '/academics/catalog/:id', builder: (context, state) => CourseCatalogDetailScreen(catalogId: state.pathParameters['id']!)),

      // Finance
      GoRoute(path: '/finance/fee-structures', builder: (context, state) => const FeeStructuresScreen()),
      GoRoute(path: '/finance/charges', builder: (context, state) => const ChargesScreen()),
      GoRoute(path: '/finance/charges/new', builder: (context, state) => const BillStudentScreen()),
      GoRoute(path: '/finance/charges/:id', builder: (context, state) => ChargeDetailScreen(chargeId: state.pathParameters['id']!)),
      GoRoute(path: '/finance/payments', builder: (context, state) => const PaymentsScreen()),
      GoRoute(path: '/finance/payments/new', builder: (context, state) => const RecordPaymentScreen()),
      GoRoute(path: '/finance/payments/:id', builder: (context, state) => PaymentDetailScreen(paymentId: state.pathParameters['id']!)),
      GoRoute(path: '/finance/scholarships', builder: (context, state) => const ScholarshipsScreen()),
      GoRoute(path: '/finance/scholarships/new', builder: (context, state) => const AwardScholarshipScreen()),
      GoRoute(path: '/finance/reports', builder: (context, state) => const FinanceReportsScreen()),

      // People / HR
      GoRoute(path: '/people/lecturers', builder: (context, state) => const LecturersScreen()),
      GoRoute(path: '/people/lecturers/new', builder: (context, state) => const LecturerFormScreen()),
      GoRoute(path: '/people/lecturers/:id', builder: (context, state) => LecturerDetailScreen(lecturerId: state.pathParameters['id']!)),
      GoRoute(path: '/people/lecturers/:id/edit', builder: (context, state) => LecturerFormScreen(lecturerId: state.pathParameters['id']!)),

      // Administration
      GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/users', builder: (context, state) => const UsersScreen()),
      GoRoute(path: '/admin/users/:id', builder: (context, state) => UserDetailScreen(userId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/roles', builder: (context, state) => const RolesPermissionsScreen()),
      GoRoute(path: '/admin/audit-logs', builder: (context, state) => const AuditLogsScreen()),
      GoRoute(path: '/admin/audit-logs/:id', builder: (context, state) => AuditLogDetailScreen(auditId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/configs', builder: (context, state) => const SystemConfigsScreen()),
      GoRoute(path: '/admin/email-logs', builder: (context, state) => const EmailLogsScreen()),

      // Communication
      GoRoute(path: '/announcements', builder: (context, state) => const AnnouncementsScreen()),
      GoRoute(path: '/announcements/compose', builder: (context, state) => const ComposeAnnouncementScreen()),
      GoRoute(path: '/announcements/:id', builder: (context, state) => AnnouncementDetailScreen(announcementId: state.pathParameters['id']!)),
      GoRoute(path: '/broadcast-notification', builder: (context, state) => const BroadcastNotificationScreen()),

      // Notification detail + account sub-screens (pushed full-screen)
      GoRoute(path: '/notifications/:id', builder: (context, state) => NotificationDetailScreen(notificationId: state.pathParameters['id']!)),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/change-password', builder: (context, state) => const ChangePasswordScreen()),
    ],
  );
});
