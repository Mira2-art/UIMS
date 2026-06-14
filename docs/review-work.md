# Trustech SIS — Backend Review

**Base URL:** `http://localhost:8000/api/v1`  
**Auth:** Bearer JWT — include `Authorization: Bearer <access_token>` on all protected routes.  
**Total endpoints:** 141

---

## Role Reference

| Code | Description |
|------|-------------|
| `SUPER_ADMIN` | Full system access — highest authority |
| `ADMIN` | Full management access, cannot change system configs |
| `REGISTRAR` | Student lifecycle, enrollment, applicants, academic structure reads |
| `LECTURER` | Own courses, grades, attendance, materials |
| `STUDENT` | Own data only — enrollments, grades (published), timetable, finances |
| `FINANCE` | All finance operations, student financial reads |
| `HR` | Lecturer management |
| `STAFF` | Announcements, notifications |

---

## MOD-1 — Authentication & Security (16 endpoints)

### Public (no token required)

| Method | Path | What it does |
|--------|------|--------------|
| `POST` | `/auth/register` | Create a new user account. Hashes password with bcrypt. Sets status=`PENDING`. Fires welcome email in background. Returns `UserRead`. |
| `POST` | `/auth/login` | Verify email + password. Creates `UserSession` with JTI. Returns `access_token` (30 min) + `refresh_token` (7 days). Logs audit event. Fires on bad creds: 401. Suspended account: 403. |
| `POST` | `/auth/refresh` | Exchange a valid refresh JWT for a new token pair. Does NOT require Authorization header — pass `refresh_token` in body. |
| `POST` | `/auth/forgot-password` | Generates a sha256-hashed `PasswordResetToken` (1 h TTL) and fires reset email. Returns the raw token in dev (not in prod). Always returns 200 even if email not found (prevents enumeration). |
| `POST` | `/auth/reset-password` | Validates reset token hash, sets new password, marks token used. |
| `POST` | `/auth/verify-email` | Confirms email using the short-lived JWT token from `/send-verification`. Sets `email_verified=true` and status=`ACTIVE`. |

