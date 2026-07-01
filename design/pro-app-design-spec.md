# Trustech **Staff (Pro)** App — Master Design Spec

> **Single source of truth** for designing the Trustech Staff (Pro) mobile app.
> Self-contained — assumes **no prior conversation context**. Deliver the design as
> Pencil (`.pen`) frames (see §8). Design **every screen** in §7; the app is one app
> whose navigation and screen visibility **adapt to the signed-in user's role(s)** (§3).
> Decisions cite the `ui-ux-pro-max` design-skill rule IDs that govern them.

---

## 1. Product context

- **What:** Trustech SIS (School Information System) — this is the **Staff / "Pro" companion app**. Flutter (Material 3 + Cupertino-adaptive), **phone-first**, light **and** dark.
- **Who:** every staff member **except SUPER_ADMIN** — **Lecturers, Registrars, Finance officers, HR, Admins, general Staff**. (Students use a separate sibling app. Super-admin-only operations are out of scope.)
- **Backend:** Trustech SIS REST API. Auth = email + password → JWT (access + refresh); every request carries an `X-Client-ID` header; login/register also send a `device_info` object (handled in code — only the login form is visible to users).
- **Tone:** professional, calm, data-dense but uncluttered. Trustworthy institutional software.

---

## 2. Roles & access — who sees what

The app contains the **superset** of all staff screens; the signed-in user's role(s) gate visibility. A user may hold several roles (e.g. ADMIN + LECTURER) and sees the **union**. Centralize this as one `moduleAccess(roles)` helper feeding the Workspace grid, the drawer directory, and the route guard (single source of truth).

| Module / area | LECTURER | REGISTRAR | FINANCE | HR | ADMIN | STAFF |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| My Courses, Attendance, Gradebook, Materials | ✔ | | | | | |
| Students (records, transcript, standing) | view | ✔ | view | | view | |
| Applicants & admissions | | ✔ | | | view | |
| Enrollments management | | ✔ | | | | |
| Academic structure (faculty/dept/program/semester/curriculum) | | ✔ | | | view | |
| Course catalog mgmt (create, assign lecturer, prerequisites, timetable) | | ✔ | | | | |
| Fees, charges, payments, scholarships, finance reports | | | ✔ | | view | |
| Lecturer (HR) management | | | | ✔ | view | |
| Users & status, Roles/permissions assignment | | | | | ✔ | |
| Audit logs, System configs (read), Analytics reports | | | | | ✔ | |
| Announcements & notifications (compose/broadcast) | own courses | ✔ | ✔ | | ✔ | ✔ |
| Profile, settings, own notifications | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |

> **Excluded (super-admin only — DO NOT design):** creating permissions, editing system-config values, deleting users, rotating/registering client apps.

---

## 3. Design system (use exactly)

### 3.1 Color tokens
| Token | Light | Dark |
|-------|-------|------|
| Primary (teal) | `#3D7A8C` | `#3D7A8C` |
| Primary dark (gradient end) | `#2D5A68` | `#2D5A68` |
| On-primary (text on teal) | `#FBFBFB` | `#FBFBFB` |
| Secondary (amber accent) | `#E8A847` | `#E8A847` |
| Destructive / error | `#DC3545` | `#DC3545` |
| Success | `#34C759` | `#34C759` |
| Background | `#FAFAFA` | `#252525` |
| Foreground (text) | `#252525` | `#FBFBFB` |
| Card surface | `#FFFFFF` | `#343434` |
| Muted surface | `#F7F7F7` | `#454545` |
| Muted foreground | `#8E8E8E` | `#B5B5B5` |
| Border | `#EBEBEB` | `#474747` |
| Input fill | `#FFFFFF` | `#404040` |

**Status accents** (chips/badges): present/active/paid → success green; late/partial/pending → amber; absent/overdue/failed → destructive red; info/neutral → primary teal; inactive → muted foreground. Functional color must always pair with icon/text (`color-not-only`).

