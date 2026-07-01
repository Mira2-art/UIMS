# Fix Plan — Light-mode card & modal-sheet contrast (trustech_mobile)

**Symptom:** In **light mode**, cards barely separate from the page, and modal bottom
sheets don't read as a distinct layer. Dark mode is fine. Reported after toggling
theme via Settings → Theme.

**Scope:** Theme + ui-kit only. No screen logic changes. Once verified here, mirror
the same changes into `trustech_mobile_pro` (it copied the same theme/ui-kit).

---

## Root causes (verified in code)

1. **Card vs page are nearly identical in light mode.**
   `background = #FAFAFA`, `card = #FFFFFF` — a ~1–2% luminance step — with a very
   faint `border = #EBEBEB`. Cards visually dissolve into the page.
   Dark mode works because `#343434` card on `#252525` page + `#474747` border is a
   clear step. (`app_colors.dart`, `theme_helper.dart`.)

2. **ColorScheme is only partially specified.**
   `ColorScheme.light(...)` / `.dark(...)` set ~8 roles; the **M3 surface-container
   roles** (`surfaceContainerLowest/Low/Container/High/Highest`, `surfaceBright`,
   `surfaceDim`) are left at Material defaults (lavender-tinted greys). Widgets that
   read them render off-brand and with inconsistent light/dark contrast — e.g.
   `notifications_screen` filter chips and unread dot, `Switch.adaptive` tracks,
   `SegmentedSelectorRow`, skeleton placeholders. (`material_theme.dart`.)

3. **Elevation tint not globally neutralized.**
   `surfaceTint` is killed on the app bar and bottom sheet only, not in the
   `ColorScheme`. Any elevated `Card`/`Dialog`/`Menu` can pick up the teal M3 tint.

4. **`SheetScaffold` paints no surface of its own.** It's `SafeArea → Padding →
   Column` with no background. It relies entirely on the sheet route's background:
   - `theme_selection_sheet` / `language_selection_sheet` are launched with
     `showModalBottomSheet(backgroundColor: Colors.transparent, …)` → the sheet is
     effectively **transparent** (you see the dimmed page through it). Worst in light
     mode. (`settings_screen.dart:189,198`.)
   - Even where `bottomSheetTheme.backgroundColor = card` applies (course detail /
     registration), the white sheet on a weak scrim has **no top edge cue**, so it
     blends with a light page.

5. **Inconsistent scrim.** Each `showModalBottomSheet` call site sets its own (or no)
   barrier; spec §4 wants a 40–60% black scrim so the sheet reads as a layer.

---

## The fix (ordered: low-risk → structural)

### Fix A — Give light mode a real surface ladder (tokens)
Make white cards pop by deepening the **page** background and strengthening the
**border**, keeping the flat 1px-bordered look (no heavy shadows).

In `app_colors.dart` (light tokens):
- `background`: `#FAFAFA` → **`#F1F3F5`** (cooler, clearly below white).
- `border`: `#EBEBEB` → **`#E2E6EA`** (slightly stronger hairline).
- Keep `card = #FFFFFF`, `muted = #F7F7F7`.
- Add an explicit light surface ladder constant set for Fix B:
  `surfaceContainerLowest #FFFFFF · Low #F7F8FA · Container #F1F3F5 · High #ECEEF1 · Highest #E6E9EC`.

Dark tokens already step well; add the matching dark ladder:
`Lowest #1F1F1F · Low #2B2B2B · Container #343434 · High #3D3D3D · Highest #454545`.

> Net effect: a visible card↔page step in light mode that mirrors dark mode.

### Fix B — Fully specify the ColorScheme (both modes)
In `material_theme.dart`, replace the partial `ColorScheme.light/.dark(...)` with a
complete scheme (or `.copyWith(...)` adding the missing roles) that maps every
surface role to the brand ladder from Fix A, and set:
- `surface` = card, `onSurface` = foreground, `onSurfaceVariant` = mutedForeground,
- `surfaceContainerLowest/Low/Container/High/Highest`, `surfaceBright`, `surfaceDim`
  = the ladder,
- `surfaceTint: Colors.transparent` (kill global elevation tint),
- `outlineVariant` = border.

This fixes the notifications filter chips, switches, segmented rows and skeletons in
one place, in both modes.

### Fix C — Make `SheetScaffold` self-contained
In `sheet_scaffold.dart`, wrap the content so the sheet **always** has its own
surface, independent of how it's launched:
- `Container(decoration: color = cCard, borderRadius top 16, border: top+side
  hairline `cBorder`)` (or a 1px top divider) — defines the sheet edge against a
  light page.
- Keep the drag handle. Optionally a soft top shadow (light mode only) for lift.

### Fix D — One `showAppSheet()` helper (ui-kit)
Add `showAppSheet(context, builder)` that standardizes every modal sheet:
`isScrollControlled: true`, `useSafeArea: true`,
`backgroundColor: Colors.transparent` (the sheet paints its own surface via
SheetScaffold now), `barrierColor: Colors.black54` (~45%, per spec).
Replace the 3 call sites (`course_detail`, `course_registration`, `settings` ×2) and
**remove** their ad-hoc `backgroundColor: Colors.transparent`.

### Fix E — Native Card/Dialog parity (defensive)
Add `cardTheme` (`color: card`, `surfaceTintColor: transparent`, `elevation: 0`,
`RoundedRectangleBorder(12)` + 1px `border` side) and `dialogTheme`
(`backgroundColor: card`, `surfaceTintColor: transparent`) so any native
`Card`/`Dialog`/`AlertDialog` matches the flat brand surface in both modes.

---

## Verification
1. `flutter analyze lib` → 0 issues; `flutter test` passes.
2. Settings → Theme → toggle **System / Light / Dark**:
   - Home/Courses/Finance: cards visibly separate from the page in **light** (parity
     with dark).
   - Notifications: filter chips, unread dot, skeletons read correctly in both modes.
3. Open the **Course Detail → Drop** sheet and **Theme/Language** sheets: opaque
   surface, rounded top, visible edge, consistent dim — both modes.
4. Spot-check `color-contrast` (≥4.5:1 body) on muted text over the new surfaces.

## Risk & rollout
- Token + theme + one ui-kit widget + 3 call sites. No feature/screen rewrites.
- `TrustechColors` hex changes are small and stay within the brand family; if the
  design spec must keep `#FAFAFA` exactly, use the surface-ladder/border route (Fix
  B + stronger border) instead of changing `background`.
- After sign-off, port the identical changes to `trustech_mobile_pro` — its light
  mode will have the same defect, and the staff Stitch screens are mostly authored in
  light with dark generated from tokens, so correct light surfaces matter there too.