### Authenticated — Any role

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/auth/logout` | Revokes `UserSession` by `session_id` (query param). Token becomes invalid on next request. Logs audit event. | Any authenticated |
| `POST` | `/auth/change-password` | Verifies current password, sets new one. Logs audit event. | Any authenticated |
| `POST` | `/auth/send-verification` | Issues a 24 h verification JWT and fires verification email. Returns token directly in dev. | Any authenticated |

### RBAC Management — ADMIN / SUPER_ADMIN

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `GET` | `/auth/roles` | List all roles in the system. | ADMIN, SUPER_ADMIN |
| `POST` | `/auth/roles` | Create a new role (`role_name`, `role_code`, `description`). | ADMIN, SUPER_ADMIN |
| `GET` | `/auth/permissions` | List all permission definitions. | ADMIN, SUPER_ADMIN |
| `POST` | `/auth/permissions` | Create a new permission definition (`permission_name`, `permission_code`, `module`). | SUPER_ADMIN only |
| `POST` | `/auth/roles/{role_id}/permissions` | Assign a permission to a role (idempotency checked). | ADMIN, SUPER_ADMIN |
| `POST` | `/auth/users/{user_id}/roles` | Assign a role to a user. Records `assigned_by`. | ADMIN, SUPER_ADMIN |
| `DELETE` | `/auth/users/{user_id}/roles/{role_id}` | Remove a role from a user. | ADMIN, SUPER_ADMIN |

---

## MOD-2 — User Management

### Users (6 endpoints)

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `GET` | `/users/me` | Returns the current authenticated user's full profile. | Any authenticated |
| `GET` | `/users` | List all users. Filter by `status` query param. Paginated (`limit`, `offset`). | ADMIN, SUPER_ADMIN |
| `GET` | `/users/{user_id}` | Get a user by ID. | ADMIN, SUPER_ADMIN, REGISTRAR, HR |
| `PUT` | `/users/{user_id}` | Update user's `first_name`, `last_name`, `phone`. | ADMIN, SUPER_ADMIN |
| `PATCH` | `/users/{user_id}/status` | Change user status (`ACTIVE`, `INACTIVE`, `SUSPENDED`, `PENDING`). | ADMIN, SUPER_ADMIN |
| `DELETE` | `/users/{user_id}` | Soft-delete: sets status=`INACTIVE`. Non-destructive. | SUPER_ADMIN only |

### Students (21 endpoints)

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/students` | Create a student record linked to an existing User. Validates matric_no uniqueness. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `GET` | `/students` | List students. Filter by `program_id`, `level`, `status`. Paginated. | ADMIN, SUPER_ADMIN, REGISTRAR, LECTURER, FINANCE |
| `GET` | `/students/{student_id}` | Get student detail. Student can view own record. | Own student OR ADMIN, SUPER_ADMIN, REGISTRAR, LECTURER |
| `PUT` | `/students/{student_id}` | Update student record (`program_id`, `level`, `session`, `status`). | ADMIN, SUPER_ADMIN, REGISTRAR |
| `DELETE` | `/students/{student_id}` | Soft-deactivate: sets status=`INACTIVE`. | ADMIN, SUPER_ADMIN |
| `GET` | `/students/{student_id}/summary` | Enrollment count + basic academic snapshot. | Own student OR ADMIN, SUPER_ADMIN, REGISTRAR |
| `GET` | `/students/{student_id}/transcript` | Published grades only, across all courses. | Own student OR ADMIN, SUPER_ADMIN, REGISTRAR, LECTURER |
| `GET` | `/students/{student_id}/standing` | Current academic standing (GPA, CGPA, standing type). Returns null if not yet computed. | Own student OR ADMIN, SUPER_ADMIN, REGISTRAR |
| `GET` | `/students/{student_id}/timetable` | Aggregated timetable from all active enrollments. | Own student OR ADMIN, SUPER_ADMIN, REGISTRAR |
| `GET` | `/students/{student_id}/charges` | All fee charges for the student. | Own student OR ADMIN, SUPER_ADMIN, FINANCE |
| `GET` | `/students/{student_id}/payments` | All payments made by student. | Own student OR ADMIN, SUPER_ADMIN, FINANCE |
| `GET` | `/students/{student_id}/scholarships` | Scholarship awards for the student. | Own student OR ADMIN, SUPER_ADMIN, FINANCE |
| `GET` | `/students/{student_id}/attendance` | Attendance records. Optional `course_id` filter. | Own student OR ADMIN, SUPER_ADMIN, REGISTRAR, LECTURER |
| `POST` | `/students/applicants` | Submit an application (links to existing User). | Any authenticated |
| `GET` | `/students/applicants` | List applicants. Filter by `application_status`, `program_id`. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `GET` | `/students/applicants/{applicant_id}` | Get applicant detail. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `PATCH` | `/students/applicants/{applicant_id}/status` | Advance application status (`SUBMITTED` → `UNDER_REVIEW` → `ACCEPTED` / `REJECTED`). Sets `decision_date`. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `POST` | `/students/applicants/{applicant_id}/convert` | Convert an `ACCEPTED` applicant into a Student record. Requires `matric_no`, `program_id`, `level`, `session`. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `POST` | `/students/applicants/{applicant_id}/documents` | Add a document reference (file_path, doc_type, mime_type, file_size). No actual upload — store storage path. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `GET` | `/students/applicants/{applicant_id}/documents` | List all documents for an applicant. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `DELETE` | `/students/applicants/{applicant_id}/documents/{doc_id}` | Remove a document reference. | ADMIN, SUPER_ADMIN, REGISTRAR |

