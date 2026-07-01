# Trustech — Backend Integration Plan (screen by screen)

How each mobile screen connects to the FastAPI backend. Both apps are currently
**UI-only (mock providers)**; this plan replaces each mock with a typed service +
provider hitting the API. Base URL: `{{API}}/api/v1`.

## 0. Conventions / Foundation (do once per app)

- **Auth header:** every request sends `X-Client-ID` — `trustech_mobile_client`
  (student) / `trustech_staff_client` (staff) — and `Authorization: Bearer <access>`.
- **Login:** `POST /auth/login` with `{email, password, client_id, device_info}` →
  `{access, refresh}`. Persist with `flutter_secure_storage` (already wired).
- **Token refresh:** on `401` (non-public), `POST /auth/refresh` with the refresh token +
  `X-Client-ID`, retry once, else clear session → `/welcome`. (Add to `token_interceptor`.)
- **Identity:** `GET /users/me` → user + roles, then the student app calls
  **`GET /students/me`** → its `StudentRead` (incl. `student_id`), which every other
  `/students/{id}/…` endpoint needs. ✅ added.
- **Pattern:** `features/<f>/data/<f>_service.dart` (Dio) → DTOs (`fromJson`) →
  `features/<f>/providers` AsyncNotifier exposing `AsyncValue`; screens render
  loading/empty/error via the ui-kit states. Replace each `data/mock/*` provider in place.
- **Errors:** map Dio errors → user message in `core/exceptions/error_mapper.dart`.

---

## 1. Student app — `trustech_mobile`  (client_id `trustech_mobile_client`)

| Screen | Route | Endpoint(s) | Notes |
|---|---|---|---|
| Splash | `/splash` | — | boot; decide `/home` vs `/welcome` from stored session |
| Welcome | `/welcome` | — | — |
| Login | `/login` | `POST /auth/login` → `GET /users/me` → `GET /students/me` | store tokens + `student_id` |
| Forgot / Reset | `/forgot-password`, `/reset-password` | `POST /auth/forgot-password`, `POST /auth/reset-password` | — |
| Verify Email | `/verify-email` | `POST /auth/send-verification`, `POST /auth/verify-email` | — |
| Home dashboard | `/home` | `GET /users/me`, `GET /students/{id}/standing`, `GET /students/{id}/timetable`, `GET /communication/announcements`, `GET /students/{id}/charges` | GPA card, today's classes, announcements, balance |
| My Courses | `/courses` | `GET /enrollments?student_id={id}` (+ `GET /courses/{id}`) | enrolled courses |
| Course Detail | `/courses/:id` | `GET /courses/{id}`, `/courses/{id}/materials`, `/courses/{id}/timetable` | |
| Course Materials | `/courses/:id/materials` | `GET /courses/{id}/materials` | |
| Course Attendance | `/courses/:id/attendance` | `GET /attendance/students/{student_id}/summary` (or `/students/{id}/attendance`) | |
| Course Registration | `/courses/register` | `GET /courses`, `POST /enrollments`, `PATCH /enrollments/{id}/drop` | window open/closed is UI |
| Weekly Timetable | `/home/timetable` | `GET /students/{id}/timetable` | |
| **Transcript** | `/grades` | **`GET /students/{id}/results`** + `GET /students/{id}/standing` | grouped CA+Exam/GPA/CGPA by year — published only |
| Academic Standing | `/grades/standing` | `GET /students/{id}/standing` | GPA/CGPA, standing |
| Finance Overview | `/finance` | `GET /students/{id}/charges`, `/students/{id}/payments`, `/students/{id}/scholarships` | |
| Charges / Charge Detail | `/finance/charges`, `/finance/charges/:id` | `GET /students/{id}/charges`, `GET /finance/charges/{id}` | |
| Payments | `/finance/payments` | `GET /students/{id}/payments` | |
| Scholarships | `/finance/scholarships` | `GET /students/{id}/scholarships` | |
| Announcements / Detail | `/announcements`, `/announcements/:id` | `GET /communication/announcements`, `/announcements/{id}` | |
| Notifications | `/notifications` | `GET /communication/notifications`, `PATCH /notifications/{id}/read`, `PATCH /notifications/read-all` | |
| Profile | `/profile` | `GET /users/me` | |
| Settings | `/settings` | theme/locale local; `POST /auth/logout` (sign out) | |
| Change Password | `/change-password` | `POST /auth/change-password` | |

---

