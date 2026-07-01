# Agent Task — GEMINI (Finance · Communication · Profile)

You implement the **Finance, Communication, and Profile/Settings** screens of the
Trustech **Student** Flutter app (`trustech_mobile`). Claude builds foundation/routing
and Auth; Codex builds Home/Courses/Timetable/Grades. Work only in **your** feature folders.

## ⛔ Start condition
Begin **only after Claude's Phase 1 (foundation) is done** — `MainShell`, the router, the
stub screens, and the UI kit must exist. **Replace your stub screens** with real hi-fi UI
(same file path + class name). **Do not edit** `src/shared/ui_kit/`, `src/router/`, or
`MainShell` — if you need a new route, ask Claude.

## Read first
- `docs/student-app-impl-overview.md` (conventions, §3 token reconciliation, duplicates).
- `docs/components-impl-plan.md` (UI kit to reuse).
- `docs/features-plan-2-impl-plan.md` + `features-plan-3-impl-plan.md` (per-screen detail for your screens).
- Design source: `design/stitch-student/<folder>/screen.png` + `code.html`.

## Golden rules
1. **UI ONLY — no backend.** Riverpod providers returning static mock under `features/<f>/data/mock/`; `// TODO(backend:)`.
2. **Use the UI kit:** `import 'package:trustech_mobile/src/shared/ui_kit/ui_kit.dart';` (`InfoListRow`, `InfoListCard`, `StatusChip`, `StatCard`, `AppHeaderBar`, `SheetScaffold`, `SegmentedSelectorRow`, `SuccessStateCard`, states…). No one-off widgets.
3. **Colors:** `TrustechColors`/`colorScheme` only; light **and** dark.
4. **Match** each screen's Stitch `screen.png`.
5. **Gate per screen:** `flutter analyze` 0 · routed · light+dark.
6. **Stay in your folders:** `features/finance/`, `features/communication/`, `features/profile/` only.

---

## Phase 1 — Finance A (3 screens)
| Screen | Stitch folder | Route | File · class |
|---|---|---|---|
| Finance Overview | `student_finance_overview_light_{1\|2}` (+ dark) | `/finance` | `features/finance/presentation/screens/finance_overview_screen.dart` · `FinanceOverviewScreen` |
| Charges | `student_finance_charges_light` | `/finance/charges` | `charges_screen.dart` · `ChargesScreen` |
| Charge Detail | `student_finance_charge_detail_light` | `/finance/charges/:id` | `charge_detail_screen.dart` · `ChargeDetailScreen` |
- Overview: big outstanding-balance card + next due + quick links. Charges: `InfoListRow` + status `StatusChip` (PAID/PARTIAL/OUTSTANDING/WAIVED) + empty. Detail: breakdown card + history.

## Phase 2 — Finance B & Communication A (3 screens)
| Screen | Stitch folder | Route | File · class |
|---|---|---|---|
| Payments | `student_finance_payments_light` | `/finance/payments` | `payments_screen.dart` · `PaymentsScreen` |
| Scholarships | `student_finance_scholarships_light` | `/finance/scholarships` | `scholarships_screen.dart` · `ScholarshipsScreen` |
| Announcements | `student_communication_announcements_light` | `/announcements` | `features/communication/presentation/screens/announcements_screen.dart` · `AnnouncementsScreen` |

## Phase 3 — Communication B & Profile A (3 screens)
| Screen | Stitch folder | Route | File · class |
|---|---|---|---|
| Announcement Detail | `student_communication_announcement_detail_light` | `/announcements/:id` | `announcement_detail_screen.dart` · `AnnouncementDetailScreen` |
| Notifications | `student_communication_notifications_light` (+ dark) | `/notifications` | `notifications_screen.dart` · `NotificationsScreen` |
| Profile Main | `student_profile_main_light_{1\|2}` | `/profile` | `features/profile/presentation/screens/profile_screen.dart` · `ProfileScreen` |
- Notifications: grouped list, unread dots, mark-all-read, empty state. Profile: avatar header, info card, menu `InfoListRow`s, separated Sign out → `/welcome`.

## Phase 4 — Profile B (2 screens)
| Screen | Stitch folder | Route | File · class |
|---|---|---|---|
| Settings | `student_profile_settings_light_{1\|2}` | `/settings` | `settings_screen.dart` · `SettingsScreen` |
| Change Password | `student_profile_change_password_light` | `/change-password` | `change_password_screen.dart` · `ChangePasswordScreen` |
- Settings rows open the theme/language sheets (Phase 5); show current theme/language.

## Phase 5 — Settings Sheets (2 screens)
| Screen | Stitch folder | Trigger | File · class |
|---|---|---|---|
| Theme Selection | `student_profile_theme_selection_sheet` | modal from Settings | `features/profile/presentation/widgets/theme_selection_sheet.dart` · `ThemeSelectionSheet` |
| Language Selection | `student_profile_language_selection_sheet` | modal from Settings | `.../widgets/language_selection_sheet.dart` · `LanguageSelectionSheet` |
- Use `SheetScaffold` + `SegmentedSelectorRow`. **These are real (local) behavior:** wire to `themeProvider` (System/Light/Dark) and `localeProvider` (English/Français) — they actually switch theme/locale.

### Per-phase DoD
All phase screens implemented (light+dark), reuse ui_kit, mock providers only, `flutter analyze` 0, reachable via existing routes. Hand off to Claude for integration.
