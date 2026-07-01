# Agent Review Log — Staff (Pro) App · GEMINI

Claude's design-fidelity review of Gemini's screens (Academics · Finance · Administration).

**Severity:** 🔴 blocking (won't compile / breaks contract) · 🟡 minor (fidelity/convention) · 🔵 cross-cutting.
**Status:** ✅ fixed · ⬜ open · 🔁 verify.

---

# GEMINI  (Academics · Finance · Administration)

## All phases (1–7) — design-fidelity review — 2026-06-08
**Overall: clean compile, good structure, medium detail fidelity.** All **25** screens
implemented (no stubs), `flutter analyze` (academics + finance + admin) = **0 issues**,
provider-driven where it counts, light+dark via theme, `// Roles:` annotations present,
and the **`TrustechChart` delta is correctly used** on both ★ chart screens. List screens
and forms are faithful; the **dense dashboard/detail screens are noticeably simplified**,
and Gemini leans on **inline-hardcoded data** the same way it did in the student app.

> Coverage: pixel-compared 8/25 across all three modules (Faculties, Program Curriculum,
> Course Catalog Detail, Finance Reports ★, Bill Student, Admin Dashboard ★, Users,
> Roles & Permissions); the remaining list/detail/form screens follow the same patterns.

### Recurring deviations (the pattern)
| # | Sev | Where | Issue | Status |
|---|-----|-------|-------|--------|
| PG.1 | 🟡 | faculties_screen, users_screen | Search uses a **raw `TextField`** instead of ui-kit `TrustechTextField` (golden rule #2). Bill Student correctly uses `TrustechTextField` — make it consistent. | ✅ fixed |
| PG.2 | 🟡 | program_curriculum, course_catalog_detail, finance_reports, admin_dashboard | **Heavy inline-hardcoded content** instead of provider/mock: curriculum header (`'Computer Science B.Sc'` with a `// TODO: get from provider`, `'DEPARTMENT OF SCIENCES'`, `'Total Units: 120'`); catalog-detail's entire syllabus, learning outcomes, timetable, lecturer block, prerequisites; both charts' data + the dashboard KPI numbers. Same habit as the student-app scholarships screen. | ⬜ open |
| PG.3 | 🟡 | finance_reports_screen | **Dense screen heavily simplified.** Missing vs design: the **4 KPI cards** (Total Collections / Outstanding / Recovery Rate / Fee Structures), the **"Export Full Report"** button, the bar chart **legend (Actual vs Projected)** + second series, the donut **category breakdown (60/25/15) + "TOP SOURCE" center**, and the **"Recent Activity" ledger table**. Only two generically-titled charts were built. | ⬜ open |
| PG.4 | 🟡 | admin_dashboard_screen | Simplified: missing the **quick-action cards** (Invite User / Audit Logs), the **Network Topology** panel, and the donut **legend (Low/Med/High)**; donut is relabeled "User Distribution" vs the design's **Security Alerts** severity donut; KPI values differ (415/350 vs 12.4k/842). | ⬜ open |
| PG.5 | 🟡 | bill_student_screen | Form fields match, but missing the **Invoice Preview** card, the **Cancel** button, the **"Active Charges History"** list, and the **"Billing Guidelines"** panel. | ⬜ open |
| PG.6 | 🟡 | roles_permissions_screen | Diverges from the design's **role directory** (icon tile + "N Users" + severity chip CRITICAL/HIGH-LEVEL + category chip + "ACTIVE ROLES / 8 Total" header + "Role Management" banner + "Create New System Role" button). Gemini renders role → permission chips (matches the spec's read-only intent, but low visual fidelity). | ⬜ open |
| PG.7 | 🟡 | admin_dashboard_screen | Raw `Colors.green` on a `StatCard` accent — token violation (use `colorScheme`/`TrustechColors`). Same family as the student-app `Colors.orange/green`. | ✅ fixed |
| PG.8 | 🟡 | users_screen | Filter chips filter by **status** (All/Active/Locked) vs the design's **by-role** (All Roles/Admin/Registrar/Lecturer). App bar reads "Admin Portal" + a duplicate body H1, where the design puts "User Management" in the app bar. Card omits the staff **ID** subtitle. | 🔁 verify |
| PG.9 | 🔵 | course_catalog_detail_screen | `TrustechAvatar(imageUrl: <hardcoded Google URL>)` (NetworkImage) — offline-fragile, no fallback. Prefer initials/asset for mock. | ✅ fixed |

### Standouts (high fidelity — leave as-is)
- **Faculties** — header, search, faculty cards (code/name/status/dean), bottom Add bar: faithful. ✅
- **Course Catalog Detail** — rich, well-structured (hero, syllabus + outcomes, timetable stacked **without horizontal scroll** per the mobile-table rule, lecturer, prerequisites + warning). ✅
- **Bill Student** — correct ui-kit form fields (`TrustechTextField`/`TrustechButton`). ✅
- **Charts** — both ★ screens use `TrustechBarChart` / `TrustechDonut` (the delta) correctly. ✅

### Verdict
Ship-quality, on-brand, compiles clean, and the hard parts (charts, mobile tables, forms)
are right. But it's **not pixel-faithful**: Gemini simplifies the dense screens (PG.3–PG.6)
and hardcodes content inline instead of via providers (PG.2). Send PG.1–PG.7 back for
parity; PG.8/PG.9 are verify/polish.

## Parity pass (Claude implemented) — 2026-06-08
Restored the dropped design sections where Stitch was judged better. All academics/finance/admin screens `flutter analyze` 0.
- ✅ PG.3 Finance Reports → added **4 KPI cards + Export + Collection-Category legend (60/25/15) + Recent-Activity ledger** (stacked rows, no horizontal scroll). Bar chart's Actual-vs-Projected 2nd series is still single-series.
- ✅ PG.4 Admin Dashboard → added **Quick Actions (Invite User / Audit Logs) + donut legend**. Network-topology panel **intentionally dropped** (decorative on mobile).
- ✅ PG.5 Bill Student → added **Invoice Preview + Cancel**. History/Guidelines panels omitted (form length).
- ✅ PG.6 Roles → added **Create New System Role**; kept the role→permission-list model (matches the read-only spec). User-count / severity chips not added.
- ✅ PG.1 `TrustechTextField`, ✅ PG.7 token color, ✅ PG.9 avatar fallback (earlier pass).
- ◑ PG.2 — **partially fixed**: program-curriculum header (department / title / total-units) and catalog-detail description now read from providers (the `// TODO: get from provider` is gone). Catalog syllabus / timetable / prereqs / lecturer-bio are still static (not in the `CatalogCourse` mock model yet). PG.8 (users filter dimension) — not done.
- ↔︎ **Gemini additions vs Stitch** (same judgment as Codex's added stat rows): the only additions Gemini made are benign — Faculties' "Total Records" count and Users' body H1 — **kept**. Unlike Codex, Gemini didn't *replace* design panels, so there's nothing to revert here.
- 🧭 **Routing:** fixed a dead link — `/home/timetable` (used by profile "Schedule" + the timetable notification CTA) had **no route in the staff app**; repointed to `/courses`. Full `flutter analyze lib` = 0; all nav targets now resolve.

## Pass 2 — 2026-06-09
- ✅ PG.2 **completed**: extended `CatalogCourse` with `syllabus / outcomes / timetable / prerequisites / lecturerTitle / lecturerBio / lecturerEmail`, populated the mock, and **data-drove** Course Catalog Detail (syllabus, outcomes, timetable, lecturer block, prerequisites all from the provider now — no inline content).
- ✅ PG.3 finalized: Finance Reports bar chart is now **two-series (Actual vs Projected) with a legend** (`TrustechBarChart` gained an optional `comparison` series — backward-compatible; Admin Dashboard unaffected).
- ✅ PG.8 **done**: Users list now filters **by role** (chips from distinct roles, "All Roles") instead of status; app bar title is **"User Management"** (dropped the duplicate body H1).
- ✅ PG.6 **completed**: `Role` gained `userCount` + `category`; roles list enriched (System/Academic/Management) and each card shows a **category chip + "N users"** alongside the permission chips + the Create button.

## Pass 3 — structural nav (foundation) — 2026-06-09
- ✅ **Bottom nav** no longer shows on Gemini's pushed screens — all academics/finance/admin routes are now root-navigator routes (full-screen, no bottom bar).
- ✅ **Hamburger→back** on Gemini's module landings (faculties, departments, programs, semesters, course_catalog, charges, fee_structures, payments, scholarships, finance_reports, admin_dashboard, users).
- `flutter analyze lib` 0 · smoke test boots.
