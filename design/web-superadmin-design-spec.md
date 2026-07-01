# Trustech **Super Admin Web Console** — Master Design Spec

> Single source of truth for the Super Admin web back-office. Self-contained.
> Stack: **Vue 3 + Vite + TypeScript + Tailwind + shadcn-vue (radix-vue) + Pinia +
> vue-router + vue-i18n + axios + lucide** (the existing `frontend/`). Brand tokens
> already wired in `frontend/src/core/constants/app_colors.ts` + `src/assets/index.css`
> (shadcn HSL vars) — **reuse them, introduce no new hex.** Decisions cite
> `ui-ux-pro-max` rule IDs.

---

## 1. Context

- **What:** the institution's **back-office web console** — desktop-first, responsive. Product type = **Admin panel / Dashboard**.
- **Who:** **SUPER_ADMIN** — the highest authority. Can do **everything** the staff (Pro) app can, **plus** the super-admin-only operations the Pro app excludes (create permissions, edit system config, delete users, manage client apps), **plus** platform-level concerns (settings, integrations, backups, analytics). Other staff roles may later get scoped web access using the same console with role-gated nav; v1 targets the super admin.
- **Why web (not mobile):** dense data tables, multi-column forms, bulk operations, analytics, and configuration are far better on a large screen.

---

## 2. Super Admin responsibilities — full platform to-do outline

Everything below is a console area the super admin owns. (★ = super-admin-exclusive, not in the Pro app.)

### A. Identity, Access & Security (RBAC — "change roles and all that")
- **Users:** full lifecycle — create, edit, **delete ★**, activate/suspend/deactivate, trigger password reset, force email re-verify.
- **Roles:** create / edit / delete roles; describe and group them.
- **Permissions ★:** create / edit permissions; **permission builder** — assign permissions to roles.
- **Role assignment:** assign / remove **any role to/from any user** (the core "change roles" flow), with audit trail.
- **Client apps ★:** register, list, **rotate `client_id`**, activate / deactivate the web / student / staff client credentials.
- **Sessions:** view active user sessions; revoke.
- **Audit & compliance:** full audit-log access, filter (user/entity/action/date), view before→after diffs, export.

### B. System Configuration & Platform Settings ★
- Edit **system config** values / feature flags / defaults.
- **Institution profile & branding** (name, logo, brand colors, contact).
- **Academic calendar** defaults; grading scale; registration-window policy.
- **Email / SMTP** settings (Gmail credentials), notification preferences, email templates.
- **Localization** defaults (en/fr) and currency.
- **Auth policy:** token TTLs, password policy, session limits.

### C. Academic structure & operations oversight (acts across all staff roles)
- Faculties · Departments · Programs · Semesters (activate) · Curriculum.
- Course catalog · lecturer assignment · prerequisites · timetable.
- Students · Lecturers · Applicants/Admissions · Enrollments (enroll/drop/withdraw/complete).
- Grades, attendance and academic-standing oversight.

### D. Finance oversight
- Fee structures · student charges/billing · payments + **reversals** · discounts · scholarships & awards · financial reports (outstanding, collection).

### E. Communication
- Institution-wide announcements (compose/publish/target) · broadcast notifications by role · email logs · template management.

### F. Analytics & Reporting (platform-wide)
- Dashboards: users by status/role, enrollments by semester, revenue/collections, attendance, academic performance; trends; CSV/image export.

### G. Data & Integrations (platform/MOD-8) ★
- **Data backup & recovery** (trigger/schedule, restore points).
- **Integration management** (third-party services, API keys, webhooks).
- **System health / monitoring** (service status, job queues, email delivery).

---

## 3. Design system (web — reuse existing tokens)

### 3.1 Color (already in `app_colors.ts` / shadcn CSS vars — do not change)
Brand: primary teal `#3D7A8C` (`--primary 193 39% 39%`), secondary amber `#E8A847` (`--secondary 36 79% 59%`). Destructive `#DC3545`, success `#34C759`. Light: bg `#FAFAFA`, fg `#252525`, card `#FFFFFF`, muted `#F7F7F7`/fg `#8E8E8E`, border/input `#EBEBEB`, ring `#B5B5B5`. Dark: bg `#252525`, card `#343434`, muted `#454545`/fg `#B5B5B5`, border `#474747`, input `#404040`. Chart palette: `#9BB8ED #6B7FD4 #5A6BC7 #4A5AB8 #3A4A9A`. `--radius: 0.5rem` (8px). Light + dark both first-class (`darkMode: class`).