### Teachers / Lecturers (5 endpoints)

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/teachers` | Create a lecturer record linked to an existing User. Validates staff_id uniqueness. | ADMIN, SUPER_ADMIN, HR |
| `GET` | `/teachers` | List lecturers. Filter by `department_id`. | Any authenticated |
| `GET` | `/teachers/{lecturer_id}` | Get lecturer detail. | Any authenticated |
| `PUT` | `/teachers/{lecturer_id}` | Update lecturer (`department_id`, `title`, `employment_status`, `specialization`). | ADMIN, SUPER_ADMIN, HR |
| `GET` | `/teachers/{lecturer_id}/courses` | Courses currently assigned to this lecturer. | Any authenticated |

---

## MOD-3 — Academic Structure (20 endpoints)

### Faculties

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/academic-structure/faculties` | Create a faculty (`name`, `code`, `description`, `dean_id`). Code is auto-uppercased. Checks uniqueness. | ADMIN, SUPER_ADMIN |
| `GET` | `/academic-structure/faculties` | List all faculties. | Any authenticated |
| `GET` | `/academic-structure/faculties/{faculty_id}` | Get faculty detail. | Any authenticated |
| `PUT` | `/academic-structure/faculties/{faculty_id}` | Update faculty fields. Can set/change dean. | ADMIN, SUPER_ADMIN |

### Departments

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/academic-structure/departments` | Create a department within a faculty. Can set HOD. | ADMIN, SUPER_ADMIN |
| `GET` | `/academic-structure/departments` | List departments. Filter by `faculty_id`. | Any authenticated |
| `GET` | `/academic-structure/departments/{dept_id}` | Get department detail. | Any authenticated |
| `PUT` | `/academic-structure/departments/{dept_id}` | Update department fields. | ADMIN, SUPER_ADMIN |

### Programs

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/academic-structure/programs` | Create a degree program (`name`, `code`, `department_id`, `duration_years`, `total_credits`, `award_type`). | ADMIN, SUPER_ADMIN |
| `GET` | `/academic-structure/programs` | List programs. Filter by `department_id`. | Any authenticated |
| `GET` | `/academic-structure/programs/{program_id}` | Get program detail. | Any authenticated |
| `PUT` | `/academic-structure/programs/{program_id}` | Update program fields. | ADMIN, SUPER_ADMIN |
| `GET` | `/academic-structure/programs/{program_id}/curriculum` | List all courses in a program's curriculum with level and semester. | Any authenticated |
| `POST` | `/academic-structure/programs/{program_id}/curriculum` | Add a course to the curriculum (`course_id`, `level`, `semester_offered`, `is_core`, `is_elective`). | ADMIN, SUPER_ADMIN, REGISTRAR |
| `DELETE` | `/academic-structure/programs/{program_id}/curriculum/{cc_id}` | Remove a course from the curriculum. | ADMIN, SUPER_ADMIN, REGISTRAR |