**Chart palette** (analytics/finance reports) — from `TrustechColors.chart1–5`: `#9BB8ED` · `#6B7FD4` · `#5A6BC7` · `#4A5AB8` · `#3A4A9A`.

**Input field:** the table's *Input fill* is the field **background**; the input **border** is `#EBEBEB` (light) / `#474747` (dark). All tokens above are 1:1 with `TrustechColors` in the Flutter codebase (`lib/src/core/constants/app_colors.dart`) — do not introduce new hex values.

### 3.2 Typography
Font family **Geist**. Scale: Display 32/800 · H1 24/700 · H2 20/700 · H3 17/600 · Body 16/500 & 14/500 · Caption 12/500 · Overline 11/700 (uppercase, +0.8 tracking). Headings use slight negative tracking (−0.3…−0.5). Body line-height 1.5. Use tabular figures for data columns/amounts (`number-tabular`). Min body 16 (`readable-font-size`). Both modes meet **4.5:1** body contrast (`color-accessible-pairs`).

### 3.3 Shape, spacing, elevation, icons
- Radius **8** (buttons/inputs/chips), **12** (cards/sheets), **999** (pills/avatars).
- **Flat** look: 1px bordered cards instead of heavy shadows; one consistent elevation scale.
- Spacing on a **4/8-pt** rhythm; screen padding 16; card padding 16; section tiers 16/24/32.
- Icons: **Material Symbols (outlined)**, one family, consistent stroke (`no-emoji-icons`, `icon-style-consistent`). Brand mark = `school` cap in teal; wordmark "Trustech**.**" with amber dot.
- Touch targets **≥44×44** with 8px spacing; respect safe areas / gesture bar.

---

## 4. Component & state kit (design once, reuse — put on a "Components" frame)

- **App bar:** flat, background = screen bg, title left (H2). Top-level screens show the **hamburger** at top-left (§6.2); deep screens show **back arrow**. Optional actions: search, filter, add.
- **Cards / list rows:** bordered, radius 12, 16 padding; leading icon/avatar, title + subtitle, trailing value/chip/chevron.
- **Status chips/badges:** pill, tinted bg (10–15% accent) + accent text (§3.1).
- **Buttons:** primary (filled teal), secondary (filled amber), outline, text, destructive (filled red); full-width in forms, 52px height; loading (spinner, disabled). One primary CTA per screen (`primary-action`).
- **Inputs:** label above field, radius 8, prefix icon, password show/hide, inline error in red below field; correct keyboard per type.
- **Forms:** grouped fields, sticky primary action at bottom; validate on blur; error states with recovery.
- **Required states for every list/detail:** **loading** (skeleton/shimmer >300ms), **empty** (icon + title + message + optional action), **error** (icon + message + retry), **success** (snackbar, green accent, auto-dismiss 3–5s).
- **Confirmations:** destructive/important actions (drop enrollment, reverse payment, publish grades, deactivate) use confirm dialog/sheet; offer undo where possible.
- **Bulk actions:** roster list with per-row segmented status control + single Save (used by attendance).
- **Mobile "tables":** never horizontal-scroll; render tabular data as stacked rows/cards with label–value pairs.
- **Scrim:** drawer/modal background scrim 40–60% black for legibility.

---

## 5. (reserved)

---

## 6. Information architecture & navigation

Two levels, clearly separated (`nav-hierarchy`, `avoid-mixed-patterns`): **bottom tabs = primary**, **top-left drawer = secondary/overflow + global**. Same placement on every screen (`navigation-consistency`). Phone uses bottom nav; ≥600dp uses a `NavigationRail`/sidebar with the same destinations (`adaptive-navigation`).

