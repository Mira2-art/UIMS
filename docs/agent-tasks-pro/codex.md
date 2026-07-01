# Agent Task — CODEX (Staff/Pro app · Teaching · Students & Admissions · People/HR)

You implement the **Teaching, Students & Admissions, and People (HR)** screens of the
Trustech **Staff (Pro)** Flutter app (`trustech_mobile_pro`). Claude builds the
foundation/shell/router/role-gating and the shared/auth/comms screens; Gemini builds
Academics/Finance/Administration. **Work only in your feature folders.**

## ⛔ Start condition
Begin **only after Claude's Foundation (P0) is done** — `MainShell` (4 tabs), the
router, the role-gating `moduleAccess`, the **stub screens**, and the UI kit (incl.
deltas) must exist. Your job is to **replace your stub screens** with real hi-fi UI at
the **same file path + class name** as the stub. **Do not edit** `src/shared/ui_kit/`,
`src/router/`, `src/core/auth/` (role-gating), or `MainShell` — if you need a new route,
ask the user to have Claude add it.

## Read first
- `design/pro-app-design-spec.md` — brand tokens (§3), components (§4), nav (§6), per-screen content (§7).
- `docs/agent-tasks-pro/claude.md` — the shared ui-kit + deltas you must reuse.
- `docs/features-plan-2-impl-pro-plan.md` (Teaching) · `features-plan-3-impl-pro-plan.md` (Students & Admissions) · `features-plan-4-impl-pro-plan.md` (People).
- Design source: `design/stitch-staff/<folder>/screen.png` + `code.html` (or the Downloads export `stitch_trustech_staff_pro_app`).

