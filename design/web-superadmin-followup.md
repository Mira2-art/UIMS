# Super Admin Console — Build Playbook (follow-up prompts)

> Ordered batches to build the **hi-fi** Super Admin web console in **`frontend/`**
> (Vue 3 + Vite + TS + Tailwind + shadcn-vue + Pinia + vue-router + vue-i18n + axios).
> Run Batch 0 first, verify it runs (`yarn dev`) and renders, then proceed in order.
> Source of truth: **`design/web-superadmin-design-spec.md`**.

## Global rules (every batch)

- **Hi-fi = real shadcn-vue components** + realistic seed/mock data (names, codes, amounts, dates), lucide icons, charts where specified. Not static wireframes.
- **Tokens:** reuse `src/core/constants/app_colors.ts` + shadcn CSS vars (`src/assets/index.css`). **No new hex.** Light + dark (`darkMode: class`).
- **Structure:** feature-first — `src/features/<area>/{pages,components,store,api}`; shared UI in `src/components/ui` (shadcn) + `src/shared`; routes in `src/router`.
- **Data:** wire to the backend via axios (JWT + `X-Client-ID` web client); where an endpoint isn't ready, use a typed mock in the feature's `api` layer behind the same interface.
- **Quality:** responsive (sidebar ≥1024 → icon-rail → drawer); reusable `DataTable`; every list/detail has loading/empty/error; destructive ops confirm; a11y (contrast, keyboard, focus, aria).
- **After each batch:** stop; confirm `yarn dev` runs and the new routes render in light + dark.

---

## Batch 0 — Foundation (validate before continuing)
App shell + auth + primitives.
- **App shell:** left **Sidebar** (grouped nav, collapsible→rail→drawer) + **Top bar** (global search `⌘K`, breadcrumb, theme toggle, notifications, account menu) + content layout.
- **Auth:** `/login` page, Pinia **auth store**, `router.beforeEach` guard (SUPER_ADMIN only), axios interceptor (JWT + `X-Client-ID` + 401 refresh), `/403` + `/404`.
- **Primitives:** reusable **DataTable** (sort/filter/search/paginate/select/bulk/row-actions + states), page-header, form wrappers, confirm-dialog, toast, empty/error/skeleton.
- **Dashboard** `/admin`: KPI tiles + charts (enrollments by semester, users by role, revenue trend) + recent audit + system-health snippet.

> **Prompt:** "Build the **Super Admin console foundation** in `frontend/` per `design/web-superadmin-design-spec.md`: app shell (sidebar + topbar + theme), auth (login + Pinia store + router guard + axios interceptor with X-Client-ID), reusable DataTable + base states, and the Dashboard. Hi-fi, light + dark. Then stop so I can run it."

---

## Batch 1 — Access & Security
Users (+ Detail with **roles editor**, sessions, reset, **delete**), Roles, **Permission builder**, Client Apps (register/rotate/activate), Sessions, Audit Logs (+ Detail diff, export).

> **Prompt:** "Build the **Access & Security** section (Users + Detail/roles editor, Roles, Permissions builder, Client Apps, Sessions, Audit Logs + Detail). Hi-fi; confirm dialogs for delete/rotate/role-change."

---

## Batch 2 — Academics
Faculties, Departments, Programs, Program Curriculum, Semesters (activate), Courses (list + Detail: assign lecturer · prerequisites · timetable · syllabus · roster).

> **Prompt:** "Build the **Academics** section (Faculties, Departments, Programs, Curriculum, Semesters + activate, Courses list + Detail). Hi-fi."

---

## Batch 3 — People
Students (+ Detail: summary, transcript, standing, enrollments, charges), Lecturers (+ Detail), Applicants (+ Detail, status, convert), Enrollments (enroll/drop/withdraw/complete).

> **Prompt:** "Build the **People** section (Students + Detail, Lecturers + Detail, Applicants + Detail/convert, Enrollments). Hi-fi."

---

## Batch 4 — Finance
Fee Structures, Charges (+ Detail, bill, discount), Payments (+ Detail, record, **reverse**), Scholarships (+ award), Reports (outstanding + collection, charts, export).

> **Prompt:** "Build the **Finance** section (Fee Structures, Charges + Detail, Payments + Detail/reverse, Scholarships, Reports with charts). Hi-fi; confirm on reverse."

---

## Batch 5 — Communication
Announcements (list/compose/publish/Detail), Notifications (send/broadcast), Email Logs, Templates.

> **Prompt:** "Build the **Communication** section (Announcements + compose/publish, Notifications send/broadcast, Email Logs, Templates). Hi-fi."

---

## Batch 6 — Settings ★
Institution & Branding, System Config (editable table), Email/SMTP (+ test send), Localization, Auth Policy.

> **Prompt:** "Build the **Settings** section (Institution & Branding, System Config, Email/SMTP, Localization, Auth Policy). Hi-fi; super-admin only."

---

## Batch 7 — Platform ★
Integrations (API keys/webhooks), Backups & Recovery (trigger/schedule/restore), System Health (services, queues, email delivery).

> **Prompt:** "Build the **Platform** section (Integrations, Backups & Recovery, System Health). Hi-fi; super-admin only."

---

## Final QA pass
> **Prompt:** "Run the `ui-ux-pro-max` pre-delivery checklist over the whole console (contrast, keyboard/focus, table a11y/`aria-sort`, dark-mode parity, responsive sidebar→drawer, chart a11y, destructive confirms) and fix issues; run `yarn build`."

### Coverage map (sections → spec)
Foundation/Dashboard §6.1 · Access & Security §6.2 · Academics §6.3 · People §6.4 · Finance §6.5 · Communication §6.6 · Settings §6.7 · Platform §6.8 · Shared/auth §6.9. Full responsibility outline = spec §2.
