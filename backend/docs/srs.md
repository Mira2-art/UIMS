# Trustech School Information System (SIS)
## Master Software Requirements Specification (SRS)

**Version:** 1.0 (Consolidated Draft)
**Standard Basis:** IEEE 29148 / IEEE 830 style
**Project:** Trustech School Information System (SIS)
**Prepared For:** Trustech University
**Prepared By:** Software Engineering Team
**Date:** 2026-05-31
**Related Documents:** `docs/arch.md`, `docs/srs-template.md`

---

## 1. Introduction

### 1.1 Purpose
This SRS defines the functional and non-functional requirements for the Trustech School Information System (SIS), a multi-role platform for academic, financial, administrative, communication, and governance operations.

### 1.2 Scope
The system shall provide:
- Authentication and access control
- User and identity lifecycle management
- Academic structure management
- Course and registration management
- Student lifecycle operations (application to standing)
- Finance and fees administration
- Communication and notification services
- Administration, analytics, and compliance

### 1.3 Business Objectives
1. Digitize core university operations end-to-end.
2. Reduce paper-based workflows significantly.
3. Improve registration and academic operations efficiency.
4. Automate grade, GPA, and CGPA computation.
5. Improve financial transparency and reconciliation.
6. Enable mobile-first institutional access.
7. Centralize institutional data governance.
8. Provide executive reporting and dashboards.

---

## 2. Stakeholders and User Roles

### 2.1 Stakeholders
| Stakeholder | Responsibility |
|---|---|
| Student | Academic and financial self-service |
| Applicant | Admission application lifecycle |
| Lecturer | Course delivery, attendance, grading |
| Department Admin | Departmental operations and oversight |
| Finance Admin | Fee and payment operations |
| General Admin | Institution-wide academic/admin workflows |
| System Admin | Platform governance and security |
| University Management | Decision support and analytics |

### 2.2 Role Types
1. Student
2. Lecturer
3. General Admin
4. Finance Admin
5. Department Admin
6. System Admin

---

## 3. System Overview

### 3.1 Architecture Style
- Mobile-first, modular, service-layered architecture.
- High cohesion inside modules, loose coupling across modules.
- Role-based access enforced at API and business layers.

### 3.2 Technology Stack (Current Implementation Target)
- Client: Flutter mobile apps
- API: FastAPI (async), REST, OpenAPI
- Security: JWT + RBAC + password hashing
- Data: PostgreSQL (primary), Redis (cache/session/event helper)
- Integrations: Email (SMTP/API), push notifications (FCM), payment gateway, SMS provider

Note:
- Earlier drafts referenced Spring Boot. The current backend implementation target is FastAPI async.

---

## 4. Module Structure

The system is organized into **8 modules**, **44 sub-modules**, and **168 high-level features**.

| Module ID | Module Name | Sub-Modules |
|---|---|---:|
| MOD-1 | Authentication & Security | 5 |
| MOD-2 | User Management | 5 |
| MOD-3 | Academic Structure | 5 |
| MOD-4 | Course Management | 5 |
| MOD-5 | Student Lifecycle | 6 |
| MOD-6 | Finance & Fees | 6 |
| MOD-7 | Communication | 6 |
| MOD-8 | Administration & Analytics | 6 |

---

## 5. Functional Requirements

## FR-100: MOD-1 Authentication & Security

### FR-101 User Login
- The system shall allow login using email and password.
- On valid credentials, system issues access token (JWT) and refresh flow support.
- On invalid credentials, system returns authentication error without credential leakage.

### FR-102 Registration
- Student self-registration shall be supported.
- Staff/admin registration shall be admin-mediated.
- Duplicate identity detection shall be enforced.

### FR-103 Password Management
- Password reset by secure token/OTP flow.
- Password change for authenticated users.
- Password strength policy and expiry policy configurable.

### FR-104 RBAC Enforcement
- Permissions shall be enforced at API, service, and data-scope levels.
- Multi-role users shall receive union of allowed permissions with explicit deny precedence.

### FR-105 Session and Security Audit
- Login, logout, token refresh, password reset, role changes, and suspicious auth events shall be logged.

## FR-200: MOD-2 User Management

### FR-201 Student Records
- Create/update/view student records, matriculation number generation, progression state.