### 6.1 Bottom tabs — 4, fixed for every role (`bottom-nav-limit`, `bottom-nav-top-level`)
1. **Home** — role-aware dashboard (quick-action cards + summaries for the user's roles).
2. **Workspace** — role-aware **card grid** launching every permitted module (§7), grouped by section.
3. **Notifications** — own notifications, unread **badge** (`tab-badge`).
4. **Profile** — profile, settings (theme/language), change/verify password, **sign out**.

Active tab highlighted with teal indicator + filled icon (`nav-state-active`).

### 6.2 Top-left menu — navigation drawer (secondary / overflow, `drawer-usage`)
A **hamburger (three-line) icon at top-left** opens a slide-in drawer — the catch-all so the bottom bar never exceeds 4. Shown only on the **4 top-level tab screens**; deep screens show a back arrow instead.

Contents top→bottom:
1. **Header** — avatar (initials), name, email, role badges → opens Profile.
2. **Full module directory** (role-gated, same `moduleAccess`) — every accessible section grouped: *Teaching · Students & Admissions · Academics · Finance · People · Administration · Communication*. (Exhaustive index; Workspace is the faster grid — overlap is intentional, neither is the *only* path to a primary action.)
3. **App-level** — Settings, Help & Support, About / version.
4. **Footer** — **Sign out**, separated, destructive styling (`destructive-nav-separation`).

Opening dims with a 40–60% scrim; selecting a row routes into the **Workspace branch** stack and closes the drawer. On ≥600dp it becomes a permanent sidebar/extended rail (no hamburger).

### 6.3 Route tree (`go_router`, `StatefulShellRoute.indexedStack`)
Auth routes are **outside** the shell; the 4 tabs are **branches** (each its own Navigator → independent back stack + preserved state). Modules nest under the **Workspace branch** so the bottom bar stays visible (`persistent-nav`) and deep links activate the right tab.

```
/                         → redirect (auth + role aware)

# Auth (outside shell, full-screen)
/welcome  /login  /forgot-password  /reset-password  /verify-email

# Shell (bottom nav)
StatefulShellRoute.indexedStack
├─ Home        /home
├─ Workspace   /workspace
│   Teaching:   /courses · /courses/:id · /courses/:id/attendance · /courses/:id/attendance/:sessionId
│               /courses/:id/gradebook · /courses/:id/gradebook/:assessmentId
│   Students:   /students · /students/:id · /students/:id/transcript · /applicants · /applicants/:id · /enrollments
│   Academics:  /academics/faculties · /academics/departments · /academics/programs
│               /academics/programs/:id/curriculum · /academics/semesters · /academics/catalog · /academics/catalog/:id
│   Finance:    /finance/fee-structures · /finance/charges · /finance/charges/:id
│               /finance/payments · /finance/payments/:id · /finance/scholarships · /finance/reports
│   People:     /people/lecturers · /people/lecturers/:id
│   Admin:      /admin/users · /admin/users/:id · /admin/roles · /admin/permissions
│               /admin/audit-logs · /admin/audit-logs/:id · /admin/configs · /admin/email-logs · /admin/reports
│   Comms:      /announcements · /announcements/compose · /announcements/:id · /notifications/send
├─ Notifications  /notifications
└─ Profile        /profile · /settings · /change-password
```
Create/edit are **pushed full-screen routes** (`/students/new`, `/students/:id/edit`), not modals (`modal-vs-navigation`). Sheets/dialogs only for confirms, quick pickers, per-row notes.

### 6.4 Redirect & role-gating
One `redirect` driven by auth + roles: (1) unauthenticated → `/welcome`; (2) authenticated on an auth route → `/home`; (3) role-gated route the user lacks → `/home` or a small "no access" screen (`empty-nav-state`) — primary gate is hiding inaccessible modules in Home/Workspace/drawer; (4) `email_verified == false` → allow use + show a non-blocking "verify email" banner on Home.

### 6.5 Deep linking & notifications (`deep-linking`)
Every screen is addressable, so notifications map to routes: grade published → `/courses/:id/gradebook/:assessmentId`; fee/payment → `/finance/charges/:id`; applicant/enrollment → `/applicants/:id` or `/enrollments`; announcement → `/announcements/:id`. A deep link activates the right branch and builds a sensible back stack (module → Workspace → Home) (`back-stack-integrity`).

### 6.6 Behavior contracts
Predictable back with restored scroll + filters + input (`state-preservation`); bottom bar respects gesture/home indicator and lists add bottom inset (`fixed-element-offset`); forward nav animates left/up, back right/down (`navigation-direction`); 150–300ms transitions, reduced-motion respected.

---

## 7. Screen catalog

Format per screen: **roles** · purpose/content · primary actions · (states from §4 apply to every list/detail).

### 7.1 Shared (all staff)
- **Splash / Welcome** — teal→dark-teal gradient hero, `school` icon, "Trustech Staff", tagline ("Manage courses, attendance, grades and students — all in one place."), **Get Started** (amber) + **Login** (white outline).
- **Login** — email, password, "Forgot password?", **Sign in** (client_id/device_info sent silently).
- **Forgot password** → email → "code sent" confirmation.
- **Reset password** — code/token + new password + confirm.
- **Verify email** — status + "Send verification" + confirmation.
- **Change password** — current + new + confirm.
- **Profile** — avatar, name, email, role badges, phone; edit editable fields.
- **Settings** — theme (System/Light/Dark), language, about/version, **sign out**.
- **Notifications** — list (type icon, title, message, time, unread dot), mark-one-read, mark-all-read.

### 7.2 Teaching — **LECTURER**
- **Home cards (lecturer):** Today's classes, My courses count, Pending grading.
- **My Courses** — list (code, title, units, enrollment count, semester); filter by semester.
- **Course Detail** — header (code, title, semester, capacity); sections: Students (roster), Materials, Timetable, Syllabus.
- **Course Roster** — enrolled students (avatar, name, matric no) → read-only student summary.
- **Materials** — list (title, type chip, published); **Add material** (title, type, file path/URL, published); delete (confirm).
- **Timetable (course)** — entries (day, time, venue, type); add entry.
- **Attendance — sessions** — per course (date, topic, present/absent counts); **Create session** (date, topic).
- **Attendance — mark** — roster with per-student **Present/Absent/Late/Excused** + note; single **Save**; summary counts.
- **Attendance — records** — read-only student→status.
- **Gradebook — assessments** — list (name, type, max score, weight %, published?); **Create/Edit assessment**.
- **Gradebook — enter scores** — roster, numeric score per student (≤ max), auto % + letter shown.
- **Grades — publish** — publish toggles / "Publish all" (confirm — notifies students).
- **Compose announcement (course)** — title, body, priority, pin/urgent.

### 7.3 Students & Admissions — **REGISTRAR** (ADMIN/FINANCE/LECTURER: view)
- **Students** — searchable list (matric, name, program, level, status chip); filter program/level/status.
- **Student Detail** — profile + academic summary (enrollment count, standing/GPA); links to transcript, standing, enrollments, charges.
- **Create/Edit Student** — user link, matric no, program, level, session, status.
- **Student Transcript** — published grades grouped by course; GPA/CGPA.
- **Applicants** — list with status chips; filter status/program.
- **Applicant Detail** — application info, documents (add/remove), decision notes.
- **Applicant — update status** — status picker + notes.
- **Applicant — convert to student** — matric, program, level, session (only when ACCEPTED).
- **Enrollments** — list/filter (student/course/status); **Enroll**; row actions **Drop / Withdraw / Complete** (reason + confirm).

### 7.4 Academics — **REGISTRAR** (ADMIN: view)
- **Faculties** — list/create/edit (name, code, dean, status).
- **Departments** — list (filter faculty)/create/edit (name, code, faculty, HOD).
- **Programs** — list (filter dept)/create/edit (name, code, dept, duration, credits, award type).
- **Program Curriculum** — courses in a program (level, semester, core/elective); add/remove.
- **Semesters / Calendar** — list/create/edit (name, year, number, start/end, registration window, exam dates); **Activate** (confirm — deactivates others).
- **Course Catalog** — list/create/edit course (code, title, units, program, semester, capacity); **Assign lecturer**; **Prerequisites** (add/remove); **Set syllabus**; **Timetable**.

### 7.5 Finance — **FINANCE** (ADMIN: view)
- **Home cards (finance):** Outstanding balances total, Today's collections.
- **Fee Structures** — list/create/edit (name, code, category, amount, currency, applies-to, program/level scope, effective dates, mandatory).
- **Charges** — list; **Bill student** (student, semester, fee structure, amount, due date, discount); **Charge detail** (amount, paid, discount, balance, status chip); **Apply discount**.
- **Payments** — list; **Record payment** (student, charge, amount, method, ref, receipt no); **Payment detail**; **Reverse** (reason + confirm).
- **Scholarships** — list/create; **Award** (student, semester, amount/percentage).
- **Reports** — Outstanding balances (per student); Collection summary (totals, reversed, net).

### 7.6 People (HR) — **HR** (ADMIN: view)
- **Lecturers** — list/filter by department.
- **Create/Edit Lecturer** — user link, staff id, department, title, employment status, specialization.
- **Lecturer Detail** — profile + courses taught.

### 7.7 Administration & Analytics — **ADMIN** (non-super)
- **Admin Dashboard** — analytics tiles: users by status, enrollments by semester.
- **Users** — list/filter by status; **Detail**; edit profile; **change status** (activate/suspend/deactivate). *(No delete — super-admin only.)*
- **Roles & Permissions** — list roles; create role; list permissions (read); **assign role to user**; **assign permission to role**. *(Create permission = super-admin only — omit.)*
- **Audit Logs** — list + filters (user, entity, action, date range); **Detail** (action, entity, before/after, IP, time).
- **System Configs** — **read-only** list (key, value, category, sensitive flag). *(Editing = super-admin only.)*
- **Email Logs** — list (recipient, subject, status, sent time).

### 7.8 Communication — **STAFF / REGISTRAR / FINANCE / ADMIN**
- **Announcements** — list (title, target, priority/urgent/pinned, views); **Compose** (title, body, target type ALL/FACULTY/DEPARTMENT/PROGRAM/COURSE + target, priority, pin/urgent, expiry); **Publish**.
- **Send / Broadcast notification** — to specific users or all users of selected role(s); title, message, type, optional action link.

---

## 8. Output format (Pencil `.pen`)

- **Fidelity: HI-FI** — full brand color, real component styling (§4), realistic sample data, avatars, icons, and charts where relevant. Not grey-box wireframes. Generation is sequenced in `design/pro-app-followup.md`.
- Deliver as Pencil JSON compatible with `pro-app.pen` (root `{ "version":"2.10", "children":[ frames ] }`). **One screen = one `frame`** (`type:"frame"`, unique `id`, `name`, `x`/`y`, `width`, `height`, `fill`, `layout`, nested child elements).
- **Phone frame 390 × 844.** Lay frames left-to-right in flow order, grouped by module, ~80px gutters, new row per section.
- **Naming:** `Pro / <Section> / <Screen> (<Light|Dark>)` — e.g. `Pro / Teaching / Attendance — Mark (Light)`.
- Provide **Light + Dark** for: all shared screens (§7.1), Home, and one representative screen per module; remaining screens Light-only with a note that dark uses §3.1 dark tokens.
- Include a **Cover / Index** frame (screen list + nav map) and a **Components** frame (the §4 kit: buttons, chips, inputs, cards, states, bottom nav, drawer).

---

## 9. Acceptance checklist

- [ ] Color tokens (§3.1) applied exactly; light + dark covered for required screens.
- [ ] Typography, shape, spacing, icon rules (§3.2–3.3) followed.
- [ ] Component & state kit (§4) on a Components frame; every list/detail shows loading/empty/error/success.
- [ ] Navigation: 4 bottom tabs + top-left drawer (§6.1–6.2); active state, badge, scrim.
- [ ] Route tree, redirects, deep links honored (§6.3–6.5); back/state contracts (§6.6).
- [ ] All shared screens (§7.1) designed.
- [ ] Every module screen in §7.2–7.8 designed, each annotated with the roles that see it (§2); no super-admin-only screens.
- [ ] Valid `.pen` JSON, frames named per §8; Cover/Index + Components frames included.