## 2. Staff (Pro) app — `trustech_mobile_pro`  (client_id `trustech_staff_client`)

### Auth & shell
| Screen | Route | Endpoint(s) |
|---|---|---|
| Login / Forgot / Reset / Verify / Change pwd | `/login` … | `POST /auth/login` · `/auth/forgot-password` · `/auth/reset-password` · `/auth/send-verification` · `/auth/verify-email` · `/auth/change-password` |
| Home dashboard | `/home` | `GET /teachers/{id}/courses`, today's `GET /courses/{id}/timetable`, pending grading (derive) |
| Workspace hub | `/workspace` | role-gated grid from `/users/me` roles (local `moduleAccess`) |
| Notifications / detail | `/notifications`, `/notifications/:id` | `GET /communication/notifications`, `PATCH …/read`, `…/read-all` |
| Profile / Settings | `/profile`, `/settings` | `GET /users/me`; `POST /auth/logout` |

### Teaching
| Screen | Route | Endpoint(s) |
|---|---|---|
| My Courses | `/courses` | `GET /teachers/{id}/courses` |
| Course Detail | `/courses/:id` | `GET /courses/{id}`, `/courses/{id}/students`, `/materials`, `/timetable` |
| Course Roster | `/courses/:id/roster` | `GET /courses/{id}/students` |
| Materials | `/courses/:id/materials` | `GET/POST/DELETE /courses/{id}/materials` |
| Course Timetable | `/courses/:id/timetable` | `GET/POST /courses/{id}/timetable` |
| Attendance — Sessions | `/courses/:id/attendance` | `GET/POST /attendance/sessions?course_id={id}` |
| Attendance — Mark | `/courses/:id/attendance/:sessionId` | `POST /attendance/sessions/{id}/records` (bulk) |
| Attendance — Records | `…/records` | `GET /attendance/sessions/{id}/records` |
| **Gradebook — Assessments** | `/courses/:id/gradebook` | `GET /grades/assessments?course_id={id}`, `POST/PUT /grades/assessments` (CA caps 30 / Exam 70) |
| **Gradebook — Enter CA scores** | `/courses/:id/gradebook/:assessmentId` | `POST /grades/bulk` (CA grid) / `POST /grades`, `GET /grades?course_id={id}` — **LECTURER** |
| **Exam Marks (/70)** | `/courses/:id/exam-marks` | `POST /grades/bulk` (EXAM rows) — **DEAN/SECRETARIAT/ADMIN, faculty-scoped** |
| **Grades — Publish** | `/courses/:id/grades/publish` | `PATCH /grades/{id}/publish` (role+faculty split), then `POST /grades/standings` |
| Compose Announcement | `/courses/:id/announce` | `POST /communication/announcements` |

### Students & Admissions
| Screen | Route | Endpoint(s) |
|---|---|---|
| Students list | `/students` | `GET /students` |
| Student Detail | `/students/:id` | `GET /students/{id}`, `/students/{id}/summary` |
| Create/Edit Student | `/students/new`, `/students/:id/edit` | `POST /students`, `PUT /students/{id}` |
| Student Transcript (staff) | `/students/:id/transcript` | `GET /students/{id}/results` |
| Enrollments | `/enrollments` | `GET /enrollments`, `PATCH /enrollments/{id}/drop|withdraw|complete` |
| Applicants list/detail | `/applicants`, `/applicants/:id` | `GET /students/applicants`, `/applicants/{id}`, `/applicants/{id}/documents` |
| Applicant Status / Convert | `…/status`, `…/convert` | `PATCH /students/applicants/{id}/status`, `POST /students/applicants/{id}/convert` |

### Academics (Registrar)
| Screen | Route | Endpoint(s) |
|---|---|---|
| Faculties / Departments / Programs | `/academics/*` | `GET/POST/PUT /academic-structure/{faculties,departments,programs}` |
| Program Curriculum | `/academics/programs/:id/curriculum` | `GET /academic-structure/programs/{id}/curriculum` |
| Semesters | `/academics/semesters` | `GET/POST/PUT /academic-structure/semesters`, `PATCH …/{id}/activate` |
| Course Catalog (list/detail) | `/academics/catalog`, `/academics/catalog/:id` | `GET /courses`, `GET /courses/{id}` (+ `assign-lecturer`, `prerequisites`, `syllabus`) |

