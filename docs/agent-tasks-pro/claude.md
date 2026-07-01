# Agent Task — CLAUDE (Staff/Pro app · Foundation · Shared/Shell/Auth · Communication)

I own the **shared foundation** (the gate for Codex & Gemini) plus the
**Shared/Shell/Auth**, **Communication**, and **Registrar notification-detail**
screens, and I **review** the other two agents.

App: `trustech_mobile_pro`. Design source: `design/stitch-staff/<folder>` (or the
Downloads export `stitch_trustech_staff_pro_app`). Spec: `design/pro-app-design-spec.md`.

## Phase 0 — FOUNDATION (must finish before Codex/Gemini start)
1. **UI kit parity** — confirm `src/shared/ui_kit/` matches the student kit (buttons, inputs, cards, chips, stat card, states, `AppHeaderBar`, `AppDrawer`, `SheetScaffold`, `SectionHeader`) and uses `TrustechTypography` + the light-mode contrast fix.
2. **UI-kit deltas (new for staff):**
   - `AnnouncementBanner` — top marquee/info banner ("New Announcement … View").
   - `WorkspaceModuleCard` — module-grid tile (icon, title, subtitle/metric, badge) for the Workspace hub.
   - `RosterStatusRow` — bulk roster row: avatar + name + id + P/A/L/E segmented control (+ note); used by attendance mark & grade entry.
   - `TrustechChart` — simple bar + donut wrapper using `chart1–5` (admin dashboard, finance reports).
   - `RoleBadge` — small role pill (LECTURER/REGISTRAR/…); `StackedField` label-value row for mobile "tables".
3. **Role-gating** — `src/core/auth/module_access.dart`: `Role` enum + `moduleAccess(Set<Role>)` → which modules/routes are visible. Single source feeding Workspace grid, drawer directory, and the router redirect.
4. **Shell** — `features/shell/presentation/main_shell.dart`: 4-tab `StatefulShellRoute.indexedStack` bottom nav **Home · Workspace · Alerts · Profile** + top-left hamburger opening `AppDrawer` (role-gated module directory).
5. **Router** — `src/router/app_router.dart`: auth routes outside shell; 4 tab branches; **all module routes nested under the Workspace branch** (so the bottom bar stays); every route from spec §6.3 wired to a **stub screen** (`StubScreen`) so Codex/Gemini can replace at known paths. Redirect: unauth→`/welcome`, role-gated→`/home`.
6. **Mock seed + `mockDelay`** helper; `StubScreen` ported.

> **Gate:** `flutter analyze` 0, app boots to shell, all 70 routes resolve to stubs, drawer + workspace render role-gated. Then hand the prompts to Codex & Gemini.

## Phase 1 — Auth & Account (6)
Welcome (`pro_shared_welcome_light/_dark`, `/welcome`) · Login (`pro_shared_login_light`+`_dark`+`_light_refined` — build all 3 variants, user picks, `/login`) · Forgot (`/forgot-password`) · Reset (`/reset-password`) · Verify Email (`/verify-email`) · Change Password (`/change-password`). Files under `features/auth/presentation/screens/`.

## Phase 2 — Shell screens (3)
Home dashboard (role-aware: verify-email banner, quick actions, summary cards, today's classes, pending grading — `pro_home_dashboard_light/_dark`, `/home`) · Workspace hub (role-gated module grid via `WorkspaceModuleCard` — `pro_workspace_hub_light`, `/workspace`) · Drawer (open state, `pro_shell_drawer_open_light` — realized as the live `AppDrawer`).

## Phase 3 — Account screens (3)
Profile (`/profile`) · Settings (theme/language sheets + sign out, `/settings`) · Notifications/Alerts (list, mark-read, `/notifications`).

## Phase 4 — Communication (4)
Announcements list (`/announcements`) · Announcement Detail (`/announcements/:id`) · Compose Announcement (`pro_communication_compose_announcement_dark`, `/announcements/compose`) · Broadcast Notification (`/notifications/send`). Files under `features/communication/`.

## Phase 5 — Registrar notification details (5)
One `NotificationDetailScreen` (`/notifications/:id`) rendering 5 type layouts from:
`pro_registrar_notification_results_light` · `_timetable_light` · `_calendar_update_light` · `_course_assignment_light` · `_announcement_light`. Build each type layout (selected by mock type), per the user's "build all 5" decision.

## Phase 6 — Review
Review Codex & Gemini phases; log findings in per-agent logs (`codex-review-log-pro.md` / `gemini-review-log-pro.md`)
(sections `# CODEX` / `# GEMINI`, dated `## Phase N`, severity 🔴/🟡/🔵, status ✅/⬜/🔁) —
same format as the student review log.

### DoD
Foundation gate met; all Claude screens light+dark, ui_kit reuse, mock providers, `flutter analyze` 0, routed.
