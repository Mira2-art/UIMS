# Agent Review Log — Staff (Pro) App UI Implementation

Running log of issues found during Claude's review of each agent's phases. Keep Codex
and Gemini separate; add a dated subsection per review.

**Severity:** 🔴 blocking (won't compile / breaks contract) · 🟡 minor (fidelity/convention) · 🔵 cross-cutting.
**Status:** ✅ fixed · ⬜ open · 🔁 verify.

---

# CODEX  (Teaching · Students & Admissions · People)

## All phases (1–8) — design-fidelity review — 2026-06-08
**Overall: excellent engineering, high *structural* fidelity, medium *detail* fidelity.**
All 24 screens implemented (no stubs), `flutter analyze` = **0 issues**, provider-driven
(`teaching/students/admissions/people` providers + mock), reuse the ui-kit + staff deltas
(notably `RosterStatusRow` on Attendance Mark), light+dark via theme, param-screen
constructor contracts honored, `// Roles:` annotations present. They **match the Stitch
designs at the screen-anatomy/component level**, but Codex consistently editorializes the
secondary content rather than reproducing the exact design.

### Recurring deviations (the pattern)
| # | Sev | Where | Issue | Status |
|---|-----|-------|-------|--------|
| PC.1 | 🟡 | my_courses, course_roster, students, gradebook_assessments, attendance_sessions, student_detail | Adds a **2-up `StatCard` summary row** near the top that isn't in the Stitch frame (design uses a plain "SHOWING N · Export"/header or none). | ⬜ open |
| PC.2 | 🟡 | my_courses, course_materials, course_timetable | Substitutes **own "insight/snapshot" panels** for the design's specific panels (My Courses "teaching load snapshot" vs design's **"Academic Calendar / Review Now"**; Materials "Featured resource insight" vs **"Learning Insights" + "Next Milestone"**; Timetable bottom cards vs **"Pending Grades" amber panel** + avatars). | ⬜ open |
| PC.3 | 🟡 | course_roster, gradebook_assessments, grades_publish | Trailing **metric/chip swapped**: roster shows attendance% (design = **grade letter** A+/B/At Risk); gradebook cards show a completion bar (design = **WEIGHT / MAX SCORE** columns + **PUBLISHED** chip); publish rows show "scores entered" (design = **"Average % · N Students"**). | ⬜ open |
| PC.4 | 🟡 | course_materials, grades_publish, lecturer_detail, applicant_detail, course_detail | Missing design accents: Materials **"Published"** chip; Grades-Publish **red (destructive) notify banner** (Codex uses a neutral card); Lecturer **"Availability / Office Hours"** panel; Applicant **"Decision Notes"** reviewer note + notes textarea; Course-Detail bento **"+4% / Stable"** mini-labels. | ⬜ open |
| PC.5 | 🔵 | course_materials, gradebook_assessments, attendance_sessions, course_detail | Pushed sub-screens use `AppHeaderBar.menu` ("Staff Portal" + hamburger) where a **back arrow** is more correct (they're pushed inside the Workspace branch). The Stitch frames themselves show a hamburger here, so it mirrors the design — but it's wrong for our 4-tab shell nav. Standardize to `.back`. | 🔁 verify |
| PC.6 | 🟡 | student_detail, applicant_detail | Detail field sets differ from design (Student: missing **DOB / Residential Address**; Applicant: **2 docs vs 4**, Program/Score vs Intended-Major/Admission-Term/Entry-Level). | ⬜ open |

### Standouts (high fidelity — leave as-is)
- **Attendance Mark** — uses `RosterStatusRow` (P/A/L/E) + sticky save bar with `ProgressRing`; exactly the intended pattern. ✅
- **Course Detail** — banner, CORE MODULE chip, bento metrics, tab strip, roster preview: faithful. ✅
- **Students list / Student Detail / Applicant Detail** — card anatomy, status chips, section structure, bottom CTAs all match. ✅

### Verdict
Ship-quality UI-only code that's faithful to the **design language and structure**, but
**not pixel-faithful** — the gaps are all secondary content (added stat rows, swapped
insight panels, a few missing chips/labels). Send PC.1–PC.4 back if you want strict
parity; PC.5 (header back-vs-menu) is worth standardizing app-wide.

> Coverage note: pixel-compared 14/24 (all complex Teaching screens + a representative
> detail per module); the remaining list/form screens (attendance_records, gradebook_scores,
> course_announce, student_form, transcript, enrollments, applicants_list, applicant_status,
> applicant_convert, lecturers, lecturer_form) follow the same patterns above.

## Grading architecture review (CA/30 + EXAM/70) — 2026-06-08
**Required model:** final grade = **CA (max 30, entered by LECTURER)** + **EXAM (max 70,
entered by Faculty Dean / School Secretariat / Admin)** = **total /100 → letter**.
Codex's gradebook does **not** match this — it built a generic weighted-assessment model.

| # | Sev | Where | Issue |
|---|-----|-------|-------|
| GC.1 | 🔴 | `teaching_mock.GradebookAssessment`, gradebook screens | Model is arbitrary weighted assessments (`type` + `maxScore` 10/20/30 + `weightPercent`), each graded in isolation. It does **not** encode the fixed two-component CA(30)+EXAM(70)→/100 scheme; `weightPercent` and per-assessment letters are conceptually wrong here. |
| GC.2 | 🔴 | all grade entry under `features/teaching` (LECTURER) | **No role split.** EXAM (/70) must be entered by Dean/Secretariat/Admin, not the lecturer. Need: lecturer gradebook = **CA only, capped at 30**; a **separate exam-entry screen** for Dean/Secretariat/Admin (Admin/Registrar/Results module). |
| GC.3 | 🟡 | `gradebook_scores_screen` | "Max insertion": `maxScore` is a free per-assessment value; should be the **fixed component caps** (CA 30, EXAM 70) with validation. The clamp-to-max mechanism is fine, but the maxes are wrong and there's no CA+EXAM summation. |
| GC.4 | 🟡 | `gradebook_scores_screen._grade()` | Letter is computed from one assessment's `score/maxScore`. It must be computed from **(CA + EXAM)/100**. Combined total + letter-from-total + publish-gated-on-both-components are absent. |

**Recommended model:** `CourseResult { studentId, ca (0–30, lecturer), exam (0–70, dean/sec/admin), total = ca+exam, grade = letterOf(total), published }` — two role-scoped entry surfaces, server-computed total + letter, publish locks the record. This is primarily a **backend** concern (below); the mobile gradebook should then mirror it.

## Parity pass (Claude implemented) — 2026-06-08
Reverted toward Stitch where the design was judged better; kept agent choices where better. All teaching screens `flutter analyze` 0.
- ✅ PC.2 My Courses → **Academic Calendar + Review Now** (replaced the "teaching load snapshot").
- ✅ PC.2 Materials → **Learning Insights + Next Milestone** (replaced "Featured resource insight").
- ✅ PC.2 Timetable → **"12 Pending Grades"** panel (replaced "X weekly slots").
- ✅ PC.3 Gradebook cards → **PUBLISHED chip + WEIGHT / MAX SCORE** (kept a completion hint) — aligns with CA/30 + EXAM/70.
- ✅ PC.3 Roster trailing → **grade letter** (At Risk when not in good standing), using the new scale.
- ✅ PC.3 Grades-Publish rows → **"N students · M entered"**; ✅ PC.4 destructive **"…notify all enrolled students…"** banner.
- ✅ PC.4 Materials rows → **Published/Draft chip + "Added <date>"**.
- ↔︎ PC.1 stat-card summary rows: **kept by design** (useful triage; an addition, not a replaced design panel).
- ⬜ PC.5 (header back-vs-menu) · PC.6 (shared helper extraction) — not done.
- ⬜ GC.1–GC.4 — backend already fixed (see grades module); the **mobile** gradebook still needs to mirror the CA/EXAM split + new exam-marks screen wiring.

## Pass 2 — 2026-06-09
- ✅ PC.5 **resolved**: verified all pushed teaching screens use `AppHeaderBar.back` (only `my_courses`, the module landing, uses `.menu` — matches its Stitch hamburger). Gave the three deep action screens real titles (Attendance Records · Compose Announcement · Grades Publish) instead of generic "Staff Portal".
## Pass 3 — mobile gradebook CA/EXAM mirror — 2026-06-09
- ✅ GC.1–GC.4 (mobile) **resolved**: the lecturer gradebook now mirrors the backend grading model.
  - `GradebookAssessment` gained a `component` (CA/EXAM); mock reframed so **CA weights sum to 30** (Quiz/Assignment/Mid-Sem × 10) + a **Final Examination (70)**.
  - Gradebook Assessments screen: "**Final grade = CA (30) + Exam (70) → 100**" explainer; stat cards **CA Weight x/30** + **Exam (Dean) /70**; a **Continuous Assessment** section (lecturer-editable CA cards) and a **locked Final Examination card** ("Entered by Faculty Dean / Secretariat — read-only") that links to the exam-marks screen.
  - Enter-Scores screen no longer shows a misleading per-assessment letter — shows **score/max + Saved/Pending** (the letter is a course-level CA+EXAM result, per the backend).
- All staff screens `flutter analyze` 0.

## Pass 4 — structural nav + PC.6 — 2026-06-09
- ✅ **Bottom-nav scoping (foundation):** router restructured so **only the 4 tab roots** (`/home`, `/workspace`, `/notifications`, `/profile`) live in the `StatefulShellRoute`; all ~56 module/detail/form routes are now top-level **root-navigator** routes → they push full-screen with **no bottom bar**.
- ✅ **Hamburger→back (foundation):** the 17 module-landing screens (incl. Codex's my_courses, students, enrollments, applicants, lecturers) switched `AppHeaderBar.menu` → `.back`; only the 4 tabs keep the hamburger. Drawer/notification nav switched `context.go`→`push` so back returns correctly.
- ✅ **PC.6:** extracted the duplicated `StudentStatus → StatusKind` mapping into `students/presentation/student_status_ext.dart` (`.chipKind`); removed the copies in `students_screen` + `student_detail_screen`. (The `_kind` helpers are type-specific per file, not true dups.)
- `flutter analyze lib` 0 · smoke test boots.