### Semesters / Academic Calendar

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/academic-structure/semesters` | Create a semester (`name`, `academic_year`, `semester_number`, `start_date`, `end_date`, registration window, exam dates). | ADMIN, SUPER_ADMIN |
| `GET` | `/academic-structure/semesters` | List semesters. Filter by `academic_year`. | Any authenticated |
| `GET` | `/academic-structure/semesters/{semester_id}` | Get semester detail. | Any authenticated |
| `PUT` | `/academic-structure/semesters/{semester_id}` | Update semester fields (dates, status). | ADMIN, SUPER_ADMIN |
| `PATCH` | `/academic-structure/semesters/{semester_id}/activate` | Deactivates all other semesters and sets this one as `is_active=true`, `status=ACTIVE`. | ADMIN, SUPER_ADMIN |

---

## MOD-4 — Course Management (15 endpoints)

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/courses` | Create a course offering (`code`, `title`, `credit_units`, `program_id`, `semester_id`, `lecturer_id`, `max_capacity`). Code is auto-uppercased. Checks code+semester uniqueness. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `GET` | `/courses` | List courses. Filter by `program_id`, `semester_id`, `lecturer_id`, `status`. Paginated. | Any authenticated |
| `GET` | `/courses/{course_id}` | Get course detail including capacity counters. | Any authenticated |
| `PUT` | `/courses/{course_id}` | Update course metadata, capacity, status. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `PATCH` | `/courses/{course_id}/syllabus` | Set the syllabus file path (`syllabus_path` query param — client stores file, API stores path). | ADMIN, SUPER_ADMIN, REGISTRAR, LECTURER |
| `PATCH` | `/courses/{course_id}/assign-lecturer` | Assign or remove a lecturer (`lecturer_id` can be null). | ADMIN, SUPER_ADMIN, REGISTRAR |
| `GET` | `/courses/{course_id}/students` | List students currently enrolled (ACTIVE status). | ADMIN, SUPER_ADMIN, REGISTRAR, LECTURER |
| `POST` | `/courses/{course_id}/prerequisites` | Add a prerequisite (`prereq_course_id`, `is_corequisite`, `is_strict`). Blocks self-reference and duplicates. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `GET` | `/courses/{course_id}/prerequisites` | List all prerequisites for a course. | Any authenticated |
| `DELETE` | `/courses/{course_id}/prerequisites/{prereq_id}` | Remove a prerequisite. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `POST` | `/courses/{course_id}/materials` | Add a material reference (`title`, `material_type`, `file_path` or `external_url`, `is_published`). Sets `uploaded_by` to current user. | ADMIN, SUPER_ADMIN, LECTURER |
| `GET` | `/courses/{course_id}/materials` | List all materials for a course. | Any authenticated |
| `DELETE` | `/courses/{course_id}/materials/{material_id}` | Remove a material. | ADMIN, SUPER_ADMIN, LECTURER |
| `POST` | `/courses/{course_id}/timetable` | Add a timetable entry (`day_of_week`, `start_time`, `end_time`, `venue`, `entry_type`). Time format: `HH:MM`. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `GET` | `/courses/{course_id}/timetable` | List timetable entries for a course. | Any authenticated |

---

## MOD-5 — Student Lifecycle

### Enrollments (6 endpoints)

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/enrollments` | Enroll a student in a course. Checks: (1) not already enrolled, (2) capacity, (3) strict prerequisites are COMPLETED, (4) registration window for STUDENT role only. Increments `current_enrollment`. | ADMIN, SUPER_ADMIN, REGISTRAR, STUDENT |
| `GET` | `/enrollments` | List enrollments. Filter by `student_id`, `course_id`, `status`. | Any authenticated |
| `GET` | `/enrollments/{enrollment_id}` | Get single enrollment detail. | Any authenticated |
| `PATCH` | `/enrollments/{enrollment_id}/drop` | Student/registrar drops a course. Sets status=`DROPPED`, records `drop_date` and optional `drop_reason`. Decrements `current_enrollment`. | ADMIN, SUPER_ADMIN, REGISTRAR, STUDENT |
| `PATCH` | `/enrollments/{enrollment_id}/withdraw` | Administrative withdrawal (formal). Sets status=`WITHDRAWN`, records reason. | ADMIN, SUPER_ADMIN, REGISTRAR |
| `PATCH` | `/enrollments/{enrollment_id}/complete` | Mark a course as successfully completed. Sets status=`COMPLETED`. Used at semester end. | ADMIN, SUPER_ADMIN, REGISTRAR |

### Grades & Assessments (8 endpoints)

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/grades/assessments` | Create a grade assessment for a course (`assessment_type`: CA_TEST / CA_ASSIGNMENT / CA_QUIZ / CA_PROJECT / EXAM / FINAL, `max_score`, `weight_percent`). | ADMIN, SUPER_ADMIN, LECTURER |
| `GET` | `/grades/assessments` | List assessments for a course (`course_id` required). | Any authenticated |
| `GET` | `/grades/assessments/{assessment_id}` | Get assessment detail. | Any authenticated |
| `PUT` | `/grades/assessments/{assessment_id}` | Update assessment (name, description, dates, publish flag). | ADMIN, SUPER_ADMIN, LECTURER |
| `POST` | `/grades` | Submit a grade for `enrollment_id` + `assessment_id`. Auto-calculates `percentage` and `letter_grade` (A≥70%, B≥60%, C≥50%, D≥45%, F<45%). Validates score ≤ max_score. | ADMIN, SUPER_ADMIN, LECTURER |
| `GET` | `/grades` | List grades. Filter by `course_id` or `student_id`. | Any authenticated |
| `PATCH` | `/grades/{grade_id}/publish` | Publish a grade — sets `is_published=true`, `published_at`, `published_by`. Published grades appear on student transcripts. | ADMIN, SUPER_ADMIN, LECTURER |
| `POST` | `/grades/standings` | Compute and record academic standing for a student in a semester. Calculates GPA on 5.0 scale, assigns standing type (DEANS_LIST ≥4.5, GOOD_STANDING ≥1.5, PROBATION <1.5). | ADMIN, SUPER_ADMIN, REGISTRAR |

