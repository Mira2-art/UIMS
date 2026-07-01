# Agent Task — CLAUDE (Foundation · Auth/Onboarding · Routing · Review)

You implement the **shared foundation**, the **Auth/Onboarding** screens, the **routing**,
and you do the **final integration review**. Two other agents work in parallel:
**Codex** (Home/Courses/Timetable/Grades) and **Gemini** (Finance/Communication/Profile).

## Read first (shared context)
- `docs/student-app-impl-overview.md` — conventions, token reconciliation, screen index, build order.
- `docs/components-impl-plan.md` — the UI kit (already implemented) + MainShell + mock-data convention.
- `docs/features-plan-1-impl-plan.md` — per-screen detail for Auth & Home & Courses-1.
- Design source (hi-fi): `design/stitch-student/<folder>/screen.png` + `code.html` (copy from the Stitch export if not in repo).

## Golden rules (all agents)
1. **UI ONLY — no backend.** Each screen reads from a Riverpod provider returning **static mock data** under `features/<f>/data/mock/`. Mark seams `// TODO(backend:)`.
2. **Use the UI kit:** `import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';` — do NOT create one-off buttons/cards/inputs.
3. **Colors:** `TrustechColors` / `Theme.of(context).colorScheme` only — no raw hex. Light **and** dark.
4. **Match the design:** reproduce the screen's Stitch `screen.png` layout/hierarchy.
5. **Quality gate per screen:** `flutter analyze` = 0 · boots · routed · light+dark.
6. **Ownership:** only Claude edits `src/shared/ui_kit/`, `src/router/`, and `MainShell`. Feature agents never touch those.

## Sequencing
**Your Phase 1 (foundation) blocks Codex & Gemini.** Finish it first and tell them to start.

---

## Phase 1 — Foundation (infra; do first) 🔒 blocks others
- Build `features/shell/presentation/main_shell.dart`: `StatefulShellRoute.indexedStack` + `AppBottomNav` (5 tabs: Home·Courses·Grades·Finance·Profile), preserved per-tab stacks.
- Rewrite `src/router/app_router.dart` with the **full route tree** from `student-app-design-spec.md` §6.2: auth routes outside the shell; 5 tab branches; all deep routes. Initial route `/splash`.
- Create **stub screens for ALL 28 screens** (every agent's screens) — each a simple `Scaffold` placeholder with the **exact file path + class name** in the registry (`docs/agent-tasks/screen-registry.md` or overview). This makes the app compile + every route reachable before features land; each agent replaces their stubs.
- Establish the **mock-data convention** (`features/<f>/data/mock/…` + provider) and a `mockDelay()` helper.
- Optional: `AppDrawer` wired to `AppHeaderBar.menu` if we keep a drawer (default: no drawer for student).
- **DoD:** `flutter run` boots to splash→welcome; bottom nav switches tabs; every route shows its placeholder; `flutter analyze` 0.

## Phase 2 — Onboarding & Auth A (3 screens)
| Screen | Stitch folder | Route | File · class |
|---|---|---|---|
| Splash | (brand splash; reuse `BrandGradientHeader`) | `/splash` | `features/auth/presentation/screens/splash_screen.dart` · `SplashScreen` |
| Welcome | `student_auth_welcome_light` (+ chosen dark) | `/welcome` | `.../welcome_screen.dart` · `WelcomeScreen` (exists — refine to design) |
| Login | `student_auth_login_light{_v2}` | `/login` | `.../login_screen.dart` · `LoginScreen` |
- Components: `BrandGradientHeader`, `TrustechButton`, `TrustechTextField`. Login submit → mock delay → `context.go('/home')`.

## Phase 3 — Auth B (3 screens)
| Screen | Stitch folder | Route | File · class |
|---|---|---|---|
| Forgot Password | `student_auth_forgot_password_light` | `/forgot-password` | `forgot_password_screen.dart` · `ForgotPasswordScreen` |
| Reset Password | `student_auth_reset_password_light` | `/reset-password` | `reset_password_screen.dart` · `ResetPasswordScreen` |
| Verify Email | `student_auth_verify_email_light` | `/verify-email` | `verify_email_screen.dart` · `VerifyEmailScreen` |
- Components: `TrustechTextField`, `TrustechButton`, `SuccessStateCard`.

## Phase 4 — Routing integration & review
- Verify every screen (yours + Codex + Gemini) is routed and reachable; nav callbacks use the documented routes; deep links resolve.
- Verify light/dark parity, `flutter analyze` = 0 across the app, boot smoke test.
- Review Codex/Gemini output for ui_kit reuse, no backend calls, design fidelity.

> Landing page = **web only** (see `design/web-landing-design-spec.md`) — not part of the student app.
