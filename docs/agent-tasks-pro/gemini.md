# Agent Task — GEMINI (Staff/Pro app · Academics · Finance · Administration)

You implement the **Academics, Finance, and Administration** screens of the Trustech
**Staff (Pro)** Flutter app (`trustech_mobile_pro`). Claude builds the
foundation/shell/router/role-gating + shared/auth/comms; Codex builds
Teaching/Students/People. **Work only in your feature folders.**

## ⛔ Start condition
Begin **only after Claude's Foundation (P0) is done** — `MainShell` (4 tabs), router,
`moduleAccess` role-gating, **stub screens**, and the UI kit (incl. deltas — note the
**chart wrapper** you need for Reports + Admin Dashboard) must exist. **Replace your
stub screens** at the same file path + class name. **Do not edit** `src/shared/ui_kit/`,
`src/router/`, `src/core/auth/`, or `MainShell` — need a route? ask the user.

## Read first
- `design/pro-app-design-spec.md` — tokens (§3), components (§4), nav (§6), screens (§7); chart palette `chart1–5` (§3.1).
- `docs/agent-tasks-pro/claude.md` — shared ui-kit + deltas (incl. `TrustechChart`).
- `docs/features-plan-5-impl-pro-plan.md` (Academics) · `features-plan-6-impl-pro-plan.md` (Finance) · `features-plan-7-impl-pro-plan.md` (Administration).
- Design source: `design/stitch-staff/<folder>/screen.png` + `code.html` (or the Downloads export).

## Golden rules
1. **UI ONLY — no backend.** Riverpod providers → static mock under `features/<f>/data/mock/`; `// TODO(backend:)`.
2. **Use the UI kit:** `import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';` — `AppHeaderBar`, `InfoListRow`/`InfoListCard`, `StatCard`, `StatusChip`, `TrustechButton`, `TrustechTextField`, `SheetScaffold`, `TrustechChart`, `SectionHeader`, states. No one-off widgets where a kit component exists.
3. **Colors/typography:** `TrustechColors`/`colorScheme` + `TrustechTypography`; charts use `chart1–5`. Light **and** dark.
4. **Match** each Stitch `screen.png` (use `code.html` where the PNG has text artifacts).
5. **Role annotation:** top `// Roles: …` per spec §2.
6. **Mobile "tables":** never horizontal-scroll — stacked label-value rows/cards (spec §4).
7. **Gate per screen:** `flutter analyze` 0 · routed · light+dark.
8. **Stay in your folders:** `features/academics/`, `features/finance/`, `features/admin/` only.
9. **Param-screen constructors (router contract):** `programId`, `catalogId`, `chargeId`, `paymentId`, `userId`, `auditId`.

---

## Phase 1 — Academics A (3)
| # | Screen | Stitch folder | Route | File · class |
|---|---|---|---|---|
|1| Faculties | `pro_academics_faculties_light` | `/academics/faculties` | `academics/presentation/screens/faculties_screen.dart` · `FacultiesScreen` |
|2| Departments | `pro_academics_departments_light` | `/academics/departments` | `departments_screen.dart` · `DepartmentsScreen` |
|3| Programs | `pro_academics_programs_light` | `/academics/programs` | `programs_screen.dart` · `ProgramsScreen` |
- List + create/edit sheet each; filter (dept/faculty) where noted.

## Phase 2 — Academics B (4)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|4| Program Curriculum | `pro_academics_program_curriculum_light` | `/academics/programs/:id/curriculum` | `program_curriculum_screen.dart` · `ProgramCurriculumScreen(programId)` |
|5| Semesters / Calendar | `pro_academics_semesters_light` | `/academics/semesters` | `semesters_screen.dart` · `SemestersScreen` |
|6| Course Catalog (list) | `pro_academics_course_catalog_light` | `/academics/catalog` | `course_catalog_screen.dart` · `CourseCatalogScreen` |
|7| Course Catalog Detail | `pro_academics_course_catalog_detail_light` (+`_dark`) | `/academics/catalog/:id` | `course_catalog_detail_screen.dart` · `CourseCatalogDetailScreen(catalogId)` |
- Semesters: **Activate** (confirm — deactivates others). Catalog Detail: assign-lecturer · prerequisites · syllabus · timetable as sections.

