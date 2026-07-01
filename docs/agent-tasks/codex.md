# Agent Task — CODEX (Home · Courses · Timetable · Grades)

You implement the **Home, Courses, Timetable, and Grades** screens of the Trustech
**Student** Flutter app (`trustech_mobile`). Claude builds the foundation/routing and
Auth; Gemini builds Finance/Communication/Profile. Work only in **your** feature folders.

## ⛔ Start condition
Begin **only after Claude's Phase 1 (foundation) is done** — `MainShell`, the router, the
stub screens, and the UI kit must exist. Your job is to **replace your stub screens** with
real hi-fi UI (same file path + class name as the stub). **Do not edit** `src/shared/ui_kit/`,
`src/router/`, or `MainShell` — if you need a new route, ask Claude.

## Read first
- `docs/student-app-impl-overview.md` (conventions, §3 token reconciliation, duplicates).
- `docs/components-impl-plan.md` (the UI kit you must reuse).
- `docs/features-plan-1-impl-plan.md` + `features-plan-2-impl-plan.md` (per-screen detail for your screens).
- Design source: `design/stitch-student/<folder>/screen.png` + `code.html`.

## Golden rules
1. **UI ONLY — no backend.** Data from Riverpod providers returning static mock under `features/<f>/data/mock/`; mark `// TODO(backend:)`.
2. **Use the UI kit:** `import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';` (`InfoListRow`, `InfoListCard`, `StatCard`, `StatusChip`, `ProgressRing`, `SectionHeader`, `AppHeaderBar`, `TrustechCard`, states…). No one-off widgets.
3. **Colors:** `TrustechColors`/`colorScheme` only; light **and** dark.
4. **Match** each screen's Stitch `screen.png`.
5. **Gate per screen:** `flutter analyze` 0 · routed · light+dark.
6. **Stay in your folders:** `features/home/`, `features/courses/`, `features/timetable/`, `features/grades/` only.

---

## Phase 1 — Home & Courses A (3 screens)
| Screen | Stitch folder | Route | File · class |
|---|---|---|---|
| Home Dashboard | `student_home_dashboard_light_v2` (+ dark_v2) | `/home` | `features/home/presentation/screens/home_screen.dart` · `HomeScreen` |
| My Courses | `student_courses_my_courses_empty_light` | `/courses` | `features/courses/presentation/screens/my_courses_screen.dart` · `MyCoursesScreen` |
| Course Registration | `student_courses_registration_light` (+ `_closed_light`, `_open_dark`) | `/courses/register` | `.../course_registration_screen.dart` · `CourseRegistrationScreen` |
- Home: `AppHeaderBar.home`, GPA/standing card (`StatusChip`), quick-actions row, finance balance card (teal, Pay Now), Today's Classes (`SectionHeader`+`InfoListRow`), announcements scroller. Nav: quick actions → `/home/timetable`, `/courses/register`, `/grades`; Pay Now → `/finance`; bell → `/notifications`.
- My Courses: course `InfoListRow`s + **empty state** + skeleton loading.
- Registration: window **open/closed** banner states; Enroll confirm sheet.

## Phase 2 — Courses B (3 screens)
| Screen | Stitch folder | Route | File · class |
|---|---|---|---|
| Course Detail | `student_courses_detail_light_{1\|2}` | `/courses/:id` | `course_detail_screen.dart` · `CourseDetailScreen` |
| Course Materials | `student_courses_materials_light` | `/courses/:id/materials` | `course_materials_screen.dart` · `CourseMaterialsScreen` |
| Course Attendance | `student_courses_attendance_low_rate_light` | `/courses/:id/attendance` | `course_attendance_screen.dart` · `CourseAttendanceScreen` |
- Detail: header + sections (Materials/Timetable/Attendance/Grades) + Drop confirm sheet.
- Materials: list w/ type `StatusChip`s.
- Attendance: `ProgressRing` (threshold color) + count tiles + records list; low-rate emphasis.

## Phase 3 — Timetable & Grades (3 screens)
| Screen | Stitch folder | Route | File · class |
|---|---|---|---|
| Weekly Timetable | `student_timetable_weekly_dark` | `/home/timetable` | `features/timetable/presentation/screens/weekly_timetable_screen.dart` · `WeeklyTimetableScreen` |
| Transcript | `student_grades_transcript_light` (+ dark) | `/grades` | `features/grades/presentation/screens/transcript_screen.dart` · `TranscriptScreen` |
| Academic Standing | `student_grades_academic_standing_light` | `/grades/standing` | `academic_standing_screen.dart` · `AcademicStandingScreen` |
- Timetable: day-grouped `InfoListRow`s, today highlighted, empty-day state.
- Transcript: GPA/CGPA `StatCard` header + grades grouped (`InfoListRow` + letter `StatusChip`) → link `/grades/standing`.
- Standing: standing card + `ProgressRing`.

### Per-phase DoD
All phase screens implemented (light+dark), reuse ui_kit, mock providers only, `flutter analyze` 0, reachable via existing routes. Hand off to Claude for integration.
