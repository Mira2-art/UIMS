# Student App — Design Generation Playbook (follow-up prompts)

> Ordered batches to generate the **hi-fi** Trustech Student design into
> **`student-app.pen`**, section by section. Run Batch 0 first, confirm it renders in
> Pencil, then run the rest in order. Each batch has a **ready-to-paste prompt**.
> Source of truth for content, brand tokens, nav and screen details:
> **`design/student-app-design-spec.md`**.
> Scope reminder: **no application/admission screens — the catalog starts at enrollment.**

## Global rules (apply to every batch)

- **Fidelity: HI-FI.** Full brand color, real component styling (§4 of the spec), realistic sample data (student name + matric no, course codes like `CSC101`, GPA, amounts, dates), avatar (initials), icons (Material Symbols outlined). **Not** grey-box wireframes.
- **Brand tokens:** exactly per spec §3 (teal `#3D7A8C`, amber `#E8A847`, light + dark token tables).
- **Frames:** one screen = one `frame`, **390 × 844**, laid left-to-right per batch in a new canvas row, ~80px gutters. **Append** to the existing `student-app.pen` (never overwrite prior frames).
- **Naming:** `Student / <Section> / <Screen> (<Light|Dark>)`.
- **Light/Dark policy:** Batch 0 is **light + dark**. Each later batch = **all screens in Light**, plus **Dark for the one representative screen** noted in the batch.
- **States:** include loading/empty/error variants only where the batch notes them; otherwise design the populated (happy-path) state.
- **After each batch:** stop so it can be opened/reviewed in Pencil before continuing.

---

## Batch 0 — Starter (validate before continuing)
**Screens:** Components kit · Cover/Index · Login · Home (dashboard) — **Light + Dark**.
Components frame must show: buttons (all variants + loading), inputs, status chips, cards/list rows, the 5-tab bottom nav, and the 4 data states.

> **Prompt:** "Generate the student-app **starter batch** into `student-app.pen`: Components + Cover/Index + Login + Home, **light and dark**. Hi-fi, per `design/student-app-design-spec.md`."

---

## Batch 1 — Auth & Account
**Screens:** Welcome · Forgot password · Reset password · Verify email · Change password · Profile · Settings.
**Dark for:** Welcome.

> **Prompt:** "Looks good — generate the **Auth & Account** section into `student-app.pen` (Welcome, Forgot/Reset password, Verify email, Change password, Profile, Settings). Hi-fi; dark for Welcome."

---

## Batch 2 — Courses & Enrollment
**Screens:** My Courses · Course Registration (with registration-window open + closed states) · Course Detail · Course Materials.
**Dark for:** Course Registration. **States:** empty state for My Courses.

> **Prompt:** "Generate the **Courses & Enrollment** section into `student-app.pen` (My Courses, Course Registration incl. window open/closed states, Course Detail, Course Materials). Hi-fi; dark for Course Registration; empty state for My Courses."

---

## Batch 3 — Timetable & Attendance
**Screens:** Weekly Timetable · Course Attendance (mine, with rate + records).
**Dark for:** Weekly Timetable. **States:** low-attendance (amber/red) emphasis on the attendance screen.

> **Prompt:** "Generate the **Timetable & Attendance** section into `student-app.pen` (Weekly Timetable, Course Attendance with rate + records). Hi-fi; dark for Weekly Timetable; show a low-attendance state."

---

## Batch 4 — Grades & Standing
**Screens:** Transcript (GPA/CGPA, grades by course/semester) · Academic Standing.
**Dark for:** Transcript.

> **Prompt:** "Generate the **Grades & Standing** section into `student-app.pen` (Transcript with GPA/CGPA, Academic Standing). Hi-fi; dark for Transcript."

---

## Batch 5 — Finance
**Screens:** Finance Overview (balance) · Charges (list) · Charge Detail · Payments (history) · Scholarships.
**Dark for:** Finance Overview.

> **Prompt:** "Generate the **Finance** section into `student-app.pen` (Finance Overview, Charges + Charge Detail, Payments, Scholarships). Hi-fi; dark for Finance Overview."

---

## Batch 6 — Communication
**Screens:** Announcements (list) · Announcement Detail · Notifications.
**Dark for:** Notifications.

> **Prompt:** "Generate the **Communication** section into `student-app.pen` (Announcements list + Detail, Notifications). Hi-fi; dark for Notifications."

---

## Final QA pass (after all batches)
> **Prompt:** "Run the `ui-ux-pro-max` pre-delivery checklist over all `student-app.pen` frames (contrast, touch targets, nav consistency, dark-mode parity, states) and fix issues."

### Coverage map (sections → spec)
Auth/Account (spec §7.1, §7.9, §6) · Home §7.2 · Courses & Enrollment §7.3 · Timetable §7.4 · Attendance §7.6 · Grades & Standing §7.5 · Finance §7.7 · Communication §7.8.