### 3.2 Typography
Sans **Geist** (Inter fallback). Desktop scale: Display 36/700 · H1 30/700 · H2 24/600 · H3 20/600 · H4 18/600 · Body 14 & 16/400-500 · Caption 12. Line-height 1.5; tabular figures for tables/amounts (`number-tabular`). Body ≥14 in dense tables, ≥16 in forms/marketing.

### 3.3 Shape, spacing, density
Radius via `--radius` (lg 8 / md 6 / sm 4). Tailwind spacing scale (4px base). Container max `1400px` (2xl), padding 2rem. Admin density is **comfortable-compact**: 40–44px row height, 12–16px cell padding. Flat surfaces, 1px borders, subtle shadow only for popovers/dialogs/sheets. Icons: **lucide**, 1 family, 18–20px.

---

## 4. Component & state kit (shadcn-vue — build once)

- **App frame:** persistent **left sidebar** (grouped nav, collapsible to icon rail) + **top bar** (global search `⌘K`, breadcrumb, theme toggle, notifications, account menu). Content area with page header (title + primary action) + body.
- **Data table** (the workhorse): column sort (`aria-sort`), filter bar, global search, pagination, page-size, row selection + **bulk actions**, row actions (kebab/menu), sticky header, empty/loading(skeleton)/error states. Responsive → stacked cards under `md` (`data-table`, no horizontal scroll on small).
- **Detail:** route page **or** right-side **Sheet** for quick view; **breadcrumbs** for 3+ levels (`breadcrumb-web`).
- **Forms:** shadcn Form + zod-style validation; grouped fieldsets, inline errors, required markers, sticky footer actions; multi-step with progress where needed.
- **Dialogs / sheets:** create/edit, confirmations for destructive (`destructive-emphasis`); **confirm before delete/reverse/rotate/role-change**; scrim 40–60%.
- **Buttons:** primary (teal), secondary (amber), outline, ghost, destructive; loading state.
- **Inputs / selects / combobox / date-range / switches / chips-badges** (status accents from §3.1).
- **Charts:** lucide+chart lib; legends, tooltips, accessible palette, empty/loading/error, responsive, CSV export (`chart-*` rules).
- **Toasts:** success/error, `aria-live`, auto-dismiss 3–5s, undo for bulk/destructive where possible.
- **States everywhere:** loading (skeleton), empty (icon+message+action), error (retry), success (toast).

---

## 5. Information architecture & navigation

**Pattern:** persistent left **sidebar** (primary nav, grouped) + top bar (secondary/global). `adaptive-navigation`: sidebar ≥1024px; icon-rail 768–1024; off-canvas drawer < 768. `nav-state-active` highlights current; `back-behavior`/`state-preservation` keep table filters & scroll on return; deep-linkable routes (`deep-linking`).

**Sidebar groups → primary destinations:**
1. **Dashboard** — `/admin`
2. **Access & Security** — Users, Roles, Permissions, Client Apps, Sessions, Audit Logs
3. **Academics** — Faculties, Departments, Programs, Semesters, Curriculum, Courses
4. **People** — Students, Lecturers, Applicants, Enrollments
5. **Finance** — Fee Structures, Charges, Payments, Scholarships, Reports
6. **Communication** — Announcements, Notifications, Email Logs, Templates
7. **Settings** — Institution & Branding, System Config, Email/SMTP, Localization, Auth Policy
8. **Platform** — Integrations, Backups & Recovery, System Health

**Route tree (`vue-router`):**
```
/                         → public landing (separate spec)
/login                    → console auth (super admin)
/admin                    → Dashboard (guarded: SUPER_ADMIN)
/admin/access/users · /users/:id · /roles · /roles/:id · /permissions · /clients · /sessions · /audit-logs · /audit-logs/:id
/admin/academics/faculties · /departments · /programs · /programs/:id/curriculum · /semesters · /courses · /courses/:id
/admin/people/students · /students/:id · /lecturers · /lecturers/:id · /applicants · /applicants/:id · /enrollments
/admin/finance/fee-structures · /charges · /charges/:id · /payments · /payments/:id · /scholarships · /reports
/admin/comms/announcements · /announcements/:id · /notifications · /email-logs · /templates
/admin/settings/institution · /system-config · /email · /localization · /auth-policy
/admin/platform/integrations · /backups · /health
```
Guard: a `vue-router` `beforeEach` requiring an authenticated SUPER_ADMIN (Pinia auth store); non-admins → `/login` or `/403`. Create/edit = routed pages or dialogs/sheets; destructive ops always confirm.

---

## 6. Screen catalog

Format: **screen · purpose/content · primary actions** (states from §4 apply to all tables/details).