## Golden rules
1. **UI ONLY — no backend.** Data from Riverpod providers returning static mock under `features/<f>/data/mock/`; mark `// TODO(backend:)` seams.
2. **Use the UI kit:** `import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';` — `AppHeaderBar`, `InfoListRow`/`InfoListCard`, `StatCard`, `StatusChip`, `TrustechButton`, `TrustechTextField`, `SheetScaffold`, `RosterStatusRow`, `SectionHeader`, states. **No one-off widgets** when a kit component exists.
3. **Colors/typography:** `TrustechColors`/`colorScheme` + `TrustechTypography` only; no new hex. Light **and** dark.
4. **Match** each screen's Stitch `screen.png` (read `code.html` for true layout where the PNG has text-overlap artifacts).
5. **Role annotation:** add a top `// Roles: …` comment per screen per spec §2 (visibility is enforced by Claude's `moduleAccess`; you just build the screen).
6. **Gate per screen:** `flutter analyze` 0 · routed · light+dark.
7. **Stay in your folders:** `features/teaching/`, `features/students/`, `features/admissions/`, `features/people/` only.
8. **Param-screen constructors are a router contract** — keep the exact names: `courseId`, `studentId`, `applicantId`, `sessionId`, `assessmentId`, `lecturerId`.

---

## Phase 1 — Teaching A (3)
| # | Screen | Stitch folder | Route | File · class |
|---|---|---|---|---|
|1| My Courses (+empty) | `pro_teaching_my_courses_light` / `_empty_state` | `/courses` | `teaching/presentation/screens/my_courses_screen.dart` · `MyCoursesScreen` |
|2| Course Detail | `pro_teaching_course_detail_light` | `/courses/:id` | `course_detail_screen.dart` · `CourseDetailScreen(courseId)` |
|3| Course Roster | `pro_teaching_course_roster_light` | `/courses/:id/roster` | `course_roster_screen.dart` · `CourseRosterScreen(courseId)` |

## Phase 2 — Teaching B (3)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|4| Materials (+Add sheet) | `pro_teaching_materials_light` | `/courses/:id/materials` | `course_materials_screen.dart` · `CourseMaterialsScreen(courseId)` |
|5| Course Timetable | `pro_teaching_course_timetable_light` | `/courses/:id/timetable` | `course_timetable_screen.dart` · `CourseTimetableScreen(courseId)` |
|6| Attendance — Sessions | `pro_teaching_attendance_sessions_light` | `/courses/:id/attendance` | `attendance_sessions_screen.dart` · `AttendanceSessionsScreen(courseId)` |

## Phase 3 — Teaching C (3)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|7| Attendance — Mark (bulk) ★ | `pro_teaching_attendance_mark_dark` | `/courses/:id/attendance/:sessionId` | `attendance_mark_screen.dart` · `AttendanceMarkScreen(courseId, sessionId)` |
|8| Attendance — Records | `pro_teaching_attendance_records_light` | `/courses/:id/attendance/:sessionId/records` | `attendance_records_screen.dart` · `AttendanceRecordsScreen(courseId, sessionId)` |
|9| Gradebook — Assessments | `pro_teaching_gradebook_assessments_light` | `/courses/:id/gradebook` | `gradebook_assessments_screen.dart` · `GradebookAssessmentsScreen(courseId)` |
- Mark uses ui-kit `RosterStatusRow` (P/A/L/E segmented) + sticky **Save Attendance** + status ring.

## Phase 4 — Teaching D (3)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|10| Gradebook — Enter Scores | `pro_teaching_gradebook_enter_scores_light` | `/courses/:id/gradebook/:assessmentId` | `gradebook_scores_screen.dart` · `GradebookScoresScreen(courseId, assessmentId)` |
|11| Grades — Publish | `pro_teaching_grades_publish_light` | `/courses/:id/grades/publish` | `grades_publish_screen.dart` · `GradesPublishScreen(courseId)` |
|12| Compose Announcement (course) | `pro_teaching_compose_announcement_light` | `/courses/:id/announce` | `course_announce_screen.dart` · `CourseAnnounceScreen(courseId)` |
- Publish = confirm dialog ("notifies students").

## Phase 5 — Students A (3)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|13| Students (list +empty +loading) | `pro_students_list_light`/`_empty_state`/`_loading_state` | `/students` | `students/presentation/screens/students_screen.dart` · `StudentsScreen` |
|14| Student Detail | `pro_students_student_detail_light` | `/students/:id` | `student_detail_screen.dart` · `StudentDetailScreen(studentId)` |
|15| Create/Edit Student | `pro_students_create_student_light` | `/students/new`, `/students/:id/edit` | `student_form_screen.dart` · `StudentFormScreen({studentId?})` |

## Phase 6 — Students B & Admissions (3)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|16| Student Transcript | `pro_students_student_transcript_light` | `/students/:id/transcript` | `student_transcript_screen.dart` · `StudentTranscriptScreen(studentId)` |
|17| Enrollments | `pro_students_enrollments_light` | `/enrollments` | `enrollments_screen.dart` · `EnrollmentsScreen` |
|18| Applicants (list) | `pro_admissions_applicants_list_light` | `/applicants` | `admissions/presentation/screens/applicants_screen.dart` · `ApplicantsScreen` |
- Enrollments rows: Drop / Withdraw / Complete (reason + confirm sheet).

## Phase 7 — Admissions B (3)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|19| Applicant Detail | `pro_admissions_applicant_detail_light` | `/applicants/:id` | `applicant_detail_screen.dart` · `ApplicantDetailScreen(applicantId)` |
|20| Applicant Status Update | `pro_admissions_status_update_light` | `/applicants/:id/status` | `applicant_status_screen.dart` · `ApplicantStatusScreen(applicantId)` |
|21| Convert to Student | `pro_admissions_convert_to_student_light` | `/applicants/:id/convert` | `applicant_convert_screen.dart` · `ApplicantConvertScreen(applicantId)` |
- Convert enabled only when status == ACCEPTED.

## Phase 8 — People / HR (3)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|22| Lecturers (list) | `pro_people_lecturers_light` | `/people/lecturers` | `people/presentation/screens/lecturers_screen.dart` · `LecturersScreen` |
|23| Create/Edit Lecturer | `pro_people_create_lecturer_light` | `/people/lecturers/new`, `/:id/edit` | `lecturer_form_screen.dart` · `LecturerFormScreen({lecturerId?})` |
|24| Lecturer Detail (courses taught) | `pro_people_lecturer_detail_light` | `/people/lecturers/:id` | `lecturer_detail_screen.dart` · `LecturerDetailScreen(lecturerId)` |

### Per-phase DoD
All phase screens implemented (light+dark), reuse ui_kit, mock providers only, `flutter analyze` 0, reachable via existing routes. Flag blockers to the user. Hand off to Claude for review (logged in `docs/agent-tasks-pro/codex-review-log-pro.md`).
