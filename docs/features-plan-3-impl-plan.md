# Features Plan 3 — Communication (part 2) · Profile & Settings — screens 21–27

> UI-only. Prereqs: `student-app-impl-overview.md` + `components-impl-plan.md`.
> Per-screen gate: matches screenshot (light+dark) · routed · `flutter analyze` 0 · no API.
> Design source base: `design/stitch-student/<folder>`.

---

## Feature: `communication` (part 2)

### 21. Announcement Detail
- **Source:** `student_communication_announcement_detail_light`
- **Route:** `/announcements/:id` · **File:** `features/communication/presentation/screens/announcement_detail_screen.dart`
- **Layout:** back app bar, hero image/category tag, title, meta (author/date, priority chip), full body content, optional attachment row.
- **Components:** `StatusChip`, `TrustechCard`. **Mock:** `announcementDetailProvider(:id)`.

### 22. Notifications
- **Source:** `student_communication_notifications_light` + `student_communication_notifications_dark`
- **Route:** `/notifications` · **File:** `.../screens/notifications_screen.dart`
- **Layout:** app bar (title + "Mark all read"), grouped list (Today/Earlier) of `InfoListRow` (type icon, title, message, time, unread dot); tap → deep-link to related screen.
- **States:** list · **empty** ("You're all caught up") · loading. **Mock:** `notificationsProvider`. **Nav:** item → related route (`/courses/:id`, `/finance/charges/:id`, `/announcements/:id`).
- **Note:** OS push mockups (`notification_banner_light`, `lock_screen_notification`) are **out of scope** here (push phase later).

---

## Feature: `profile` (tab 5)

### 23. Profile Main
- **Source:** `student_profile_main_light_{choice #8}`
- **Route:** `/profile` · **File:** `features/profile/presentation/screens/profile_screen.dart`
- **Layout:** header (avatar/initials, name, matric no, program · level), info card (email, phone), **menu list** (`InfoListRow` w/ chevron): Settings, Change Password, Notifications, Help, About; **Sign out** (destructive, separated at bottom).
- **Components:** `TrustechAvatar`, `InfoListRow`, `TrustechButton` (destructive). **Mock:** `profileProvider`. **Nav:** → `/settings`, `/change-password`, `/notifications`; Sign out → `/welcome` (`// TODO(backend:)`).

### 24. Settings
- **Source:** `student_profile_settings_light_{choice #9}`
- **Route:** `/settings` · **File:** `.../screens/settings_screen.dart`
- **Layout:** grouped rows: **Appearance** (Theme → opens Theme sheet, shows current), **Language** (→ Language sheet, shows current), **Notifications** toggles, **About / version**, **Sign out** (destructive).
- **Components:** `InfoListRow`, switches, `SheetScaffold`. **Wire:** Theme row → `themeProvider`; Language row → `localeProvider`. **Nav:** opens sheets (#26, #27).

### 25. Change Password
- **Source:** `student_profile_change_password_light`
- **Route:** `/change-password` · **File:** `.../screens/change_password_screen.dart`
- **Layout:** current / new / confirm fields (eye toggles), strength hint, **Update password** button → success snackbar.
- **Components:** `TrustechTextField` ×3, `TrustechButton`, `AppSnackbar`.

### 26. Theme Selection (bottom sheet)
- **Source:** `student_profile_theme_selection_sheet`
- **Trigger:** from Settings (not a route) · **File:** `features/profile/presentation/widgets/theme_selection_sheet.dart`
- **Layout:** `SheetScaffold` (grabber + "Appearance"), `SegmentedSelectorRow` options: System / Light / Dark with check on current.
- **Wire:** reads/sets `themeProvider` live (real behavior — this is local state, not backend). Closes on select.

### 27. Language Selection (bottom sheet)
- **Source:** `student_profile_language_selection_sheet`
- **Trigger:** from Settings · **File:** `.../widgets/language_selection_sheet.dart`
- **Layout:** `SheetScaffold` ("Language"), `SegmentedSelectorRow`: English / Français with check on current.
- **Wire:** reads/sets `localeProvider` live (l10n already scaffolded). Closes on select.

---

### Routing additions (this plan)
`/announcements/:id`, `/notifications`, Profile branch (`/profile`, `/settings`, `/change-password`). Theme/Language are modal bottom sheets launched from Settings (no route). Confirm full route tree matches `design/student-app-design-spec.md` §6.2.

---

## End-state checklist (after Plans 1–3)
- [ ] 27 screens implemented (chosen variants), light + dark.
- [ ] 5-tab `MainShell` + all deep routes reachable; back/state preserved.
- [ ] Theme + Language sheets actually switch theme/locale (local, real).
- [ ] All data from mock providers; every seam marked `// TODO(backend:)`.
- [ ] `flutter analyze` = 0; boots to Home; matches Stitch screenshots.
