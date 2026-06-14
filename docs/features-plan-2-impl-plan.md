# Features Plan 2 — Courses (part 2) · Timetable · Grades · Finance · Communication (part 1) — screens 11–20

> UI-only. Prereqs: `student-app-impl-overview.md` + `components-impl-plan.md`.
> Per-screen gate: matches screenshot (light+dark) · routed · `flutter analyze` 0 · no API.
> Design source base: `design/stitch-student/<folder>`.

---

## Feature: `courses` (part 2)

### 11. Course Attendance (mine)
- **Source:** `student_courses_attendance_low_rate_light`
- **Route:** `/courses/:id/attendance` · **File:** `features/courses/presentation/screens/course_attendance_screen.dart`
- **Layout:** attendance-rate **ProgressRing** (color by threshold), count tiles (Present/Late/Absent/Excused via `StatCard`+`StatusChip`), records list (date → status chip). **Low-rate state** emphasized amber/red (match source).
- **Mock:** `courseAttendanceProvider(:id)`. `// TODO(backend:) /attendance/students/{id}/summary`.

---

## Feature: `timetable`

### 12. Weekly Timetable
- **Source:** `student_timetable_weekly_dark`
- **Route:** `/home/timetable` · **File:** `features/timetable/presentation/screens/weekly_timetable_screen.dart`
- **Layout:** day selector / week header, day-grouped list (or grid) of entries (`InfoListRow`/`ClassRow`: time block, course, venue, type); today highlighted; empty day state.
- **Mock:** `timetableProvider`. **Nav:** entry → `/courses/:id`.

---

## Feature: `grades` (tab 3)

### 13. Transcript
- **Source:** `student_grades_transcript_light` + `student_grades_transcript_dark`
- **Route:** `/grades` · **File:** `features/grades/presentation/screens/transcript_screen.dart`
- **Layout:** summary header (GPA / CGPA, credits) ; grades grouped by semester/course (`InfoListRow`: course, score %, letter chip); link → Academic Standing.
- **Components:** `StatCard`, `InfoListRow`, `StatusChip`, `SectionHeader`. **Mock:** `transcriptProvider`. **Nav:** → `/grades/standing`.

### 14. Academic Standing
- **Source:** `student_grades_academic_standing_light`
- **Route:** `/grades/standing` · **File:** `.../screens/academic_standing_screen.dart`
- **Layout:** current standing card (standing chip, GPA/CGPA, credits attempted/earned, reason), optional history list.
- **Components:** standing card, `ProgressRing`, `StatusChip`. **Mock:** `standingProvider`.

---

## Feature: `finance` (tab 4)

### 15. Finance Overview
- **Source:** `student_finance_overview_light_{choice #7}` + `student_finance_overview_dark`
- **Route:** `/finance` · **File:** `features/finance/presentation/screens/finance_overview_screen.dart`
- **Layout:** big **outstanding balance** card (status accent), next due date, quick links (Charges · Payments · Scholarships), recent items.
- **Components:** balance card, `InfoListRow`, `SectionHeader`. **Mock:** `financeOverviewProvider`. **Nav:** → `/finance/charges/:id`, `/finance/payments`, `/finance/scholarships`.

### 16. Charges
- **Source:** `student_finance_charges_light`
- **Route:** `/finance/charges` · **File:** `.../screens/charges_screen.dart`
- **Layout:** list of charges (`InfoListRow`: fee name, amount, balance, status chip PAID/PARTIAL/OUTSTANDING/WAIVED).
- **States:** list · empty · loading. **Mock:** `chargesProvider`. **Nav:** row → `/finance/charges/:id`.

### 17. Charge Detail
- **Source:** `student_finance_charge_detail_light`
- **Route:** `/finance/charges/:id` · **File:** `.../screens/charge_detail_screen.dart`
- **Layout:** breakdown card (amount, discount, paid, balance, due date, semester), status chip, payment history for this charge.
- **Mock:** `chargeDetailProvider(:id)`.

### 18. Payments
- **Source:** `student_finance_payments_light`
- **Route:** `/finance/payments` · **File:** `.../screens/payments_screen.dart`
- **Layout:** payment history list (`InfoListRow`: date, amount, method, receipt no, reversed flag chip).
- **States:** list · empty. **Mock:** `paymentsProvider`.

### 19. Scholarships
- **Source:** `student_finance_scholarships_light`
- **Route:** `/finance/scholarships` · **File:** `.../screens/scholarships_screen.dart`
- **Layout:** awarded scholarships list (`InfoListRow`: name, amount/percentage, semester, status chip).
- **States:** list · empty. **Mock:** `scholarshipsProvider`.

---

## Feature: `communication` (part 1)

### 20. Announcements
- **Source:** `student_communication_announcements_light`
- **Route:** `/announcements` · **File:** `features/communication/presentation/screens/announcements_screen.dart`
- **Layout:** list of announcement cards (image/category tag, title, excerpt, date, priority/pinned indicator).
- **States:** list · empty · loading. **Mock:** `announcementsProvider`. **Nav:** card → `/announcements/:id`.

---

### Routing additions (this plan)
`/courses/:id/attendance`, `/home/timetable`, Grades branch (`/grades`, `/grades/standing`), Finance branch (`/finance`, `/finance/charges`, `/finance/charges/:id`, `/finance/payments`, `/finance/scholarships`), `/announcements`.
