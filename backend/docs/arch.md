# Trustech School Information System (SIS)
## Architecture Blueprint (Normalized v1)

## Executive Summary

This document defines the normalized module architecture for the Trustech School Information System (SIS), a multi-role academic management platform.

The architecture is organized into **8 consolidated modules** with **44 sub-modules** and **168 high-level features**. It is designed around:
- High cohesion within modules
- Loose coupling between modules
- Clear ownership boundaries
- Role-based access control across all module APIs

This version is aligned to the current backend implementation direction:
- **FastAPI (async)** for application services
- **PostgreSQL** for primary data storage
- **Redis** for cache/session/queue-support use cases

---

## System Overview

The system supports the full institutional workflow:
- Applicant intake and admission
- Student academic lifecycle
- Course and timetable operations
- Attendance and grading
- Fee billing and payment operations
- Announcements and messaging
- System governance, audits, and analytics

The platform supports **6 role types**:
1. Student
2. Lecturer
3. General Admin
4. Finance Admin
5. Department Admin
6. System Admin

---

## Complete Module Hierarchy

| Module | Sub-Modules | Feature Count | Primary Users | Complexity |
|---|---:|---:|---|---|
| MOD-1: Authentication & Security | 5 | 18 | All Users | Medium |
| MOD-2: User Management | 5 | 22 | Admin, System Admin | High |
| MOD-3: Academic Structure | 5 | 16 | Admin, Dept Admin | Medium |
| MOD-4: Course Management | 5 | 20 | Lecturer, Admin, Student | High |
| MOD-5: Student Lifecycle | 6 | 28 | Student, Lecturer, Admin | High |
| MOD-6: Finance & Fees | 6 | 22 | Finance Admin, Student, Admin | High |
| MOD-7: Communication | 6 | 18 | All Users | Medium |
| MOD-8: Administration & Analytics | 6 | 24 | System Admin, Admin Roles | High |
| **TOTAL** | **44** | **168** | **6 role types** | **Enterprise** |

---

## Module Detail (Scope Outline)

### MOD-1: Authentication & Security (5)
1. User Authentication
2. User Registration
3. Password Management
4. RBAC
5. Session & Security Audit

Dependency note:
- Foundational for MOD-2 through MOD-8.

### MOD-2: User Management (5)
1. Student Records Management
2. Applicant Management
3. Lecturer/Faculty Records
4. Administrative User Management
5. User Lifecycle & Transitions

Dependency note:
- Depends on MOD-1.
- Supplies identity and role data to MOD-3, MOD-4, MOD-5, MOD-6, MOD-7.

### MOD-3: Academic Structure (5)
1. Faculty Management
2. Department Management
3. Program Management
4. Academic Calendar & Sessions
5. Curriculum Structure

Dependency note:
- Depends on MOD-2 for assignment actors (deans/HODs).
- Supplies structure to MOD-4, MOD-5, MOD-6, MOD-7.

### MOD-4: Course Management (5)
1. Course Catalog
2. Course Assignment
3. Course Materials & Resources
4. Prerequisites & Corequisites
5. Course Registration

Dependency note:
- Depends on MOD-2 and MOD-3.
- Supplies course/enrollment data to MOD-5 and MOD-7.

### MOD-5: Student Lifecycle (6)
1. Application Management
2. Enrollment Management
3. Attendance Tracking
4. Timetable & Scheduling
5. Grade Management
6. Academic Standing & Probation

Dependency note:
- Depends on MOD-2, MOD-3, MOD-4.
- Supplies standing/grade/attendance outcomes to MOD-6, MOD-7, MOD-8.

### MOD-6: Finance & Fees (6)
1. Fee Structure Configuration
2. Student Fee Billing
3. Payment Processing
4. Scholarships & Discounts
5. Financial Reports & Analytics
6. Arrears & Debt Management

Dependency note:
- Depends on MOD-2, MOD-3, MOD-5.
- Supplies finance state to MOD-7 and MOD-8.

### MOD-7: Communication (6)
1. Announcements & Notices
2. Targeted Messaging
3. Push Notifications
4. Email Integration
5. Communication History
6. Bulk Communication

Dependency note:
- Depends on MOD-2, MOD-3, MOD-4.
- Integrates with MOD-5 and MOD-6 for event-triggered notifications.

### MOD-8: Administration & Analytics (6)
1. System Configuration
2. Role & Permission Builder
3. Audit Logs & Compliance
4. Reports & Dashboards
5. Data Backup & Recovery
6. Integration Management

Dependency note:
- Consumes read data from MOD-1 through MOD-7 for governance/reporting.
- Provides platform-level configuration and oversight controls (not core domain master data).

---

## Role-to-Module Access Matrix

