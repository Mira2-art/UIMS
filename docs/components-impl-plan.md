# Components Implementation Plan (shared — build FIRST)

> Shared foundation every feature plan depends on. Build this before any screens.
> Target: `trustech_mobile/`. UI-only phase. Source: Stitch
> `student_shared_components_kit` + `student_project_cover_index` + recurring patterns
> across all screens. Reconcile to existing `TrustechColors`/theme (no new hex).

---

## 0. What already exists (reuse, don't recreate)
`src/shared/ui_kit/`: `TrustechButton` (primary/secondary/outline/text/destructive + loading), `TrustechTextField` (label, prefix, password toggle, error), `TrustechCard`, `TrustechScaffold`, `TrustechLoader` (+overlay), `TrustechEmptyState`, `AppSnackbar`, `TrustechAvatar`, `SectionHeader`. Theme: `material_theme.dart`, `cupertino_theme.dart`, `theme_provider.dart`. Tokens: `TrustechColors`. Helpers: `theme_helper.dart` (`context.cCard`, etc.).

The Components-Kit screenshot maps 1:1 to these — verify each renders to match, extend where noted.

---

## 1. Theme / token tasks
- Confirm `TrustechButton` variants match the kit (primary teal, secondary amber, outline, text link, destructive red, loading spinner). Adjust radius/padding to match.
- Confirm `TrustechTextField` matches (email w/ mail prefix; password w/ lock prefix + eye toggle).
- Ensure `flutter analyze` clean after any token edits. **No new hex** — map any design teal to `TrustechColors.primary`.

---

## 2. New shared components to build (`src/shared/ui_kit/…`)

| Component | File | Purpose / source | Notes |
|---|---|---|---|
| `StatusChip` | `display/status_chip.dart` | success/warning/error/info pill (kit "Status Chips") | tinted bg (10–15%) + accent text + dot/icon; enum `StatusKind` |
| `StatCard` | `display/stat_card.dart` | icon + label + big value (kit "Attendance 94.2%", "Next Class 10:30 AM") | compact, bordered |
| `InfoListRow` / `ListRowCard` | `layout/info_list_row.dart` | leading icon/avatar + title + subtitle + trailing (value/chip/chevron) (kit "Data Displays") | the workhorse list row used by courses/finance/grades/comms |
| `SkeletonLoader` | `feedback/skeleton_loader.dart` | shimmer placeholder (kit "UI Feedback States") | for list/detail loading |
| `ErrorStateCard` | `feedback/error_state_card.dart` | icon + message + retry (kit "Connection Failed") | callback `onRetry` |
| `SuccessStateCard` | `feedback/success_state_card.dart` | check + message + CTA (kit "Payment Complete / View Receipt") | |
| `ProgressRing` / `ProgressBar` | `display/progress_indicators.dart` | GPA / attendance-rate visual | color by threshold (green/amber/red) |
| `AppBottomNav` | `navigation/app_bottom_nav.dart` | 5-tab bar: Home·Courses·Grades·Finance·Profile | filled active icon + teal indicator |
| `AppHeaderBar` | `navigation/app_header_bar.dart` | custom app bar (`PreferredSizeWidget`); configurable leading: **back / menu(drawer) / avatar / custom / none**, title or wordmark, actions + built-in notification bell w/ badge | named ctors `AppHeaderBar.home/.back/.menu` |
| `AppDrawer` | `navigation/app_drawer.dart` | navigation drawer opened by the menu icon — gradient header (avatar/name), `AppDrawerItem` list, separated sign-out | items provided per app/role |
| `BrandGradientHeader` | `layout/brand_gradient_header.dart` | teal→#2D5A68 gradient hero (welcome) | |
| `SheetScaffold` | `layout/sheet_scaffold.dart` | rounded-top bottom sheet w/ grabber + title (theme/language sheets) | |
| `SegmentedSelectorRow` | `inputs/segmented_selector_row.dart` | single-select option row w/ check (theme/language sheet items) | |

> Keep each component theme-driven (light/dark via `colorScheme`), with `const` constructors where possible. Add a barrel export entry in `ui_kit.dart`.

---