### FR-202 Applicant Management
- Online application capture, status tracking, admission decisioning, applicant-to-student conversion.

### FR-203 Lecturer/Faculty Records
- Lecturer profiles, department assignment, rank/title, workload visibility.

### FR-204 Administrative Multi-Role Management
- Admin roles: General Admin, Finance Admin, Department Admin, System Admin.
- A user may hold multiple admin roles with scope boundaries.

### FR-205 User Lifecycle Transitions
- Supported transitions include applicant, admitted, active, inactive, alumni/archived states.

## FR-300: MOD-3 Academic Structure

### FR-301 Faculty Management
- Create/update/deactivate faculties, assign deans.

### FR-302 Department Management
- Create/update/deactivate departments under faculties, assign HODs.

### FR-303 Program Management
- Define programs, duration, and program metadata.

### FR-304 Academic Calendar
- Define sessions/semesters, registration windows, exam periods, active term.

### FR-305 Curriculum Structure
- Define core/elective groupings, prerequisites, and curriculum versions.

## FR-400: MOD-4 Course Management

### FR-401 Course Catalog
- Manage course code, title, credits, category, description, and status.

### FR-402 Course Assignment
- Assign lecturers to courses/sections with workload visibility.

### FR-403 Course Materials
- Upload and publish course resources with access control.

### FR-404 Prerequisite/Corequisite Rules
- Enforce prerequisite/corequisite constraints during registration.

### FR-405 Course Registration
- Register/add/drop within allowed windows with validation and audit trail.

## FR-500: MOD-5 Student Lifecycle

### FR-501 Application Management
- Applicant submission, document upload, review workflow, offer/decision lifecycle.

### FR-502 Enrollment Management
- Program/semester enrollment, transfer workflows, leave-of-absence handling.

### FR-503 Attendance Tracking
- Lecturer attendance sessions, marking, attendance ratios, threshold alerts.

### FR-504 Timetable & Scheduling
- Class and exam scheduling with conflict detection and publish control.

### FR-505 Grade Management
- CA/exam entry, weighted computation, publish workflow, grade history.

### FR-506 Academic Standing
- GPA/CGPA calculations, probation/suspension decisions, standing notifications.

## FR-600: MOD-6 Finance & Fees

### FR-601 Fee Structure
- Configure fees by category, program, level, and policy period.

### FR-602 Billing
- Generate semester charges automatically, support waivers/adjustments.

### FR-603 Payment Processing
- Capture payments, support partial payments, issue receipts, update balance.

### FR-604 Scholarships/Discounts
- Manage scholarship definitions and awards; apply funding rules to billing.

### FR-605 Financial Reporting
- Revenue, collections, outstanding balances, and aging views.

### FR-606 Arrears Management
- Arrears flags, payment plans, clearance/hold policies, exception approvals.

## FR-700: MOD-7 Communication

### FR-701 Announcements
- Broadcast notices by institution/faculty/department/course scope.

### FR-702 Targeted Messaging
- Direct and group messaging by role or academic scope.

### FR-703 Push Notifications
- Event-driven push for grades, finance reminders, deadlines, attendance alerts.

### FR-704 Email Services
- Template-based transactional and bulk email with delivery tracking.

### FR-705 Communication History
- Searchable archive with read/delivery metadata.

### FR-706 Bulk Communication
- Scheduled mass communication and import-driven distribution.

## FR-800: MOD-8 Administration & Analytics

### FR-801 System Configuration
- Configure academic and operational rules (e.g., grade boundaries, attendance thresholds).

### FR-802 Role/Permission Builder
- Define custom roles and fine-grained permission maps.

### FR-803 Audit & Compliance
- Queryable activity logs and compliance-ready reports.

### FR-804 Dashboards and Reporting
- Executive and operational dashboards across enrollment, finance, and academics.

### FR-805 Backup & Recovery
- Scheduled backups, integrity verification, and recovery procedures.

### FR-806 Integration Management
- Configure and monitor external integrations (payment, email, SMS, SSO/webhooks).

---

## 6. Role-to-Module Access Matrix (Summary)

