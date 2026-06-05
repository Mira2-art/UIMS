# Trustech School Information System (SIS)
## Consolidated Database Design (Normalized v1)

**Version:** 1.0 (Consolidated Draft)
**Database:** PostgreSQL 15.x / 16.x
**Normal Form Target:** 3NF with selective denormalization for read performance
**Primary Key Strategy:** UUID v4 (`gen_random_uuid()`)
**Related Docs:** `docs/arch.md`, `docs/srs.md`, `docs/db-design-template.md`

---

## 1. Executive Summary

This document is the consolidated database design baseline for Trustech SIS.
It merges your detailed schema draft with architectural normalization and implementation-readiness corrections.

### 1.1 Finalized Scope
- Covers all 8 modules (MOD-1 to MOD-8)
- Transactional OLTP schema in PostgreSQL
- Referential integrity, indexing, triggers, and migration strategy
- Auditability and operational safety for academic and finance workflows

### 1.2 Corrected Inventory (from draft normalization)
- **Total tables:** 36 (not 28)
- **Estimated columns:** 300+ (to be finalized after first migration set)
- **Foreign keys:** 80+ expected
- **Indexes:** 40+ expected

Reason for count correction:
- The supplied draft DDL enumerates 36 tables across modules.

---

## 2. Design Decisions Locked

1. Use PostgreSQL with UUID primary keys for all domain tables.
2. Use `timestamptz` (UTC) for all date-time audit fields.
3. Keep schema in **single namespace (`public`)** for v1 simplicity.
4. Enforce integrity in DB (FK/UQ/CHECK), not only in application code.
5. Use selective denormalization for expensive aggregates (e.g., academic standing summary).
6. Keep finance records immutable after posting; reversals are compensating entries.

---

## 3. Cross-Cutting Standards

## 3.1 Naming
- Tables: `snake_case`, plural nouns
- Columns: `snake_case`
- Primary key: `id` (preferred canonical)
- Foreign key: `<entity>_id`

Note:
- Your current draft uses table-specific PK names (`user_id`, `student_id`, ...).
  This is acceptable, but for consistency with FastAPI/SQLAlchemy patterns, prefer canonical `id` in new migrations.

## 3.2 Common Columns
Most mutable domain tables should include:
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Optional (where needed):
- `created_by uuid null`
- `updated_by uuid null`
- soft-delete fields (`is_deleted`, `deleted_at`) for archival workflows

## 3.3 Monetary Types
- Use `numeric(18,2)` for money columns (avoid float/double precision).

---

## 4. Module-to-Table Mapping

## MOD-1 Authentication & Security (6)
1. `users`
2. `roles`
3. `user_roles`
4. `permissions`
5. `role_permissions`
6. `password_reset_tokens`

## MOD-2 User Management (5)
1. `students`
2. `lecturers`
3. `applicants`
4. `applicant_documents`
5. `user_sessions`

## MOD-3 Academic Structure (5)
1. `faculties`
2. `departments`
3. `programs`
4. `semesters`
5. `curriculum_courses`

## MOD-4 Course Management (4)
1. `courses`
2. `prerequisites`
3. `course_materials`
4. `enrollments`

## MOD-5 Student Lifecycle (6)
1. `attendance_sessions`
2. `attendance_records`
3. `timetable_entries`
4. `grade_assessments`
5. `grades`
6. `academic_standings`

## MOD-6 Finance & Fees (5)
1. `fee_structures`
2. `fee_charges`
3. `payments`
4. `scholarships`
5. `scholarship_awards`

## MOD-7 Communication (3)
1. `announcements`
2. `notifications`
3. `email_logs`

## MOD-8 Administration & Analytics (2)
1. `audit_logs`
2. `system_configs`

---

## 5. Key Integrity Rules

## 5.1 Referential Actions
- `ON DELETE CASCADE`: only for true dependent/junction records
  - e.g., `user_roles`, `role_permissions`, `applicant_documents`
- `ON DELETE SET NULL`: optional relationship references
  - e.g., `courses.lecturer_id`, `departments.hod_id`, `faculties.dean_id`
- `ON DELETE RESTRICT`: critical domain entities
  - e.g., `enrollments -> students/courses`, `payments -> fee_charges`

## 5.2 Uniqueness
- `users.email` unique
- `students.matric_no` unique
- `lecturers.staff_id` unique
- `programs.code` unique
- scoped uniqueness for enrollments and curriculum mappings

## 5.3 Business Checks (examples)
- `credit_units > 0`
- `end_time > start_time`
- `amount > 0`
- GPA range checks (`0.00..5.00`)

---

## 6. Critical Corrections Applied to Draft

## 6.1 Table Count Correction
- Draft headline: 28 tables
- Actual enumerated tables: 36

## 6.2 FK Creation Order / Cycles
Your DDL contains forward/cyclic dependencies:
- `students.program_id -> programs` before `programs` exists
- `curriculum_courses.course_id -> courses` before `courses` exists
- `lecturers.department_id -> departments` and `departments.hod_id -> lecturers` (cycle)
- `faculties.dean_id -> lecturers` (cross-cycle)

