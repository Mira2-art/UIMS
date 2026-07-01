# Student App — UI Implementation Overview & Execution Guide

> Implementation plan for porting the **hi-fi Stitch design** of the Trustech
> Student Companion App into the existing Flutter app **`trustech_mobile`**.
> **Scope of this phase: UI ONLY — no backend wiring.** Screens render from static
> mock data; backend integration points are marked `// TODO(backend:)`.
>
> Read this file first, then `components-impl-plan.md`, then the feature plans
> (`features-plan-1-impl-plan.md` … `-3-`). Any AI/engineer can pick a feature plan
> and execute it independently once the **components plan** is done (it's the shared
> dependency).

---

## 1. Design source of truth

Hi-fi export (Google Stitch): each screen is a folder with **`code.html`** (Tailwind markup) + **`screen.png`** (render).
Current location: `/home/juniorbesong/Downloads/stitch_trustech_student_companion_app(1)/stitch_trustech_student_companion_app/<folder>`.

> **Action recommended:** copy the export into the repo at `design/stitch-student/` so every implementer (and other AIs) can access it. Plans reference screens by **folder name**; resolve against the design source dir.

For each screen: **match the screenshot's layout/spacing/hierarchy**, but implement with Flutter + the app's `ui_kit` and theme — **do not** copy Stitch's raw hex values (see §3).

---

## 2. Target codebase & conventions

- **App:** `trustech_mobile/` (Flutter, Material 3 + Cupertino-adaptive, Riverpod, go_router, vue… no — Flutter). Existing: `src/core/theme`, `src/core/constants/app_colors.dart` (`TrustechColors`), `src/shared/ui_kit/`, `src/shared/utils/theme_helper.dart`, `src/router/app_router.dart`.
- **Feature-first structure** per screen:
  ```
  src/features/<feature>/presentation/screens/<name>_screen.dart
  src/features/<feature>/presentation/widgets/<widget>.dart
  src/features/<feature>/data/mock/<name>_mock.dart      # static mock data (UI phase)
  src/features/<feature>/providers/<name>_provider.dart   # Riverpod provider returning mock
  ```
- **UI-only data rule:** NO `dio`/API calls this phase. Each screen gets its data from a Riverpod provider that returns **static mock data** (typed models in `data/mock/`). This keeps the swap-to-backend trivial later. Mark the seam: `// TODO(backend): replace mock with <endpoint>`.
- **Navigation:** add routes to `src/router/app_router.dart` using the route tree in `design/student-app-design-spec.md` §6.2; the 5 tabs use `StatefulShellRoute.indexedStack` via the `MainShell` (built in the components plan).
- **Light + dark:** rely on `ThemeData` (already wired). Implement every screen for both; the design shows one representative theme per screen.
- **State variants:** implement loading / empty / error where the design provides them (and where a list/detail logically needs them).
- **Quality gate per screen:** visually matches the screenshot (light & dark), `flutter analyze` = 0 issues, no backend calls, routed and reachable.

---

## 3. Color / token reconciliation (important)

The Stitch `DESIGN.md` uses a Material-3 palette where `primary = #206172` and `primary-container = #3d7a8c`. **The implementation standardizes on the existing codebase tokens** in `TrustechColors` — brand **primary = `#3D7A8C`** (teal), secondary `#E8A847` (amber), with the full light/dark set already defined. Map the design's teal family → `TrustechColors.primary`; never introduce new hex. Use `Theme.of(context).colorScheme` / `TrustechColors` / `context` theme helpers only.

---

## 4. Duplicates — YOUR CHOICE NEEDED

The export contains multiple variants of some screens. Pick one per row (default = my recommendation). Implementation uses the chosen variant; the other is ignored.

| # | Screen | Variants | Recommendation |
|---|--------|----------|----------------|
| 1 | Welcome (dark) | `welcome_dark_1` · `welcome_dark_2` | _your pick_ |
| 2 | Login (light) | `login_light` · `login_light_v2` | _your pick_ |
| 3 | Login (dark) | `login_dark` · `login_dark_v2` | _your pick_ (match #2) |
| 4 | **Home (light)** | `home_dashboard_light` · `home_dashboard_light_v2` | **v2** (no drawer, teal Pay-Now finance card, cleaner) ✔ viewed |
| 5 | **Home (dark)** | `home_dashboard_dark` · `home_dashboard_dark_v2` | **v2** (match light) |
| 6 | Course Detail | `courses_detail_light_1` · `courses_detail_light_2` | _your pick_ |
| 7 | Finance Overview (light) | `finance_overview_light_1` · `finance_overview_light_2` | _your pick_ |
| 8 | Profile Main | `profile_main_light_1` · `profile_main_light_2` | _your pick_ |
| 9 | Profile Settings | `profile_settings_light_1` · `profile_settings_light_2` | _your pick_ |

> **Drawer note:** Home **v1** shows a top-left hamburger (a navigation drawer) — this contradicts the spec's "no drawer, 5 tabs" decision. Home **v2** has no drawer (avatar + wordmark). Choosing **v2** keeps the app drawer-free as specced. If you pick v1, we add a drawer (and I'll update the components plan).

---

## 5. Out of scope as Flutter screens

- `student_communication_notification_banner_light`, `student_communication_lock_screen_notification` → OS push-notification mockups; implemented later with the push integration, not as app screens.
- `academic_clarity` (design tokens only), `student_project_cover_index` (index), `student_shared_components_kit` → drives the **components plan**, not a screen.

---

## 6. Screen index (27 screens) & file grouping

**Components plan** (`components-impl-plan.md`) — shared first, blocks everything.

**`features-plan-1-impl-plan.md` (screens 1–10): Auth · Home · Courses (part 1)**
1. Welcome · 2. Login · 3. Forgot Password · 4. Reset Password · 5. Verify Email · 6. Home Dashboard · 7. My Courses · 8. Course Registration · 9. Course Detail · 10. Course Materials

**`features-plan-2-impl-plan.md` (screens 11–20): Courses (part 2) · Timetable · Grades · Finance · Communication (part 1)**
11. Course Attendance · 12. Weekly Timetable · 13. Transcript · 14. Academic Standing · 15. Finance Overview · 16. Charges · 17. Charge Detail · 18. Payments · 19. Scholarships · 20. Announcements

**`features-plan-3-impl-plan.md` (screens 21–27): Communication (part 2) · Profile & Settings**
21. Announcement Detail · 22. Notifications · 23. Profile Main · 24. Settings · 25. Change Password · 26. Theme Selection (sheet) · 27. Language Selection (sheet)

---

## 7. Build / dependency order (for parallel execution)

1. **Components plan** (theme reconciliation + `ui_kit` additions + `MainShell` bottom nav + mock-data convention). **Must be done first** — all feature plans depend on it.
2. Then feature plans can run **in parallel** by different implementers:
   - Plan 1 (Auth + Home + Courses-1) — also finalizes auth routes + the shell tabs.
   - Plan 2 (Courses-2 + Timetable + Grades + Finance + Comms-1).
   - Plan 3 (Comms-2 + Profile).
3. Integration review (me): routing wired, nav consistent, light/dark parity, analyze clean.
4. You test each feature as it lands.

---

## 8. Definition of done (whole phase)
- [ ] All 27 screens implemented per chosen variants, light + dark.
- [ ] Reuses `ui_kit` + new shared components from the components plan; no duplicate one-off widgets.
- [ ] No backend calls; all data from mock providers with `TODO(backend:)` seams.
- [ ] All routes wired; 5-tab shell + deep routes reachable.
- [ ] `flutter analyze` = 0 issues; smoke test boots to Home.
