# Pro App — Design Generation Playbook (follow-up prompts)

> Ordered batches to generate the **hi-fi** Trustech Staff (Pro) design into
> **`pro-app.pen`**, section by section. Run Batch 0 first, confirm it renders in
> Pencil, then run the rest in order. Each batch below has a **ready-to-paste prompt**.
> Source of truth for content, brand tokens, nav and screen details:
> **`design/pro-app-design-spec.md`**.

## Global rules (apply to every batch)

- **Fidelity: HI-FI.** Full brand color, real component styling (§4 of the spec), realistic sample data (staff/student names, course codes like `CSC101`, amounts, dates), avatars (initials), icons (Material Symbols outlined), and charts where the screen calls for them (admin dashboard, finance reports). **Not** grey-box wireframes.
- **Brand tokens:** exactly per spec §3 (teal `#3D7A8C`, amber `#E8A847`, light + dark token tables).
- **Frames:** one screen = one `frame`, **390 × 844**, laid left-to-right per batch in a new canvas row, ~80px gutters. **Append** to the existing `pro-app.pen` (never overwrite prior frames).
- **Naming:** `Pro / <Section> / <Screen> (<Light|Dark>)`.
- **Light/Dark policy:** Batch 0 is **light + dark**. Each later batch = **all screens in Light**, plus **Dark for the one representative screen** noted in the batch (the rest reuse the §3 dark tokens).
- **States:** include loading/empty/error variants only where the batch notes them; otherwise design the populated (happy-path) state.
- **After each batch:** stop so it can be opened/reviewed in Pencil before continuing.

---

## Batch 0 — Starter (validate before continuing)
**Screens:** Components kit · Cover/Index · Login · Home (lecturer-default, role-aware) — **Light + Dark**.
Components frame must show: buttons (all variants + loading), inputs, status chips, cards/list rows, the 4-tab bottom nav, the open drawer, and the 4 data states.

> **Prompt:** "Generate the pro-app **starter batch** into `pro-app.pen`: Components + Cover/Index + Login + Home, **light and dark**. Hi-fi, per `design/pro-app-design-spec.md`."

---

## Batch 1 — Shell & Auth/Account
**Screens:** Welcome · Workspace hub · Drawer (open) · Notifications · Profile · Settings · Forgot password · Reset password · Verify email · Change password.
**Dark for:** Welcome.

> **Prompt:** "Looks good — generate the **Shell & Auth** section into `pro-app.pen` (Welcome, Workspace hub, Drawer open, Notifications, Profile, Settings, Forgot/Reset password, Verify email, Change password). Hi-fi; dark variant for Welcome."

---

## Batch 2 — Teaching (Lecturer)
**Screens:** My Courses · Course Detail · Course Roster · Materials · Course Timetable · Attendance Sessions · Attendance Mark (bulk) · Attendance Records · Gradebook Assessments · Gradebook Enter Scores · Grades Publish · Compose Announcement (course).
**Dark for:** Attendance Mark. **States:** empty state for My Courses.

> **Prompt:** "Generate the **Teaching** section into `pro-app.pen` (all 12 lecturer screens). Hi-fi; dark variant for Attendance Mark; empty state for My Courses."

---

## Batch 3 — Students & Admissions (Registrar)
**Screens:** Students (list) · Student Detail · Create/Edit Student · Student Transcript · Applicants (list) · Applicant Detail · Applicant Status Update · Convert to Student · Enrollments.
**Dark for:** Student Detail. **States:** empty + loading for Students.

> **Prompt:** "Generate the **Students & Admissions** section into `pro-app.pen` (Students, Student Detail, Create/Edit Student, Transcript, Applicants, Applicant Detail, Status Update, Convert, Enrollments). Hi-fi; dark for Student Detail; empty+loading for Students."

---

## Batch 4 — Academics (Registrar)
**Screens:** Faculties · Departments · Programs · Program Curriculum · Semesters/Calendar · Course Catalog (list) · Course Catalog Detail (assign lecturer · prerequisites · syllabus · timetable as sections).
**Dark for:** Course Catalog Detail.

> **Prompt:** "Generate the **Academics** section into `pro-app.pen` (Faculties, Departments, Programs, Program Curriculum, Semesters, Course Catalog list + detail). Hi-fi; dark for Course Catalog Detail."

---

## Batch 5 — Finance
**Screens:** Fee Structures · Charges (list) · Charge Detail · Bill Student (form) · Payments (list) · Payment Detail · Record Payment (form) · Scholarships · Award Scholarship (form) · Reports (Outstanding + Collection, with charts).
**Dark for:** Reports.

> **Prompt:** "Generate the **Finance** section into `pro-app.pen` (Fee Structures, Charges + Detail, Bill Student, Payments + Detail, Record Payment, Scholarships, Award Scholarship, Reports with charts). Hi-fi; dark for Reports."

---

## Batch 6 — People (HR)
**Screens:** Lecturers (list) · Create/Edit Lecturer · Lecturer Detail (courses taught).
**Dark for:** Lecturer Detail.

> **Prompt:** "Generate the **People (HR)** section into `pro-app.pen` (Lecturers, Create/Edit Lecturer, Lecturer Detail). Hi-fi; dark for Lecturer Detail."

---

## Batch 7 — Administration & Analytics (Admin, non-super)
**Screens:** Admin Dashboard (charts) · Users (list) · User Detail · Roles & Permissions · Audit Logs (list) · Audit Log Detail · System Configs (read-only) · Email Logs.
**Dark for:** Admin Dashboard.

> **Prompt:** "Generate the **Administration & Analytics** section into `pro-app.pen` (Admin Dashboard with charts, Users + Detail, Roles & Permissions, Audit Logs + Detail, System Configs read-only, Email Logs). Hi-fi; dark for Admin Dashboard."

---

## Batch 8 — Communication
**Screens:** Announcements (list) · Announcement Detail · Compose Announcement · Send/Broadcast Notification.
**Dark for:** Compose Announcement.

> **Prompt:** "Generate the **Communication** section into `pro-app.pen` (Announcements list + Detail, Compose Announcement, Send/Broadcast Notification). Hi-fi; dark for Compose Announcement."

---

## Final QA pass (after all batches)
> **Prompt:** "Run the `ui-ux-pro-max` pre-delivery checklist over all `pro-app.pen` frames (contrast, touch targets, nav consistency, dark-mode parity, states) and fix issues."

### Coverage map (sections → spec)
Shell/Auth (spec §7.1, §6) · Teaching §7.2 · Students & Admissions §7.3 · Academics §7.4 · Finance §7.5 · People/HR §7.6 · Administration §7.7 · Communication §7.8.
