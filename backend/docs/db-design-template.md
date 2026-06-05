# Database Design Template
## Trustech School Information System (SIS)

**Document Type:** Database Design Specification
**Version:** `<v0.1>`
**Date:** `<YYYY-MM-DD>`
**Author(s):** `<Name(s)>`
**Related Docs:** `docs/arch.md`, `docs/srs.md`, `docs/srs-template.md`

---

## 1. Purpose and Scope

### 1.1 Purpose
Define the relational data model, constraints, performance strategy, and governance rules for the SIS database.

### 1.2 Scope
- In scope:
  - Core transactional schema for MOD-1 to MOD-8
  - Keys, constraints, indexes, and relationships
  - Auditing and lifecycle retention strategy
  - Migration and versioning approach
- Out of scope:
  - BI warehouse/star schema (if separate)
  - Legacy data migration mapping (unless specified)

---

## 2. Database Platform and Standards

### 2.1 Platform
- Engine: PostgreSQL `<version>`
- Access layer: SQLAlchemy async + `asyncpg` (application layer)
- Cache/session helper: Redis (non-system-of-record)

### 2.2 Standards
- Naming:
  - Tables: `snake_case`, plural preferred (e.g., `students`, `course_registrations`)
  - Columns: `snake_case`
  - PK: `id` (UUID)
  - FK: `<referenced_table_singular>_id`
- Time:
  - Use `timestamptz` for all timestamps
  - Store in UTC
- IDs:
  - UUID primary keys across domain tables
- Monetary values:
  - `numeric(18,2)` (or stricter if needed)
- Enumerations:
  - Use DB enums or constrained text (choose one policy and stay consistent)

---

## 3. Design Principles

1. Normalize to at least 3NF for transactional consistency.
2. Enforce integrity in DB first (FK, unique, check constraints).
3. Support soft-delete/archive where legal/audit retention requires it.
4. Keep write models optimized for correctness; use read-optimized views/materialized views for heavy reporting.
5. Make ownership boundaries explicit per module.

---

## 4. Module-to-Schema Mapping

| Module | Schema/Namespace | Ownership Notes |
|---|---|---|
| MOD-1 Authentication & Security | `<schema>` | `<notes>` |
| MOD-2 User Management | `<schema>` | `<notes>` |
| MOD-3 Academic Structure | `<schema>` | `<notes>` |
| MOD-4 Course Management | `<schema>` | `<notes>` |
| MOD-5 Student Lifecycle | `<schema>` | `<notes>` |
| MOD-6 Finance & Fees | `<schema>` | `<notes>` |
| MOD-7 Communication | `<schema>` | `<notes>` |
| MOD-8 Administration & Analytics | `<schema>` | `<notes>` |

Decision:
- Single schema (`public`) or multi-schema strategy (`auth`, `academics`, `finance`, etc.) — document final choice.

---

## 5. Global Conventions

### 5.1 Common Columns
For most domain tables:
- `id UUID PRIMARY KEY`
- `created_at timestamptz NOT NULL DEFAULT now()`
- `updated_at timestamptz NOT NULL DEFAULT now()`
- `created_by UUID NULL` (if auditing actor required)
- `updated_by UUID NULL` (if auditing actor required)
- `is_deleted boolean NOT NULL DEFAULT false` (if soft-delete policy used)
- `deleted_at timestamptz NULL` (if soft-delete policy used)

### 5.2 Referential Actions
- `ON DELETE RESTRICT` by default for master data.
- `ON DELETE CASCADE` only for dependent child records where safe and intended.

### 5.3 Uniqueness Rules
- Natural keys where needed (e.g., `matric_no`, `course_code`, `receipt_no`) must be unique.
- Use composite unique constraints for scoped uniqueness.

---

## 6. Logical Data Model

Provide both:
1. ERD (high-level)
2. Table dictionary (detailed)

### 6.1 Core Entity Groups
- Identity and Access
- User and Role domain
- Academic structure domain
- Course and registration domain
- Student lifecycle domain
- Finance domain
- Communication domain
- Administration/audit domain

### 6.2 Entity Relationship Summary
| Parent Entity | Child Entity | Cardinality | Notes |
|---|---|---|---|
| `<entity>` | `<entity>` | `1:N` / `M:N` | `<notes>` |

---

## 7. Table Dictionary Template

Repeat this section for each table.

## 7.X `<table_name>`

**Purpose:** `<what this table stores>`
**Module Owner:** `<MOD-X>`
**Estimated Growth:** `<rows/day or rows/semester>`

| Column | Type | Null | Default | Constraints | Description |
|---|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | PK | Primary key |
| `<column>` | `<type>` | `<Yes/No>` | `<default>` | `<FK/UQ/CHK>` | `<description>` |

