# Features Plan 1 — Auth · Home · Courses (part 1) — screens 1–10

> UI-only. Read `student-app-impl-overview.md` (conventions, §3 tokens, §4 duplicate
> choices) and complete `components-impl-plan.md` first. Each screen: match its Stitch
> screenshot, build with `ui_kit` + theme, data from mock providers, no backend.
> Design source base: `design/stitch-student/<folder>` (or the Downloads export).
> Per-screen quality gate: matches screenshot (light+dark) · routed · `flutter analyze` 0 · no API.

---

## Feature: `auth`  (routes outside the shell)

### 1. Welcome
- **Source:** `student_auth_welcome_light` + `student_auth_welcome_dark_{choice #1}`
- **Route:** `/welcome` · **File:** `features/auth/presentation/screens/welcome_screen.dart` (exists — update to match design)
- **Layout:** `BrandGradientHeader` (teal→`#2D5A68`), `school` logo + wordmark, headline + tagline, **Get Started** (primary/amber) + **Login** (outline) buttons, footer © line.
- **Components:** `BrandGradientHeader`, `TrustechButton`. **Nav:** Get Started/Login → `/login`.

### 2. Login
- **Source:** `student_auth_login_light{_v2 #2}` + `student_auth_login_dark{_v2 #3}`
- **Route:** `/login` · **File:** `features/auth/presentation/screens/login_screen.dart`
- **Layout:** logo/title, email field (mail prefix), password field (lock prefix + eye), "Forgot password?" link (right), **Sign in** button, optional helper text.
- **Components:** `TrustechTextField` ×2, `TrustechButton`. **States:** button loading on submit (mock delay → go `/home`). **Nav:** forgot → `/forgot-password`; submit → `/home`.

### 3. Forgot Password
- **Source:** `student_auth_forgot_password_light`
- **Route:** `/forgot-password` · **File:** `.../screens/forgot_password_screen.dart`
- **Layout:** back app bar, title + helper, email field, **Send reset code** button → success confirmation panel ("code sent").
- **Components:** `TrustechTextField`, `TrustechButton`, `SuccessStateCard`. **Nav:** continue → `/reset-password`.

### 4. Reset Password
- **Source:** `student_auth_reset_password_light`
- **Route:** `/reset-password` · **File:** `.../screens/reset_password_screen.dart`
- **Layout:** code/token field, new password + confirm (eye toggles), **Reset password** button → success.
- **Components:** `TrustechTextField` ×3, `TrustechButton`. **Nav:** success → `/login`.

### 5. Verify Email
- **Source:** `student_auth_verify_email_light`
- **Route:** `/verify-email` · **File:** `.../screens/verify_email_screen.dart`
- **Layout:** illustration/icon, status text, **Send verification** button, "resend" countdown, confirmation state.
- **Components:** `TrustechButton`, `SuccessStateCard`.

---

## Feature: `home`  (tab 1)

### 6. Home Dashboard  ★ flagship
- **Source:** `student_home_dashboard_light_v2` + `student_home_dashboard_dark_v2` (default per §4 #4/#5)
- **Route:** `/home` · **File:** `features/home/presentation/screens/home_screen.dart`
- **Layout (top→bottom):** `AppHeaderBar.home` (avatar + wordmark + bell w/ badge); **GPA/Standing card** (GPA value, GOOD STANDING `StatusChip`, program + level); **quick-actions row** (Timetable · Registration · Transcript — icon tiles); **Finance Balance card** (teal filled, amount + "Outstanding Balance" + **Pay Now**); **Today's Classes** (`SectionHeader` "See All" + 2–3 `ClassRow`/`InfoListRow` with icon, code+title, time, venue); **Announcements** (horizontal scroller of image cards w/ category tag).
- **Components:** `HomeHeaderBar`, `StatusChip`, `StatCard`/custom standing card, `InfoListRow`, `SectionHeader`, announcement card, `TrustechCard`.
- **Mock:** `homeSummaryProvider` (standing, balance, todays classes, announcements) → `// TODO(backend:)` (standing, timetable, charges, announcements).
- **Nav:** quick actions → `/home/timetable`, `/courses/register`, `/grades`; Pay Now → `/finance`; bell → `/notifications`; class → `/courses/:id`; announcement → `/announcements/:id`; See All → `/home/timetable`.

---

## Feature: `courses`  (tab 2 — part 1)

### 7. My Courses
- **Source:** `student_courses_my_courses_empty_light` (empty) + build populated list
- **Route:** `/courses` · **File:** `features/courses/presentation/screens/my_courses_screen.dart`
- **Layout:** app bar (title + semester filter), list of course cards (`InfoListRow`: code+title, lecturer, units, status chip), FAB/app-bar action → Registration.
- **States:** populated · **empty** (match `my_courses_empty_light`: "No courses found" + Register CTA) · loading (skeleton).
- **Mock:** `myCoursesProvider`. **Nav:** card → `/courses/:id`; register → `/courses/register`.

### 8. Course Registration
- **Source:** `student_courses_registration_light` + `student_courses_registration_closed_light` (closed) + `student_courses_registration_open_dark` (dark)
- **Route:** `/courses/register` · **File:** `.../screens/course_registration_screen.dart`
- **Layout:** **window banner** (open = teal/success, closed = muted/amber), search/filter, available-course rows (units, lecturer, capacity used, prereq tag) each with **Enroll** button.
- **States:** **open** (enroll enabled) · **closed** (enroll disabled + "Registration closed" banner) · enroll confirm sheet · success snackbar.
- **Mock:** `availableCoursesProvider`, `registrationWindowProvider`. **Nav:** course → `/courses/:id`.

### 9. Course Detail
- **Source:** `student_courses_detail_light_{choice #6}`
- **Route:** `/courses/:id` · **File:** `.../screens/course_detail_screen.dart`
- **Layout:** header (code, title, lecturer, semester, units, capacity); sectioned tabs/anchors: **Materials**, **Timetable**, **My Attendance**, **My Grades**; **Drop course** action (confirm sheet w/ reason).
- **Components:** `TrustechCard`, `InfoListRow`, `StatusChip`, `SectionHeader`, confirm sheet. **Nav:** Materials → `/courses/:id/materials`; Attendance → `/courses/:id/attendance`.

### 10. Course Materials
- **Source:** `student_courses_materials_light`
- **Route:** `/courses/:id/materials` · **File:** `.../screens/course_materials_screen.dart`
- **Layout:** list of materials (`InfoListRow`: title, type chip DOCUMENT/VIDEO/LINK/ASSIGNMENT/QUIZ/SYLLABUS, size/date, download/open icon).
- **States:** list · empty · loading. **Mock:** `courseMaterialsProvider(:id)`.

---

### Routing additions (this plan)
Auth routes (`/welcome` `/login` `/forgot-password` `/reset-password` `/verify-email`) outside shell. Home tab branch (`/home`). Courses tab branch (`/courses`, `/courses/register`, `/courses/:id`, `/courses/:id/materials`). Wire into `app_router.dart` + `MainShell`.