## Phase 3 — Finance A (3)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|8| Fee Structures | `pro_finance_fee_structures_light` | `/finance/fee-structures` | `finance/presentation/screens/fee_structures_screen.dart` · `FeeStructuresScreen` |
|9| Charges (list) | `pro_finance_charges_light` | `/finance/charges` | `charges_screen.dart` · `ChargesScreen` |
|10| Charge Detail | `pro_finance_charge_detail_light` | `/finance/charges/:id` | `charge_detail_screen.dart` · `ChargeDetailScreen(chargeId)` |
- Charge detail: amount/paid/discount/balance + status chip; **Apply discount** sheet.

## Phase 4 — Finance B (4)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|11| Bill Student (form) | `pro_finance_bill_student_light` | `/finance/charges/new` | `bill_student_screen.dart` · `BillStudentScreen` |
|12| Payments (list) | `pro_finance_payments_light` | `/finance/payments` | `payments_screen.dart` · `PaymentsScreen` |
|13| Payment Detail | `pro_finance_payment_detail_light` | `/finance/payments/:id` | `payment_detail_screen.dart` · `PaymentDetailScreen(paymentId)` |
|14| Record Payment (form) | `pro_finance_record_payment_light` | `/finance/payments/new` | `record_payment_screen.dart` · `RecordPaymentScreen` |
- Payment detail: **Reverse** (reason + confirm).

## Phase 5 — Finance C (3)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|15| Scholarships | `pro_finance_scholarships_light` | `/finance/scholarships` | `scholarships_screen.dart` · `ScholarshipsScreen` |
|16| Award Scholarship (form) | `pro_finance_award_scholarship_light` | `/finance/scholarships/new` | `award_scholarship_screen.dart` · `AwardScholarshipScreen` |
|17| Reports (charts) ★ | `pro_finance_reports_dark` | `/finance/reports` | `finance_reports_screen.dart` · `FinanceReportsScreen` |
- Reports = Outstanding balances + Collection summary using `TrustechChart`.

## Phase 6 — Administration A (4)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|18| Admin Dashboard (charts) ★ | `pro_admin_dashboard_dark` | `/admin/dashboard` | `admin/presentation/screens/admin_dashboard_screen.dart` · `AdminDashboardScreen` |
|19| Users (list) | `pro_admin_users_list_light` | `/admin/users` | `users_screen.dart` · `UsersScreen` |
|20| User Detail | `pro_admin_user_detail_light` | `/admin/users/:id` | `user_detail_screen.dart` · `UserDetailScreen(userId)` |
|21| Roles & Permissions | `pro_admin_roles_permissions_light` | `/admin/roles` | `roles_permissions_screen.dart` · `RolesPermissionsScreen` |
- User Detail: change-status (activate/suspend/deactivate); **no delete**. Roles: assign role→user, permission→role (read-only permission list).

## Phase 7 — Administration B (4)
| # | Screen | Stitch | Route | File · class |
|---|---|---|---|---|
|22| Audit Logs (list) | `pro_admin_audit_logs_light` | `/admin/audit-logs` | `audit_logs_screen.dart` · `AuditLogsScreen` |
|23| Audit Log Detail | `pro_admin_audit_log_detail_light` | `/admin/audit-logs/:id` | `audit_log_detail_screen.dart` · `AuditLogDetailScreen(auditId)` |
|24| System Configs (read-only) | `pro_admin_system_configs_light` | `/admin/configs` | `system_configs_screen.dart` · `SystemConfigsScreen` |
|25| Email Logs | `pro_admin_email_logs_light` | `/admin/email-logs` | `email_logs_screen.dart` · `EmailLogsScreen` |
- Configs are **read-only** (editing = super-admin, excluded).

### Per-phase DoD
All phase screens (light+dark), reuse ui_kit, mock providers only, `flutter analyze` 0, routed. Flag blockers to the user. Hand off to Claude for review (`docs/agent-tasks-pro/gemini-review-log-pro.md`).