Indexes:
- `idx_<table>_<col>`
- `<other index>`

Business Rules:
- `<rule>`
- `<rule>`

---

## 8. Many-to-Many and Join Table Design

Document join tables explicitly:
- Example: `user_roles`, `program_courses`, `student_course_registrations`

For each join table:
- Composite unique key
- Extra attributes (e.g., assignment period, status)
- Effective dating if historical tracking is required

---

## 9. State and Lifecycle Modeling

For lifecycle-heavy entities (`application`, `enrollment`, `grade_publication`, `invoice`, etc.):

| Entity | Allowed States | Transition Rules | Terminal States |
|---|---|---|---|
| `<entity>` | `<states>` | `<rules>` | `<states>` |

Implementation note:
- Use check constraints and/or controlled update procedures for critical state transitions.

---

## 10. Financial Data Design Rules (Critical)

1. Use `numeric`, never floating point for money.
2. Separate `charges`, `payments`, `adjustments`, `scholarship_credits`.
3. Keep immutable ledger-like records for posted transactions.
4. Reversals should create compensating entries, not destructive edits.
5. Maintain reconciliation keys and external reference IDs for gateway transactions.

---

## 11. Security and Data Protection

### 11.1 Data Classification
| Data Category | Examples | Protection Rule |
|---|---|---|
| PII | `<name, email, phone>` | `<masking/access control>` |
| Financial | `<payment details>` | `<strict audit + restricted roles>` |
| Academic | `<grades, standing>` | `<role and scope restrictions>` |

### 11.2 Access Controls
- Row-level scope constraints where needed (department/faculty scoping).
- Principle of least privilege in DB users/roles.

### 11.3 Sensitive Fields
- Hash credentials.
- Encrypt highly sensitive fields at rest if policy requires.

---

## 12. Auditing and Compliance

### 12.1 Audit Strategy
- Central `audit_logs` table for critical entity actions.
- Capture: actor, action, entity, entity_id, before/after snapshot, timestamp.

### 12.2 Retention
| Data Class | Retention Period | Archival Strategy |
|---|---|---|
| Audit Logs | `<period>` | `<cold storage strategy>` |
| Financial Records | `<period>` | `<policy>` |
| Communication Logs | `<period>` | `<policy>` |

---

## 13. Performance and Indexing Strategy

### 13.1 Query Patterns
Document expected hot queries:
- Student transcript read
- Course registration validation
- Timetable fetch
- Fee balance statement
- Dashboard aggregates

### 13.2 Index Plan
| Table | Query Pattern | Proposed Index |
|---|---|---|
| `<table>` | `<where/order/join>` | `<btree/composite/partial>` |

### 13.3 Partitioning and Archival
- Define if partitioning is required for:
  - `audit_logs`
  - `notifications`
  - `payments`
  - `attendance_records`

---

## 14. Concurrency and Transaction Rules

| Use Case | Isolation / Lock Strategy | Notes |
|---|---|---|
| Course registration | `<strategy>` | Prevent over-registration |
| Grade publishing | `<strategy>` | Prevent double publish/race |
| Payment posting | `<strategy>` | Preserve financial integrity |

Idempotency:
- Define idempotency keys for payment and external callback workflows.

---

## 15. Migration and Versioning Strategy

### 15.1 Migration Tooling
- Alembic migration workflow
- Naming standards for revisions

### 15.2 Deployment Policy
- Forward-only migration preferred
- Rollback strategy for failed deployments

### 15.3 Seed Data
- Required static data (roles, permission sets, grade boundaries, fee categories)

---

## 16. Backup, Recovery, and DR

| Requirement | Target |
|---|---|
| RPO | `<e.g., 15 min>` |
| RTO | `<e.g., 1 hour>` |
| Backup Frequency | `<schedule>` |
| Restore Testing | `<cadence>` |

---

## 17. Data Quality and Validation Rules

| Rule ID | Rule | Enforcement Layer |
|---|---|---|
| DQ-001 | `<rule>` | DB Constraint / App Validation / Both |
| DQ-002 | `<rule>` | DB Constraint / App Validation / Both |

---

## 18. Open Questions

1. `<question>`
2. `<question>`
3. `<question>`

---

## 19. Appendices

### Appendix A: ERD
- `<Link or embed>`

### Appendix B: DDL Snippets
```sql
-- Example template
create table if not exists <table_name> (
  id uuid primary key,
  created_at timestamptz not null default now()
);
```

### Appendix C: Change Log
| Version | Date | Author | Change |
|---|---|---|---|
| `<v0.1>` | `<date>` | `<name>` | Initial draft |