### Attendance (5 endpoints)

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/attendance/sessions` | Create an attendance session for a course date (`course_id`, `session_date`, `topic`). | ADMIN, SUPER_ADMIN, LECTURER |
| `GET` | `/attendance/sessions` | List sessions for a course (`course_id` required). | Any authenticated |
| `POST` | `/attendance/sessions/{session_id}/records` | Bulk record attendance. Body: list of `{student_id, status, notes}`. Status values: `PRESENT`, `ABSENT`, `LATE`, `EXCUSED`. Upserts — re-recording a student updates their status. | ADMIN, SUPER_ADMIN, LECTURER |
| `GET` | `/attendance/sessions/{session_id}/records` | Get all attendance records for a session. | Any authenticated |
| `GET` | `/attendance/students/{student_id}/summary` | Attendance summary for a student in a course (`course_id` required). Returns counts per status and attendance rate (%). | Any authenticated |

---

## MOD-6 — Finance & Fees (17 endpoints)

### Fee Structures

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/finance/fee-structures` | Create a fee structure (`fee_name`, `fee_code`, `fee_category`, `amount`, `currency`, `effective_from`). Can be scoped to a program, faculty, or level. | ADMIN, SUPER_ADMIN, FINANCE |
| `GET` | `/finance/fee-structures` | List all fee structures. | Any authenticated |
| `GET` | `/finance/fee-structures/{fee_structure_id}` | Get fee structure detail. | Any authenticated |
| `PUT` | `/finance/fee-structures/{fee_structure_id}` | Update fee structure (name, amount, dates, active status). | ADMIN, SUPER_ADMIN, FINANCE |

### Fee Charges (Billing)

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/finance/charges` | Bill a student by creating a `FeeCharge` linked to a fee structure and semester. Initial status=`OUTSTANDING`. | ADMIN, SUPER_ADMIN, FINANCE |
| `GET` | `/finance/charges` | List all charges. | ADMIN, SUPER_ADMIN, FINANCE |
| `GET` | `/finance/charges/{charge_id}` | Get charge detail including balance. | Any authenticated |
| `PATCH` | `/finance/charges/{charge_id}/discount` | Apply a discount amount to a charge. Auto-recalculates status (PAID / PARTIAL / OUTSTANDING). | ADMIN, SUPER_ADMIN, FINANCE |

### Payments

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/finance/payments` | Record a payment against a charge. Accepts `payment_method` (CASH / BANK_TRANSFER / ONLINE / CHEQUE / MOBILE_MONEY). Auto-updates charge `amount_paid` and status. | ADMIN, SUPER_ADMIN, FINANCE |
| `GET` | `/finance/payments` | List all payments. | ADMIN, SUPER_ADMIN, FINANCE |
| `GET` | `/finance/payments/{payment_id}` | Get payment detail. | Any authenticated |
| `PATCH` | `/finance/payments/{payment_id}/reverse` | Reverse a payment. Restores `amount_paid` on the charge. Optional `reason` query param. | ADMIN, SUPER_ADMIN, FINANCE |