### Finance (Bursary)
| Screen | Route | Endpoint(s) |
|---|---|---|
| Fee Structures | `/finance/fee-structures` | `GET/POST/PUT /finance/fee-structures` |
| Charges / Bill Student / Charge Detail | `/finance/charges*` | `GET/POST /finance/charges`, `GET /finance/charges/{id}`, `PATCH …/{id}/discount` |
| Payments / Record / Detail | `/finance/payments*` | `GET/POST /finance/payments`, `GET /finance/payments/{id}`, `PATCH …/{id}/reverse` |
| Scholarships / Award | `/finance/scholarships*` | `GET/POST /finance/scholarships` |
| Reports ★ | `/finance/reports` | `GET /finance/reports/outstanding`, `/finance/reports/collection` |

### People / HR
| Screen | Route | Endpoint(s) |
|---|---|---|
| Lecturers list/detail | `/people/lecturers`, `/:id` | `GET /teachers`, `GET /teachers/{id}`, `/teachers/{id}/courses` |
| Create/Edit Lecturer | `/people/lecturers/new`, `/:id/edit` | `POST /teachers`, `PUT /teachers/{id}` |

### Administration
| Screen | Route | Endpoint(s) |
|---|---|---|
| Admin Dashboard ★ | `/admin/dashboard` | `GET /administration/reports/users`, `/reports/enrollments` |
| Users / User Detail | `/admin/users`, `/:id` | `GET /users`, `GET /users/{id}`, `PATCH /users/{id}/status` |
| Roles & Permissions | `/admin/roles` | `GET /auth/roles`, `/auth/permissions`, `POST /auth/roles/{id}/permissions`, `POST /auth/users/{id}/roles` |
| Audit Logs / Detail | `/admin/audit-logs*` | `GET /administration/audit-logs`, `/audit-logs/{id}` |
| System Configs | `/admin/configs` | `GET /administration/configs` (read-only) |
| Email Logs | `/admin/email-logs` | `GET /communication/email-logs` |

### Communication
| Screen | Route | Endpoint(s) |
|---|---|---|
| Announcements / Detail / Compose | `/announcements*` | `GET/POST /communication/announcements`, `GET /announcements/{id}`, `PATCH …/{id}/publish` |
| Broadcast Notification | `/broadcast-notification` | `POST /communication/notifications/broadcast` (or `/send`) |

---

## 3. Grading flow (the recent backend work) — end to end

1. Lecturer creates CA assessments (weights sum 30) → `POST /grades/assessments`.
2. Lecturer enters CA per student → `POST /grades` (CA) → **Enter CA Scores** screen.
3. Lecturer publishes CA → `PATCH /grades/{id}/publish`. Students immediately see **published CA** in `/students/{id}/results`.
4. Dean/Secretariat enters EXAM (/70), faculty-scoped → **Exam Marks** screen → `POST /grades` (EXAM).
5. Dean/Secretariat publishes EXAM → `PATCH /grades/{id}/publish`. Now the course is finalized → student sees **CA + Exam + Total + letter**.
6. Registrar finalizes the semester → `POST /grades/standings` → computes **semester GPA (4.0)** + **cumulative CGPA**; students see it on Transcript / Standing.

Student visibility is enforced server-side: `/students/{id}/results` is **ownership-scoped, enrolled-only, published-only**; raw `GET /grades` & `/grades/course-result` are **staff-only**.

---

## 4. Open gaps to resolve during integration

- ✅ **`student_id` resolution** — added **`GET /students/me`** (current user's `StudentRead`).
- ✅ **Bulk grade submission** — added **`POST /grades/bulk`** (`{items:[{enrollment_id, assessment_id, score, remarks}]}`; upserts; per-row CA/EXAM role + faculty + cap checks) for the Exam-Marks Excel upload + CA score grids.
- **Seed** roles/clients/semesters first (`make seed`) or auth/role-gating fails.
- **Pagination & pull-to-refresh** on all list screens; **i18n** strings; dark-mode QA (Phase 5 polish).

---

## 5. Suggested phasing

- **P0 Foundation:** auth + `X-Client-ID` + token refresh + `/users/me` + `student_id`/`me` resolution + error mapper. Gate: login→home→logout per app.
- **P1 Read-heavy:** dashboards, lists, details (courses, grades/transcript, finance, notifications).
- **P2 Write flows:** attendance marking, CA/exam entry + publish, enrollment add/drop, finance charge/payment, student/lecturer CRUD.
- **P3 Admin/registrar:** academic structure, users/roles, audit/config, reports/charts.
- **P4 Polish:** pagination, refresh, i18n, empty/error states, dark-mode QA.