### 6.1 Dashboard
- **Overview** — KPI tiles (total users by status, active students, lecturers, enrollments this semester, outstanding balance, today's collections); charts (enrollments by semester, users by role, revenue trend, attendance rate); recent audit activity; system-health snippet.

### 6.2 Access & Security
- **Users** — table (name, email, status, roles, last login); filters; create; bulk status; row → detail.
- **User Detail** — profile, status controls, **roles editor** (add/remove roles), sessions, reset password, **delete ★**, activity/audit for this user.
- **Roles** — list (name, code, #users, #permissions); create/edit/delete.
- **Role Detail / Permission Builder ★** — role meta + permission matrix (toggle permissions by module).
- **Permissions ★** — list/create/edit (name, code, module).
- **Client Apps ★** — list (name, platform, client_id masked, active); register, rotate, activate/deactivate.
- **Sessions** — active sessions (user, device, ip, issued/expiry); revoke.
- **Audit Logs** — table + rich filters (user, entity, action, date range); **Detail** with before→after diff; export.

### 6.3 Academics
- **Faculties / Departments / Programs / Semesters** — tables + create/edit; semester **Activate**.
- **Program Curriculum** — courses in program (level, semester, core/elective); add/remove.
- **Courses (catalog)** — table + create/edit; **Course Detail** (assign lecturer, prerequisites, timetable, syllabus, roster).

### 6.4 People
- **Students** — table (matric, name, program, level, status); create/edit; **Detail** (summary, transcript, standing, enrollments, charges).
- **Lecturers** — table (staff id, name, dept, status); create/edit; **Detail** (courses taught).
- **Applicants** — table (status, program); **Detail** (docs, decision); status update; **convert to student**.
- **Enrollments** — table/filters; enroll; drop / withdraw / complete.

### 6.5 Finance
- **Fee Structures** — table + create/edit.
- **Charges** — table; **bill student**; **Detail** (balance, discount); apply discount.
- **Payments** — table; record; **Detail**; **reverse** (confirm).
- **Scholarships** — list/create; award.
- **Reports** — outstanding balances + collection summary, with charts + export.

### 6.6 Communication
- **Announcements** — table; compose (target type + priority + schedule); publish; **Detail**.
- **Notifications** — send / broadcast by role.
- **Email Logs** — delivery table (recipient, subject, status, sent).
- **Templates** — manage email templates.

### 6.7 Settings ★
- **Institution & Branding** — name, logo, brand colors, contact.
- **System Config** — editable config table (key, value, type, category, sensitive).
- **Email / SMTP** — Gmail/SMTP credentials, test-send.
- **Localization** — default language, currency.
- **Auth Policy** — token TTLs, password policy, session limits.

### 6.8 Platform ★
- **Integrations** — third-party services, API keys, webhooks (add/revoke).
- **Backups & Recovery** — backup list, trigger backup, restore points, schedule.
- **System Health** — service status, queue/worker status, email delivery health.

### 6.9 Shared
- **Login** — email + password (client_id/device handled).
- **Account** — own profile, change password, theme/language, sign out.
- **403 / Not authorized** · **404**.

---

## 7. Build & output notes (for implementation)

- Implement in `frontend/` (Vue 3 + shadcn-vue). Feature-first under `src/features/<area>/` (components/pages/store/api), shared UI in `src/components/ui` (shadcn) and `src/shared`.
- Reuse tokens in `src/core/constants/app_colors.ts` + shadcn CSS vars; **no new hex**.
- Tables: one reusable `DataTable` wrapper (sort/filter/paginate/select) used by every list.
- Auth + role guard via Pinia store + `router.beforeEach`; axios interceptor adds JWT + `X-Client-ID` (web client_id) and handles 401 refresh.
- i18n strings via vue-i18n (en/fr already scaffolded).
- Responsive: sidebar → rail → drawer; tables → cards under `md`.

## 8. Acceptance checklist
- [ ] Tokens reused from code; light + dark; no new hex.
- [ ] Sidebar IA (§5) with grouped nav; active state; breadcrumbs on deep pages.
- [ ] Every §2 responsibility has a screen in §6 (incl. all ★ super-only areas).
- [ ] Reusable DataTable with sort/filter/paginate/bulk + loading/empty/error.
- [ ] Destructive ops (delete user, reverse payment, rotate client, role change) confirm.
- [ ] Charts have legend/tooltip/empty/loading + accessible palette + export.
- [ ] Route guard restricts the console to SUPER_ADMIN.
- [ ] Accessibility: contrast 4.5:1, keyboard nav, focus states, aria on tables/forms.