### Scholarships

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/finance/scholarships` | Create a scholarship definition (`scholarship_type`: MERIT / NEED_BASED / SPORTS / RESEARCH / GOVERNMENT / PRIVATE / OTHER, `amount` or `percentage_coverage`). | ADMIN, SUPER_ADMIN, FINANCE |
| `GET` | `/finance/scholarships` | List all scholarships. | Any authenticated |
| `POST` | `/finance/scholarships/{scholarship_id}/awards` | Award a scholarship to a student for a semester. Records `approved_by`. | ADMIN, SUPER_ADMIN, FINANCE |

### Reports

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `GET` | `/finance/reports/outstanding` | Students with outstanding balances — grouped by student with totals. | ADMIN, SUPER_ADMIN, FINANCE |
| `GET` | `/finance/reports/collection` | Payment collection summary — total payments, gross collected, reversed amount, net collected. | ADMIN, SUPER_ADMIN, FINANCE |

---

## MOD-7 — Communication (10 endpoints)

### Announcements

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `POST` | `/communication/announcements` | Create an announcement (`title`, `content`, `target_type`: ALL / FACULTY / DEPARTMENT / PROGRAM / COURSE, `priority`: LOW / NORMAL / HIGH / URGENT, `is_pinned`, `is_urgent`, `expires_at`). | ADMIN, SUPER_ADMIN, STAFF |
| `GET` | `/communication/announcements` | List announcements. Filter by `target_type`, `target_id`, `published_only`. Pinned announcements appear first. | Any authenticated |
| `GET` | `/communication/announcements/{announcement_id}` | Get announcement and increment `view_count`. | Any authenticated |
| `PATCH` | `/communication/announcements/{announcement_id}/publish` | Publish an announcement — sets `published_at` timestamp. | ADMIN, SUPER_ADMIN, STAFF |

### Notifications

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `GET` | `/communication/notifications` | Get current user's notifications, ordered newest first (last 50). | Any authenticated |
| `PATCH` | `/communication/notifications/{notification_id}/read` | Mark one notification as read. Enforces ownership. | Any authenticated |
| `PATCH` | `/communication/notifications/read-all` | Mark all current user's unread notifications as read in one shot. | Any authenticated |
| `POST` | `/communication/notifications/send` | Send a notification to a specific list of user IDs. | ADMIN, SUPER_ADMIN, STAFF |
| `POST` | `/communication/notifications/broadcast` | Broadcast a notification to ALL users holding specific roles (`role_codes` list). Fetches matching users and creates individual notifications. | ADMIN, SUPER_ADMIN, STAFF |

### Email Logs

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `GET` | `/communication/email-logs` | List email log entries (delivery tracking). `limit` query param (max 500). | ADMIN, SUPER_ADMIN |

---

## MOD-8 — Administration & Analytics (7 endpoints)

### System Configs

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `GET` | `/administration/configs` | List all system configuration keys and values. Sensitive configs have `is_sensitive=true` (value shown but flagged). | ADMIN, SUPER_ADMIN |
| `GET` | `/administration/configs/{config_key}` | Get a single config by key. | ADMIN, SUPER_ADMIN |
| `PUT` | `/administration/configs/{config_key}` | Update a config value. Blocked if `is_editable=false`. Records `updated_by`. | SUPER_ADMIN only |

### Audit Logs

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `GET` | `/administration/audit-logs` | List audit log entries. Filter by `user_id`, `entity_type`, `action`, `date_from`, `date_to`. Ordered newest-first. | ADMIN, SUPER_ADMIN |
| `GET` | `/administration/audit-logs/{audit_id}` | Get a single audit log entry. | ADMIN, SUPER_ADMIN |

### Reports

| Method | Path | What it does | Access |
|--------|------|--------------|--------|
| `GET` | `/administration/reports/users` | User counts grouped by status (ACTIVE, INACTIVE, SUSPENDED, PENDING). | ADMIN, SUPER_ADMIN |
| `GET` | `/administration/reports/enrollments` | Enrollment stats grouped by course — total, active, dropped counts. | ADMIN, SUPER_ADMIN, REGISTRAR |

---

## Background Email (Celery)

### Setup

1. **Install (already done):** `pip install celery[redis] aiosmtplib`

2. **Enable Redis** — Celery uses Redis as its broker. Ensure Redis is running:
   ```bash
   redis-server
   ```

3. **Configure `.env`:**
   ```env
   REDIS_ENABLED=true
   CELERY_BROKER_URL=redis://localhost:6379/1
   CELERY_RESULT_BACKEND=redis://localhost:6379/2
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   GMAIL_FROM=put real gmail address here@gmail.com
   GMAIL_APP_PASSWORD=put real 16-character gmail app password here
   EMAIL_ENABLED=true
   ```
   > **Gmail App Password:** Enable 2-Step Verification on the Google account, then go to  
   > [https://myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords) and generate a 16-character app password.

4. **Start the worker** (from `/backend` directory):
   ```bash
   source env/bin/activate
   celery -A app.core.celery_app worker --loglevel=info --queues=email --concurrency=2
   ```

5. **Development mode** — set `EMAIL_ENABLED=false` in `.env` to skip sending and just log to console. All task calls still go through the queue but return `{"status": "skipped"}`.

### Where emails are triggered automatically

| Event | Email sent | Task function |
|-------|-----------|---------------|
| `POST /auth/register` | Welcome email to new user | `send_welcome_email()` |
| `POST /auth/send-verification` | Email verification token | `send_verification_email()` |
| `POST /auth/forgot-password` | Password reset token | `send_password_reset_email()` |

### Pre-built task helpers (wire these when needed)

Located in `app/tasks/email.py`:

| Function | Use when |
|----------|----------|
| `send_welcome_email(to, first_name)` | After registration |
| `send_verification_email(to, first_name, token)` | Email verification flow |
| `send_password_reset_email(to, first_name, raw_token)` | Password reset flow |
| `send_grade_published_email(to, first_name, course_code, letter_grade)` | After `PATCH /grades/{id}/publish` |
| `send_fee_reminder_email(to, first_name, outstanding_amount, due_date)` | Scheduled reminders for outstanding fees |

### File layout

```
backend/
├── app/
│   ├── core/
│   │   └── celery_app.py      # Celery instance + config
│   └── tasks/
│       ├── __init__.py
│       └── email.py           # All email tasks + helpers
└── .env                       # GMAIL_FROM, GMAIL_APP_PASSWORD, EMAIL_ENABLED
```

---

## Remaining Gaps / Future Work

| Item | Status | Notes |
|------|--------|-------|
| Email sending when grade published | Planned | Call `send_grade_published_email()` inside `GradeService.publish()` |
| Fee reminder scheduling | Planned | Use `celery beat` + `send_fee_reminder_email()` on a cron |
| Push notifications (FCM/APNs) | Planned | `Notification` model exists; add Firebase task in `app/tasks/push.py` |
| File upload (syllabus, documents) | Planned | API accepts `file_path` strings; add S3/MinIO upload task |
| Student self-serve password reset (link-based) | Planned | Currently token returned in API response; wire email link when SMTP live |
| Applicant document storage | Planned | `ApplicantDocument` stores path; actual upload is client-side to storage |
| Celery beat (scheduled jobs) | Planned | Add to `celery_app.py` `beat_schedule` for fee reminders, standing recomputes |
