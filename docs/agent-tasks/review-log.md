# Agent Review Log — Student App UI Implementation

Running log of issues found during Claude's review of each agent's phases. Add a new
dated subsection per phase per agent. Keep Codex and Gemini separate.

**Severity:** 🔴 blocking (won't compile / breaks contract) · 🟡 minor (fidelity/convention) · 🔵 cross-cutting (shared decision).
**Status:** ✅ fixed · ⬜ open · 🔁 verify.

---

# CODEX  (Home · Courses · Timetable · Grades)

## Phase 1 — Home, My Courses, Course Registration — reviewed 2026-06-06
Overall: **clean compile, high fidelity.** No blocking issues. Minor only.

| # | Sev | File | Issue | Status |
|---|-----|------|-------|--------|
| C1.1 | 🟡 | `features/home/presentation/screens/home_screen.dart` | `unreadCount: 3` hardcoded in `AppHeaderBar.home` — should come from a notifications provider. | ⬜ open |
| C1.2 | 🟡 | `features/courses/presentation/screens/my_courses_screen.dart` | `avatarName: 'John Doe'` hardcoded (Home correctly uses `summary.studentName`). Source from a user provider. | ⬜ open |
| C1.3 | 🟡 | `features/courses/presentation/screens/course_registration_screen.dart` | Units badge uses an embedded newline `'${course.units}\nUnits'` — verify it renders cleanly on narrow widths (consider a 2-line Column instead). | 🔁 verify |
| C1.4 | 🔵 | `home_screen.dart`, `my_courses_screen.dart` | Uses `AppHeaderBar.home` (avatar + bell) on a non-Home tab root. Consistency decision across all 5 tab roots — to be standardized by Claude in Phase 4 integration. Not a Codex defect. | ⬜ open (Phase 4) |

## Phase 2 — Course Detail, Materials, Attendance — reviewed 2026-06-07
Overall: **clean compile, high fidelity, exemplary.** No blocking issues. All three screens consume `courseDetailProvider` / `courseMaterialsProvider` / `courseAttendanceProvider`, use `AppHeaderBar.back`, reuse ui_kit (`ProgressRing` with threshold accent, `StatCard`, `InfoListCard`, `StatusChip`, `TrustechEmptyState`, `SheetScaffold`), handle empty states, and mark `// TODO(backend:)` seams. The reference others should follow.

| # | Sev | File | Issue | Status |
|---|-----|------|-------|--------|
| C2.1 | 🔁 | `course_detail_screen.dart` | "Weekly Timetable" row navigates to `/home/timetable` (cross-tab jump, loses course context) and "Grades" → `/grades`. Acceptable for mock; verify these resolve and feel right once routing is integrated. | 🔁 verify |
| C2.2 | 🟡 | `course_detail_screen.dart`, `course_materials_screen.dart`, `course_attendance_screen.dart` | Each defines a private `_materialIcon` / `_statusIcon` / accent helper at file scope — `_materialIcon` is duplicated verbatim in detail **and** materials. Trivial; could move to a shared `courses` util. | ⬜ open |

## Phase 3 — Weekly Timetable, Transcript, Academic Standing — reviewed 2026-06-07
Overall: **clean compile, high fidelity.** No blocking. All three consume their providers (`timetableProvider`, `transcriptProvider`, `standingProvider`), reuse ui_kit (`ProgressRing`/`ProgressBar`, `StatCard`, `InfoListCard`, `StatusChip`, `SectionHeader`, `TrustechEmptyState`), and tap through to course detail. Codex also anchored Geist via `TrustechTypography.fontFamily` in its custom widgets — consistent with the kit work.

| # | Sev | File | Issue | Status |
|---|-----|------|-------|--------|
| C3.1 | 🟡 | `features/grades/presentation/screens/transcript_screen.dart` | `AppHeaderBar.home(title: 'Grades', avatarName: 'John Doe')` — hardcoded avatar name (same family as C1.2 / G1.5). Source from a user provider; standardize tab-root headers in Phase 4 integration. | ⬜ open |
| C3.2 | 🟡 | `features/grades/presentation/screens/academic_standing_screen.dart` | `_GraduationProgressCard` title is hardcoded `'Exceptional Work'` regardless of `standing.status` — would show even on probation. Make the headline conditional on the actual standing. | ⬜ open |
| C3.3 | 🔵 | `transcript_screen.dart`, `academic_standing_screen.dart` | `_standingKind` (and `_gradeKind`) defined at file scope in both — duplicated. Move to a shared `grades` util (same as C2.2's `_materialIcon`). | ⬜ open |
| C3.4 | 🟡 | all 3 P3 files | Import ordering: `core/constants/app_typography.dart` is placed before the `package:flutter_riverpod` import (groups out of order). Cosmetic — analyze is clean — but tidy for consistency. | 🔁 verify |

**Good:** timetable day-selector + empty-day state; transcript semester grouping with letter-grade chips; standing `ProgressRing` + graduation `ProgressBar`.

---

# GEMINI  (Finance · Communication · Profile)

## Phase 1 — Finance Overview, Charges, Charge Detail — reviewed 2026-06-06
Overall: **strong work, high fidelity** — but shipped with **4 blocking errors** (since fixed) from using a non-existent `ui_kit` API and breaking a router contract. Plus minor fidelity gaps.

### Blocking (were breaking the build) — now fixed
| # | Sev | File | Issue | Status |
|---|-----|------|-------|--------|
| G1.1 | 🔴 | `finance_overview_screen.dart`, `charges_screen.dart`, `charge_detail_screen.dart` | Used `MainAxisAlignment.between` — not a valid Dart value. Correct: `MainAxisAlignment.spaceBetween`. | ✅ fixed |
| G1.2 | 🔴 | `finance_overview_screen.dart` | `SectionHeader(color: …)` — `SectionHeader` has no `color` param (only `title`, `actionLabel`, `onAction`). | ✅ fixed |
| G1.3 | 🔴 | `charge_detail_screen.dart` | `TrustechButton(text:, type: TrustechButtonType.outline)` — wrong API. Correct: `TrustechButton(label:, variant: TrustechButtonVariant.outline)`. No `text`/`type`/`TrustechButtonType`. | ✅ fixed |
| G1.4 | 🔴 | `charge_detail_screen.dart` | Renamed the screen constructor param `chargeId` → `id`, breaking the router (which passes `chargeId`). Param-screen constructors are fixed by the router contract. | ✅ fixed |

### Minor (fidelity / convention)
| # | Sev | File | Issue | Status |
|---|-----|------|-------|--------|
| G1.5 | 🟡 | `finance_overview_screen.dart` | Header uses `AppHeaderBar.home(title: 'Finance')` → shows "Finance"; design shows the **"Trustech" wordmark**. | ⬜ open |
| G1.6 | 🟡 | `finance_overview_screen.dart` | Current-semester amounts use `InfoListRow.trailingText` (renders teal/primary); design shows near-black with **red for overdue** and negative grants distinct. Use a `trailing:` Text with the right color. | ⬜ open |
| G1.7 | 🟡 | `charges_screen.dart` | Charges list renders straight from a sync provider with **no empty / loading state** (plan requires both). Add an empty state + optional `mockDelay` skeleton. | ⬜ open |
| G1.8 | 🟡 | `charges_screen.dart` | Title "Charges" omits the design's **amber accent dot** ("Charges."). Trivial. | ⬜ open |
| G1.9 | 🔁 | `finance_overview_screen.dart` | Verify `_QuickLinks` nav targets resolve (All Charges → `/finance/charges`, Payments → `/finance/payments`, Scholarships → `/finance/scholarships`). | 🔁 verify |

---

## Phase 2 — Payments, Scholarships, Announcements — reviewed 2026-06-06
Overall: **clean compile, no blocking issues** (`flutter analyze lib/src/features/finance lib/src/features/communication` → No issues found). Payments and Announcements wire to their providers/mock correctly. **Main defect: `scholarships_screen.dart` ignores its provider/mock and hardcodes all content inline** — inconsistent with every other Gemini screen. Plus recurring header/avatar hardcoding (same family as G1.5).

| # | Sev | File | Issue | Status |
|---|-----|------|-------|--------|
| G2.1 | 🟡 | `finance/presentation/screens/scholarships_screen.dart` | Imports **only** `ui_kit` + `intl` — does **not** use `scholarshipsProvider` / `FinanceMock.scholarships` (both exist, now unused). All data hardcoded inline in `_ActiveScholarshipCard` ('Merit Scholarship', '$12,500'), `_ApplicationProgressCard` (×2), `_OpportunityCard`. Breaks the "screens read from Riverpod mock providers" convention used everywhere else. Source from the provider; extend the `Scholarship` mock model with the richer fields (active grant, applications, opportunities) if needed. | ⬜ open |
| G2.2 | 🟡 | `communication/presentation/screens/announcements_screen.dart` | Pushed route uses `AppHeaderBar.home(...)` (avatar leading, **no back button**) — a pushed full-screen route should expose a back affordance. Also `avatarName: 'John Doe'` hardcoded. Use `AppHeaderBar.back`/`.home` consistently and source the avatar from a user provider (same family as G1.5 / C1.2). | ⬜ open |
| G2.3 | 🟡 | `scholarships_screen.dart` | Header title `'Trustech'` on `AppHeaderBar.back` with avatar action — fine, but `_OpportunityCard` uses a hardcoded remote `imageUrl` (`Image.network`). For UI-only/offline-safe mock, prefer a gradient/asset placeholder (see `announcement_detail` fallback) or a `errorBuilder`. | 🔁 verify |
| G2.4 | 🟡 | `communication/presentation/screens/announcement_detail_screen.dart` (P3, noted here) | Custom `SliverAppBar` hero (acceptable — `AppHeaderBar` can't collapse), but: (a) event details hardcoded (`'14:00 - 16:30 GMT'`, `'Great Hall, Main Campus'`) not from the model; (b) empty state is a bare `Center(Text('Announcement not found'))` instead of `TrustechEmptyState` (Charge detail uses the empty-state widget); (c) `Image.network` without `errorBuilder`. | ⬜ open |
| G2.5 | 🔁 | `payments_screen.dart` | Uses `paymentsProvider` + `financeOverviewProvider` + mock correctly, `AppHeaderBar.back(title: 'Finance')`. Verify the receipt/download actions and any nav targets resolve. | 🔁 verify |

**Good:** `payments_screen.dart` and `announcements_screen.dart` both consume providers + mock as intended; announcements adds a category filter + featured/others split that matches the design.

## Phase 3 — Announcement Detail, Notifications, Profile — reviewed 2026-06-07
Overall: **clean compile, no blocking.** Profile + Notifications consume their providers (`userProfileProvider`, `notificationsProvider` / `filteredNotificationsProvider`) and Profile correctly sources the avatar from the provider (good — no hardcoding). Main issues: a non-functional logout, a recurring one-off section-label widget, and the announcement-detail gaps already noted in G2.4.

| # | Sev | File | Issue | Status |
|---|-----|------|-------|--------|
| G3.1 | 🟡 | `profile/presentation/screens/profile_screen.dart` | "Logout from Trustech" button is a no-op (`// TODO(backend): implement logout`). The plan specifies **Sign out → `/welcome`** — this is local navigation that should work now. Use `context.go('/welcome')`. | ⬜ open |
| G3.2 | 🔵 | `profile_screen.dart`, `settings_screen.dart` | Both define a private `_SectionTitle` widget (duplicated) instead of reusing ui_kit `SectionHeader`. Golden rule: no one-off widgets. Consolidate or justify (the design's tiny uppercase label differs from `SectionHeader`'s style — if intentional, add a ui_kit variant rather than per-file copies). | ⬜ open |
| G3.3 | 🟡 | `communication/presentation/screens/notifications_screen.dart` | Unread dot uses `cs.secondaryContainer` (a near-surface tone) → very low contrast against the card. Use `cs.secondary`/`cs.primary` for the unread accent. Also the "Today" group's "Mark all as read" is a TODO no-op while the app-bar `markAllAsRead()` works. | ⬜ open |
| G3.4 | 🟡 | `communication/presentation/screens/announcement_detail_screen.dart` | (Same as G2.4, formally in P3.) Empty state is bare `Center(Text('Announcement not found'))` not `TrustechEmptyState`; event details hardcoded (`'14:00 - 16:30 GMT'`, `'Great Hall, Main Campus'`) not from the model; `Image.network` lacks `errorBuilder`. | ⬜ open |
| G3.5 | 🟡 | `profile_screen.dart` | Help Center / Terms / Privacy / Academic Advisor rows are empty `onTap: () {}`. Fine for UI-only, but prefer an `AppSnackbar.info('… coming soon')` stub so taps give feedback (matches Codex's pattern). Version string `'2.4.1'` hardcoded. | 🔁 verify |

## Phase 4 — Settings, Change Password — reviewed 2026-06-07
Overall: **clean compile, no blocking.** Settings correctly reads `themeProvider`/`localeProvider` and opens the Phase-5 theme/language sheets; Change Password reuses `TrustechTextField` / `TrustechButton` / `SuccessStateCard` with a live password-strength meter. One real token violation, plus dialog/no-op polish items.

| # | Sev | File | Issue | Status |
|---|-----|------|-------|--------|
| G4.1 | 🟡 | `profile/presentation/screens/change_password_screen.dart` | `_getStrengthColor` returns raw `Colors.orange` / `Colors.green` — violates golden rule #3 (colorScheme / `TrustechColors` only; no new hex/material colors). Use `cs.secondary` / `cs.tertiary` or `TrustechColors.success`/`warning`. | ⬜ open |
| G4.2 | 🔁 | `change_password_screen.dart` | Success uses `showDialog(child: SuccessStateCard(...))` (a card, not a dialog — verify sizing/rounding inside the barrier) followed by a 2s delayed **double** `Navigator.pop()`. Fragile: the two pops assume an exact stack depth and could pop the wrong route. Prefer a single explicit flow (e.g. `AppSnackbar.success` + one `context.pop()`, or a full success screen). Also: no new==confirm check before showing success. | 🔁 verify |
| G4.3 | 🟡 | `profile/presentation/screens/settings_screen.dart` | All `Switch.adaptive` toggles have hardcoded `value:` + `onChanged: (v) {}` no-ops — they don't even toggle visually. For UI-only fidelity make them local `setState` toggles (`ConsumerStatefulWidget`). "Log out from all sessions" `TextButton` is also an empty no-op. | ⬜ open |
| G4.4 | 🔵 | `settings_screen.dart` | Same one-off `_SectionTitle` as G3.2 (cross-cutting). | ⬜ open |

**Good:** theme + language sheets are wired to the real providers and actually switch theme/locale (P5 behavior met); Change Password strength meter logic is sound.

## Phase 5 — Theme & Language Selection Sheets — reviewed 2026-06-07
Overall: **clean compile, DoD met.** Both sheets use `SheetScaffold` and wire to the real `themeProvider` / `localeProvider` — they actually switch theme and locale (System/Light/Dark, English/Français), which was the explicit P5 requirement. Main issue is a convention miss: a hand-rolled option row instead of the ui-kit component named for this exact use.

| # | Sev | File | Issue | Status |
|---|-----|------|-------|--------|
| G5.1 | 🟡 | `profile/presentation/widgets/theme_selection_sheet.dart`, `language_selection_sheet.dart` | Both reimplement a custom `_OptionRow` instead of the ui-kit `SegmentedSelectorRow`, which the plan/golden rules explicitly named for these sheets. Swap to `SegmentedSelectorRow` (it already provides the leading icon, selected check, and styling). | ⬜ open |
| G5.2 | 🔵 | both sheet files | `_OptionRow` is duplicated **verbatim** across both files. Resolves itself once G5.1 adopts `SegmentedSelectorRow`; otherwise extract to one shared widget. | ⬜ open |

**Good:** real local behavior wired correctly (theme/locale persist via providers); `SheetScaffold` used per spec.

---

## How to use
- Claude appends a new `## Phase N — … — reviewed <date>` block under the relevant agent after each review.
- Agents read their section, fix ⬜/🔁 items (preferably in their next phase's review pass), and Claude flips them to ✅ on re-review.
- 🔴 items must be fixed before that screen is considered done.