Resolution:
- Create base tables first without cyclic optional FKs.
- Add cyclic optional FKs in a second phase via `ALTER TABLE ... ADD CONSTRAINT`.

## 6.3 Trigger Bugs
Draft trigger issues corrected conceptually:
1. `recalculate_academic_standing` used non-existent column names in insert/update (`total_credits` vs `total_credits_attempted/earned`).
2. Generic audit trigger used `NEW.user_id` as entity id for all tables (incorrect).
3. Grade check constraint referenced another table (`max_score`) indirectly; use trigger/application validation instead.

## 6.4 Partial Index Predicate Issue
The draft used time-dependent predicate examples like `expires_at > CURRENT_TIMESTAMP` in index definitions.
Use immutable predicates only in partial indexes; move dynamic time filtering to query predicates.

---

## 7. Recommended Enum and Status Strategy

Keep enums for strongly bounded domains:
- `user_status`
- `enrollment_status`
- `attendance_status`
- `payment_method`
- `fee_status`
- `priority_level`
- `notification_type`
- `academic_standing_type`

For fast-changing admin-configurable values, prefer constrained text + reference table instead of enum.

---

## 8. Indexing Strategy (High-Value Set)

## 8.1 Authentication and Identity
- `users(email)` unique btree
- `user_roles(user_id)`, `user_roles(role_id)`
- `password_reset_tokens(user_id)`, `password_reset_tokens(expires_at)` (with safe static predicate)

## 8.2 Academic Operations
- `students(matric_no)` unique
- `students(program_id)`
- `courses(program_id, semester_id)`
- `enrollments(student_id)`, `enrollments(course_id)`, `enrollments(status)`
- `attendance_records(session_id, student_id)` unique
- `grades(enrollment_id, assessment_id)` unique

## 8.3 Finance
- `fee_charges(student_id, semester_id)`
- `payments(student_id, payment_date)`
- `payments(receipt_number)` unique

## 8.4 Communication and Audit
- `notifications(user_id, is_read)`
- `announcements(target_type, target_id)`
- `audit_logs(entity_type, entity_id, created_at desc)`

---

## 9. Trigger and Procedure Policy

## 9.1 `updated_at` Trigger
Use one shared trigger function to set `updated_at` on row update.

## 9.2 Academic Standing Recalculation
Recompute standing on grade publish/unpublish events:
- Trigger entry: `grades` changes that affect published outcomes
- Logic source: weighted assessments + configured thresholds
- Write target: `academic_standings`

## 9.3 Audit Logging
Track create/update/delete for critical tables:
- actor
- action
- entity
- entity_id
- before/after JSON snapshot
- timestamp

Implementation note:
- Capture actor via session variable (`app.current_user_id`) set by API layer per request.

---

## 10. Finance Integrity Rules

1. Monetary columns use `numeric`.
2. Do not mutate posted payment rows; create reversal rows.
3. Maintain reconciliation references (`transaction_ref`, provider ids).
4. Keep charge/payments relationship explicit.
5. Validate overpayment boundaries with constraints and transaction logic.

---

## 11. Security and Compliance

1. Store password hashes only (bcrypt/argon policy defined at app layer).
2. Apply least-privilege DB roles.
3. Restrict direct updates on grade and payment tables to service accounts.
4. Audit all high-risk actions: role changes, grade changes, payment actions, config changes.
5. Define retention and archival windows for audit and communication logs.

---

## 12. Partitioning and Archival

Recommended partition candidates:
- `audit_logs` (monthly by `created_at`)
- `notifications` (monthly by `created_at`)
- `email_logs` (monthly by `created_at`/`sent_at`)
- `attendance_records` (term/year partition strategy where data volume requires)

Do not partition prematurely for low-volume tables.

---

## 13. Migration and Rollout Strategy

1. Build schema in migration sets:
  - base tables
  - foreign keys
  - indexes
  - triggers/functions
2. Apply seed data:
  - roles
  - core permissions
  - essential `system_configs`
3. Validate:
  - FK checks
  - unique constraints
  - query plans for hot endpoints
4. Use forward-only migrations in production.

---

## 14. Open Decisions to Finalize Before Implementation

1. Canonical PK naming (`id` for all tables) vs existing `<table>_id` convention.
2. Enum vs lookup-table policy for admin-configurable states.
3. Full soft-delete policy by module (which tables require it).
4. Final finance ledger model:
  - current `fee_charges + payments` vs explicit double-entry extension.
5. Final retention periods for:
  - audit logs
  - communication logs
  - financial records

---

## 15. Implementation Next Step

After approval of this `db-design.md`:
1. Generate `alembic` migration sequence from this design.
2. Produce `srs-mod-1.md`.
3. Implement MOD-1 end-to-end (auth + RBAC + session + audit baseline).