| Module / Role | Student | Lecturer | General Admin | Finance Admin | Department Admin | System Admin |
|---|---|---|---|---|---|---|
| MOD-1 Authentication | Full (own) | Full (own) | Full (all) | Full (own) | Full (own) | Full (all) |
| MOD-2 User Mgmt | Read (own) | Read (own) | Full | Read (billing scope) | Read/Write (dept scope) | Full |
| MOD-3 Academic Structure | Read | Read | Full | Read | Read/Write (dept/faculty scope) | Full |
| MOD-4 Course Mgmt | Read/Register | Read/Manage assigned | Full | No | Read/Write (dept scope) | Full |
| MOD-5 Student Lifecycle | Full (own) | Write (attendance/grades) | Full | Read (billing relevance) | Read (dept students) | Full |
| MOD-6 Finance & Fees | Read (own) | No | Read | Full | No | Full |
| MOD-7 Communication | Read/Receive | Read/Create (course scope) | Full/Broadcast | Read/Create (finance scope) | Read/Create (dept scope) | Full |
| MOD-8 Admin & Analytics | No | No | Read (reports) | Read (finance reports) | Read (dept reports) | Full |

---

## Inter-Module Data Flow

| Source Module | Consuming Module | Data Exchanged |
|---|---|---|
| MOD-1 | MOD-2..MOD-8 | Identity verification, JWT claims, RBAC context |
| MOD-2 | MOD-3, MOD-4, MOD-5, MOD-6, MOD-7 | User profile/state/role records |
| MOD-3 | MOD-4, MOD-5, MOD-6, MOD-7 | Faculty/department/program/session/curriculum structure |
| MOD-4 | MOD-5, MOD-7 | Course offerings, assignments, registration outcomes |
| MOD-5 | MOD-6, MOD-7, MOD-8 | Enrollment status, attendance, grades, standing |
| MOD-6 | MOD-7, MOD-8 | Balances, billing status, payment outcomes |
| MOD-7 | All modules (event-driven) | Delivery status, notification events, comm logs |
| MOD-8 | MOD-1..MOD-7 (config/observability) | Policies, audit requirements, analytics views |

---

## Technology Stack Alignment (Implementation Target)

| Tier | Technology | Usage |
|---|---|---|
| Client | Flutter 3.x + Dart | Mobile UI for all role personas |
| API | FastAPI (async) + Pydantic v2 | Module REST APIs and validation |
| Auth/Security | JWT + role claims + password hashing | Centralized auth and RBAC enforcement |
| Data Access | SQLAlchemy 2.x (async) + asyncpg | ORM/repository patterns and transactional flows |
| Database | PostgreSQL 15/16 | Primary relational store |
| Cache/Realtime support | Redis | Session/cache/rate-limit/queue helper patterns |
| API Docs | OpenAPI/Swagger | Contract-first interface visibility |
| Background jobs | Celery/RQ or FastAPI task strategy (TBD) | Notification/async processing |

---

## SRS Documentation Roadmap

| Phase | Module | Priority | Dependency Prerequisites |
|---|---|---|---|
| Phase 1 | MOD-1 Authentication & Security | Critical | None |
| Phase 1 | MOD-3 Academic Structure | Critical | None |
| Phase 2 | MOD-2 User Management | Critical | MOD-1 |
| Phase 3 | MOD-4 Course Management | High | MOD-2, MOD-3 |
| Phase 3 | MOD-5 Student Lifecycle | High | MOD-2, MOD-3, MOD-4 |
| Phase 4 | MOD-6 Finance & Fees | High | MOD-2, MOD-3, MOD-5 |
| Phase 4 | MOD-7 Communication | Medium | MOD-2, MOD-3, MOD-4, MOD-5, MOD-6 |
| Phase 5 | MOD-8 Administration & Analytics | Medium | All previous |

---

## Data Entity Expansion Summary (Normalized)

The expanded architecture introduces **10 new entities** and modifies **4 existing entities**.

### New Entities (10)
1. `Faculty`
2. `Application`
3. `ApplicationDocument`
4. `Payment`
5. `Scholarship`
6. `ScholarshipAward`
7. `Notification`
8. `EmailLog`
9. `AuditLog`
10. `SystemConfig`

### Modified Existing Entities (4)
1. `User` (multi-role + lifecycle extensions)
2. `Admin` (admin-type and scope granularity)
3. `Fee` (billing/payment-reconciliation enhancements)
4. `Announcement` (targeting, priority, expiration, delivery metadata)

---

## Risk & Complexity Snapshot

| Module | Risk | Complexity Driver | Mitigation |
|---|---|---|---|
| MOD-1 | Low | Security edge cases | Security-focused unit/integration tests |
| MOD-2 | Medium | Multi-role + lifecycle transitions | Explicit state machine and policy checks |
| MOD-3 | Low | Hierarchical data integrity | Strong FK constraints and scoped permissions |
| MOD-4 | Medium | Prerequisites/registration constraints | Transactional checks and rollback-safe flows |
| MOD-5 | High | GPA/standing correctness | Deterministic calculation tests + golden cases |
| MOD-6 | High | Financial correctness/reconciliation | Decimal-safe math + audit trails |
| MOD-7 | Medium | Multi-channel reliability | Queue + retry + idempotent delivery design |
| MOD-8 | Medium | Cross-module aggregation | Read-optimized reporting paths + caches |

---

## Conclusion

This normalized architecture is the baseline for module-level SRS authoring and implementation planning. It resolves earlier inconsistencies in counts, dependencies, and stack alignment while preserving your intended domain scope and role complexity.

Recommended next move:
- Start SRS drafting for MOD-1 and MOD-3 first, then follow dependency order.