| Module | Student | Lecturer | General Admin | Finance Admin | Department Admin | System Admin |
|---|---|---|---|---|---|---|
| MOD-1 | Own auth | Own auth | Full | Own auth | Own auth | Full |
| MOD-2 | Own profile | Own profile | Full | Read (billing scope) | Dept scope | Full |
| MOD-3 | Read | Read | Full | Read | Dept/faculty scope | Full |
| MOD-4 | Register/read | Manage assigned | Full | No | Dept scope | Full |
| MOD-5 | Own lifecycle | Attendance/grades | Full | Read (billing relevance) | Dept read | Full |
| MOD-6 | Own finance | No | Read | Full | No | Full |
| MOD-7 | Receive/read | Course comms | Full | Finance comms | Dept comms | Full |
| MOD-8 | No | No | Reports | Finance reports | Dept reports | Full |

---

## 7. Non-Functional Requirements

### 7.1 Performance
- API p95 response target: <= 2 seconds (general endpoints).
- Dashboard load target: <= 5 seconds under defined report scope.
- Concurrent users target: >= 1,000.

### 7.2 Scalability
- Initial scale target: >= 10,000 students.
- Growth target: up to 50,000 students and multi-campus evolution.

### 7.3 Availability and Reliability
- Service uptime target: 99.9%.
- ACID guarantees for financial and grade-critical transactions.
- Automated backups and tested recovery plan.

### 7.4 Security
- HTTPS-only transport.
- JWT-based authentication and RBAC enforcement.
- Secure password hashing.
- Audit logging for sensitive actions.

### 7.5 Maintainability
- Modular codebase organization.
- API documentation via OpenAPI.
- Automated tests with high coverage targets for critical paths.

---

## 8. Data Requirements

### 8.1 Database Requirements
The system shall use PostgreSQL with normalized schemas supporting all 8 modules.

### 8.2 Entity Expansion (Normalized)
- New entities: `Faculty`, `Application`, `ApplicationDocument`, `Payment`, `Scholarship`, `ScholarshipAward`, `Notification`, `EmailLog`, `AuditLog`, `SystemConfig`.
- Modified entities: `User`, `Admin`, `Fee`, `Announcement`.

### 8.3 Integrity and Identity
- UUID primary keys for domain entities.
- Strong foreign key enforcement and scoped uniqueness constraints.
- Immutable auditing for sensitive operations where required.

---

## 9. Integrations and External Interfaces

### 9.1 Required Integrations
1. Push notifications (FCM)
2. Email provider (SMTP/API)
3. Payment gateway
4. SMS provider (optional/phase-based)

### 9.2 API Interface
- RESTful API endpoints under versioned path (e.g., `/api/v1`).
- OpenAPI contract publication for clients and QA.

---

## 10. Testing and Acceptance

### 10.1 Test Layers
- Unit tests for domain logic.
- Integration tests for service-repository-db interactions.
- API contract tests for request/response consistency.
- End-to-end tests for high-risk user journeys.

### 10.2 Critical Acceptance Outcomes
1. Student registration and lifecycle processes are fully digital.
2. Grade computation and publish workflows are automated and auditable.
3. Fee billing and payment reconciliation are automated and verifiable.
4. Role-based permissions prevent unauthorized actions.
5. Executive dashboards provide accurate near-real-time insights.

---

## 11. Delivery Roadmap for Module-Level SRS

1. MOD-1 Authentication & Security
2. MOD-3 Academic Structure
3. MOD-2 User Management
4. MOD-4 Course Management
5. MOD-5 Student Lifecycle
6. MOD-6 Finance & Fees
7. MOD-7 Communication
8. MOD-8 Administration & Analytics

---

## 12. Future Enhancements (Out of Current Scope)

Recommended future modules:
1. Library Management
2. Hostel & Accommodation Management
3. Examination/CBT Management
4. Parent Portal
5. Alumni Portal
6. Research Repository/LMS integration

These are intentionally excluded from current implementation scope and treated as roadmap extensions.

---

## 13. Open Decisions

1. Confirm final backend stack lock: FastAPI async (current) vs any alternate.
2. Confirm payment provider(s) and reconciliation flow.
3. Confirm identity proofing requirements for applicant onboarding.
4. Confirm formal data retention periods by module for compliance.

---

## 14. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Product Owner |  |  |  |
| Engineering Lead |  |  |  |
| QA Lead |  |  |  |
| Security/Compliance |  |  |  |