## 3. App shell & navigation (`MainShell`)
- Build `src/features/shell/presentation/main_shell.dart`: `StatefulShellRoute.indexedStack` host rendering `AppBottomNav` + the 5 branch navigators (Home, Courses, Grades, Finance, Profile). Each tab keeps its own stack (state preserved).
- Update `src/router/app_router.dart`: auth routes outside the shell; the 5 tabs as branches; deep routes nested per `design/student-app-design-spec.md` §6.2. Add a simple `redirect` placeholder (UI phase: default to `/home`; real auth guard later — `// TODO(backend:)`).
- Notifications reached via the Home header bell (not a tab).

---

## 4. Mock-data convention (UI-only)
- Define plain Dart models per feature under `data/mock/` (e.g. `CourseMock`, `ChargeMock`) with realistic sample values (names, `CSC101`, GPA 3.85, `$1,250.00`, dates).
- Expose via Riverpod: `final myCoursesProvider = Provider((ref) => CourseMock.sample);` returning static lists. Screens consume providers (so the later backend swap only changes the provider body).
- Add `// TODO(backend): replace with <endpoint from review-work.md>` at each provider.
- Optional: a tiny `mockDelay()` helper to demo loading/skeleton states.

---

## 4b. Component API quick reference (USE THESE EXACT NAMES)

Read the widget source before use. Common mistakes to avoid are noted with ❌.

- **TrustechButton** — `TrustechButton(label: '…', onPressed: fn, variant: TrustechButtonVariant.primary|secondary|outline|text|destructive, icon: Icons.x, isLoading: false, expand: true)`. ❌ no `text:`, no `type:`, no `TrustechButtonType`.
- **TrustechTextField** — `TrustechTextField(controller:, label:, hintText:, prefixIcon:, obscureText:, keyboardType:, textInputAction:, onSubmitted:, errorText:, autofillHints:)`.
- **TrustechCard** — `TrustechCard(child:, padding:, onTap:, margin:)`.
- **SectionHeader** — `SectionHeader(title:, actionLabel:, onAction:)`. ❌ no `color:`.
- **StatusChip** — `StatusChip(label:, kind: StatusKind.success|warning|error|info|neutral)` or `StatusChip.custom(label:, accent:)`.
- **StatCard** — `StatCard(icon:, label:, value:, accent:, onTap:)`.
- **InfoListRow** — `InfoListRow(title:, subtitle:, icon:, iconAccent:, trailingText:, trailing:, showChevron:, onTap:)`; **InfoListCard(children: [...])**.
- **ProgressRing** — `ProgressRing(percent: 0..100, label:, color:)`; **ProgressBar(percent:)**.
- **AppHeaderBar** — `AppHeaderBar.home(title:, avatarName:, unreadCount:, onNotification:)` · `AppHeaderBar.back(title:, actions:)` · `AppHeaderBar.menu(title:)` · default `AppHeaderBar(title:, leading: AppHeaderLeading.none|back|menu|avatar|custom, actions:)`.
- **TrustechAvatar** — `TrustechAvatar(name:, imageUrl:, radius:)`.
- **TrustechEmptyState** — `TrustechEmptyState(title:, message:, icon:, actionLabel:, onAction:)`.
- **SheetScaffold** `(title:, child:)` · **SegmentedSelectorRow** `(label:, selected:, onTap:, leadingIcon:)` · **ErrorStateCard** `(message:, onRetry:)` · **SuccessStateCard** `(title:, subtitle:, ctaLabel:, onCta:)` · **SkeletonBox/SkeletonListTile** · **AppSnackbar.success/error/info/warning(context, msg)**.
- **Flutter gotcha:** it's `MainAxisAlignment.spaceBetween` ❌ not `MainAxisAlignment.between`.
- **Param-screen constructors are fixed by the router contract:** `CourseDetailScreen(courseId:)`, `CourseMaterialsScreen(courseId:)`, `CourseAttendanceScreen(courseId:)`, `ChargeDetailScreen(chargeId:)`, `AnnouncementDetailScreen(announcementId:)`. **Do not rename these params** — the router passes them by these names.

## 5. Acceptance
- [ ] Components kit screen reproduced by the real widgets (light + dark) — visually matches `student_shared_components_kit/screen.png`.
- [ ] `AppBottomNav` + `MainShell` route between 5 tabs with preserved state.
- [ ] All new components exported from `ui_kit.dart`, theme-driven, no hardcoded hex.
- [ ] `flutter analyze` = 0 issues.
