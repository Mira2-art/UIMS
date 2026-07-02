"""Rich demo dataset for local development / showcase.

Run with:  python -m app.db.seed_demo   (or `make seed-demo`).
Run `make seed` first (roles, clients, admin). Idempotent guard: skips if the
B.Sc Computer Science program already exists.

Shape (Cameroon calendar — academic year starts October):
  * 2 faculties → 1 department each → 1 programme each: Computer Science (focus)
    and Management.
  * 4 semesters: 2024/2025 S1+S2 and 2025/2026 S3 (all completed) + S4 (current).
  * 6 courses per semester per programme; lecturers per department; a Dean per faculty.
  * 10 students per programme. Each registers all 6 courses every semester (24 each).
  * Completed semesters carry published CA (/30) + EXAM (/70) grades; the system
    auto-computes each semester's GPA and the cumulative CGPA (4.0 scale).
"""

from __future__ import annotations

import asyncio
from datetime import UTC, date, datetime
from decimal import Decimal

from sqlalchemy import select

from app.core.security import hash_password
from app.db.session import SessionLocal
from app.db.sis_models import (
    Announcement,
    AnnouncementTarget,
    AttendanceRecord,
    AttendanceSession,
    AttendanceStatus,
    Course,
    CourseMaterial,
    Department,
    Enrollment,
    EnrollmentStatus,
    Faculty,
    FeeCharge,
    FeeStatus,
    FeeStructure,
    Grade,
    GradeAssessment,
    Lecturer,
    Notification,
    NotificationType,
    Payment,
    PaymentMethod,
    PriorityLevel,
    Program,
    Role,
    Semester,
    Student,
    User,
    UserRole,
    UserStatus,
)
from app.modules.grades.schemas import AcademicStandingCreate
from app.modules.grades.service import StandingService

_PW = hash_password("Password123!")

# Cameroonian student names. Index 0 (cs.student1) is Samira Ambani.
_FIRST = ["Samira", "Achille", "Nadège", "Aristide", "Brigitte", "Cédric", "Diane", "Emmanuel", "Francine", "Ghislaine"]
_LAST = ["Ambani", "Nkengfack", "Mbarga", "Fotso", "Njoya", "Tchamba", "Etoundi", "Manga", "Atangana", "Ndongo"]

# Separate Cameroonian lecturer pool (7: 4 CS + 3 Management).
_LECTURERS = [
    ("Pr. Bernard", "Eyenga"), ("Dr. Solange", "Mbella"), ("Dr. Thomas", "Awono"),
    ("Dr. Rose", "Kamga"), ("Dr. Patrick", "Nana"), ("Dr. Estelle", "Bayiha"),
    ("Dr. Hervé", "Tagne"),
]

# (code, title, credit_units) — 6 per semester (index 0..3).
_CS_COURSES = [
    [("CSC101", "Introduction to Computing", 3), ("CSC103", "Programming I", 4),
     ("MAT101", "Calculus I", 3), ("PHY101", "Mechanics", 2),
     ("GST101", "Communication Skills", 2), ("STA101", "Introductory Statistics", 3)],
    [("CSC102", "Programming II", 4), ("CSC104", "Discrete Mathematics", 3),
     ("MAT102", "Calculus II", 3), ("PHY102", "Electricity & Magnetism", 2),
     ("GST102", "Use of Library", 2), ("ENT102", "Entrepreneurship", 2)],
    [("CSC201", "Data Structures & Algorithms", 4), ("CSC203", "Object-Oriented Programming", 3),
     ("CSC205", "Computer Architecture", 3), ("MAT201", "Linear Algebra", 3),
     ("CSC207", "Digital Logic Design", 2), ("STA201", "Probability Theory", 3)],
    [("CSC202", "Design & Analysis of Algorithms", 4), ("CSC204", "Database Systems", 3),
     ("CSC206", "Operating Systems", 3), ("CSC208", "Web Development", 3),
     ("MAT202", "Numerical Methods", 2), ("CSC210", "Software Engineering", 3)],
]
_MGT_COURSES = [
    [("MGT101", "Introduction to Management", 3), ("ACC101", "Financial Accounting I", 3),
     ("ECO101", "Microeconomics", 3), ("BUS101", "Business Mathematics", 2),
     ("GST110", "Communication Skills", 2), ("LAW101", "Business Law", 2)],
    [("MGT102", "Principles of Marketing", 3), ("ACC102", "Financial Accounting II", 3),
     ("ECO102", "Macroeconomics", 3), ("BUS102", "Business Statistics", 2),
     ("ENT110", "Entrepreneurship", 2), ("MGT104", "Organisational Behaviour", 2)],
    [("MGT201", "Human Resource Management", 3), ("ACC201", "Cost Accounting", 3),
     ("FIN201", "Corporate Finance", 3), ("MKT201", "Consumer Behaviour", 3),
     ("MGT203", "Operations Management", 2), ("ECO201", "Managerial Economics", 3)],
    [("MGT202", "Strategic Management", 3), ("FIN202", "Investment Analysis", 3),
     ("MKT202", "Digital Marketing", 3), ("ACC202", "Management Accounting", 3),
     ("MGT204", "Project Management", 2), ("MGT206", "Business Ethics", 2)],
]


def _scores(student_idx: int, course_idx: int) -> tuple[Decimal, Decimal]:
    """Deterministic, varied CA (/30) + EXAM (/70). Students 8–9 are weaker."""
    base = student_idx * 7 + course_idx * 13
    if student_idx >= 8:
        return Decimal(10 + base % 10), Decimal(22 + base % 25)
    return Decimal(18 + base % 12), Decimal(40 + base % 30)


async def _role_map(session) -> dict:
    return {r.role_code: r for r in (await session.execute(select(Role))).scalars()}


async def seed_demo() -> None:
    from app.db.session import init_db

    await init_db()  # ensure tables exist (no-op on an Alembic'd Postgres; needed on SQLite)
    async with SessionLocal() as session:
        if (
            await session.execute(select(Program).where(Program.code == "BSC-CS"))
        ).scalar_one_or_none() is not None:
            print("Demo data already seeded — skipping.")
            return

        from app.db.seed import _ensure_roles  # ensure system roles exist

        await _ensure_roles(session)
        await session.flush()
        roles = await _role_map(session)

        def assign_role(user_id, code):
            role = roles.get(code)
            if role is not None:
                session.add(UserRole(user_id=user_id, role_id=role.role_id))

        # ── Faculties / departments / programmes ──────────────────────────────
        fac_comp = Faculty(name="Faculty of Computing & Information Technology", code="FCIT")
        fac_biz = Faculty(name="Faculty of Business & Management", code="FBM")
        session.add_all([fac_comp, fac_biz])
        await session.flush()

        dept_cs = Department(name="Computer Science", code="CSC", faculty_id=fac_comp.faculty_id)
        dept_mgt = Department(name="Management", code="MGT", faculty_id=fac_biz.faculty_id)
        session.add_all([dept_cs, dept_mgt])
        await session.flush()

        prog_cs = Program(
            name="B.Sc. Computer Science", code="BSC-CS",
            department_id=dept_cs.department_id, duration_years=3, total_credits=120,
        )
        prog_mgt = Program(
            name="B.Sc. Management", code="BSC-MGT",
            department_id=dept_mgt.department_id, duration_years=3, total_credits=120,
        )
        session.add_all([prog_cs, prog_mgt])
        await session.flush()

        # ── Semesters (S1–S3 completed, S4 current) — fetch-or-create so this
        #    coexists with `seed.py`, which already creates the current year. ────
        sem_specs = [
            ("2024/2025 First Semester", "2024/2025", 1, date(2024, 10, 1), date(2025, 2, 15), False, "CLOSED"),
            ("2024/2025 Second Semester", "2024/2025", 2, date(2025, 3, 1), date(2025, 7, 15), False, "CLOSED"),
            ("2025/2026 First Semester", "2025/2026", 1, date(2025, 10, 1), date(2026, 2, 15), False, "CLOSED"),
            ("2025/2026 Second Semester", "2025/2026", 2, date(2026, 3, 1), date(2026, 7, 15), True, "ACTIVE"),
        ]
        sems = []
        for name, ay, num, start, end, active, st in sem_specs:
            existing = (
                await session.execute(
                    select(Semester).where(
                        Semester.academic_year == ay, Semester.semester_number == num
                    )
                )
            ).scalar_one_or_none()
            if existing is None:
                existing = Semester(
                    name=name, academic_year=ay, semester_number=num,
                    start_date=start, end_date=end, is_active=active, status=st,
                )
                session.add(existing)
                await session.flush()
            sems.append(existing)

        # ── Lecturers (users + Lecturer + LECTURER role) + Deans ──────────────
        async def make_lecturers(dept, prefix, count, offset):
            out = []
            for i in range(count):
                first, last = _LECTURERS[offset + i]
                u = User(
                    email=f"{prefix.lower()}.lecturer{i + 1}@trustech.cm", password_hash=_PW,
                    first_name=first, last_name=last,
                    status=UserStatus.ACTIVE, email_verified=True,
                )
                session.add(u)
                await session.flush()
                lec = Lecturer(
                    user_id=u.user_id, staff_id=f"{prefix}-L{i + 1:03d}",
                    department_id=dept.department_id, title="Dr.",
                )
                session.add(lec)
                await session.flush()
                assign_role(u.user_id, "LECTURER")
                out.append((u, lec))
            return out

        cs_lecturers = await make_lecturers(dept_cs, "CSC", 4, offset=0)
        mgt_lecturers = await make_lecturers(dept_mgt, "MGT", 3, offset=4)

        # Deans (dual role dean/lecturer) — enable faculty-scoped exam entry/publish.
        fac_comp.dean_id = cs_lecturers[0][1].lecturer_id
        fac_biz.dean_id = mgt_lecturers[0][1].lecturer_id
        assign_role(cs_lecturers[0][0].user_id, "DEAN")
        assign_role(mgt_lecturers[0][0].user_id, "DEAN")
        await session.flush()

        # ── Courses + assessments (CA 30 + EXAM 70 per course) ────────────────
        programs = [
            (prog_cs, cs_lecturers, _CS_COURSES),
            (prog_mgt, mgt_lecturers, _MGT_COURSES),
        ]
        courses_by_prog_sem: dict = {}
        assessments: dict = {}  # course_id -> (ca, exam)
        lecturer_user: dict = {}  # course_id -> lecturer user_id
        dean_user = {
            prog_cs.program_id: cs_lecturers[0][0],
            prog_mgt.program_id: mgt_lecturers[0][0],
        }
        for prog, lecturers, names in programs:
            for si, sem in enumerate(sems):
                clist = []
                for ci, (code, title, cu) in enumerate(names[si]):
                    lec_user, lec = lecturers[ci % len(lecturers)]
                    course = Course(
                        code=code, title=title, credit_units=cu, program_id=prog.program_id,
                        lecturer_id=lec.lecturer_id, semester_id=sem.semester_id, max_capacity=60,
                    )
                    session.add(course)
                    await session.flush()
                    lecturer_user[course.course_id] = lec_user.user_id
                    ca = GradeAssessment(
                        course_id=course.course_id, assessment_type="CA_TEST",
                        name="Continuous Assessment", max_score=Decimal(30), weight_percent=Decimal(30),
                        is_published=(si < 3), created_by=lec_user.user_id,
                    )
                    exam = GradeAssessment(
                        course_id=course.course_id, assessment_type="EXAM",
                        name="Final Examination", max_score=Decimal(70), weight_percent=Decimal(70),
                        is_published=(si < 3), created_by=lec_user.user_id,
                    )
                    session.add_all([ca, exam])
                    await session.flush()
                    assessments[course.course_id] = (ca, exam)
                    clist.append(course)
                courses_by_prog_sem[(prog.program_id, si)] = clist

        # ── Students (10 per programme) ───────────────────────────────────────
        students_by_prog: dict = {}
        for prog, _lecturers, _names in programs:
            prefix = "CS" if prog is prog_cs else "MG"
            slist = []
            for i in range(10):
                u = User(
                    email=f"{prefix.lower()}.student{i + 1}@trustech.cm", password_hash=_PW,
                    first_name=_FIRST[i], last_name=_LAST[i],
                    status=UserStatus.ACTIVE, email_verified=True,
                )
                session.add(u)
                await session.flush()
                st = Student(
                    user_id=u.user_id, matric_no=f"{prefix}24-{i + 1:03d}",
                    program_id=prog.program_id, level=200, session="2024/2025",
                )
                session.add(st)
                await session.flush()
                assign_role(u.user_id, "STUDENT")
                slist.append(st)
            students_by_prog[prog.program_id] = slist

        await session.commit()

        # ── Enrollments + grades + standings, semester by semester ────────────
        now = datetime.now(UTC)
        for si, sem in enumerate(sems):
            completed = si < 3
            for prog, _lecturers, _names in programs:
                clist = courses_by_prog_sem[(prog.program_id, si)]
                for sidx, st in enumerate(students_by_prog[prog.program_id]):
                    for cidx, course in enumerate(clist):
                        enr = Enrollment(
                            student_id=st.student_id, course_id=course.course_id,
                            status=EnrollmentStatus.ACTIVE,
                        )
                        session.add(enr)
                        await session.flush()
                        if not completed:
                            continue  # S4: registered, results in progress
                        ca, exam = assessments[course.course_id]
                        ca_score, exam_score = _scores(sidx, cidx)
                        session.add(Grade(
                            enrollment_id=enr.enrollment_id, assessment_id=ca.assessment_id,
                            score=ca_score,
                            percentage=(ca_score / Decimal(30) * Decimal(100)).quantize(Decimal("0.01")),
                            letter_grade=None, is_published=True, published_at=now,
                            published_by=lecturer_user[course.course_id],
                        ))
                        session.add(Grade(
                            enrollment_id=enr.enrollment_id, assessment_id=exam.assessment_id,
                            score=exam_score,
                            percentage=(exam_score / Decimal(70) * Decimal(100)).quantize(Decimal("0.01")),
                            letter_grade=None, is_published=True, published_at=now,
                            published_by=dean_user[prog.program_id].user_id,
                        ))
            await session.commit()

            if completed:
                standing = StandingService(session)
                for prog, _lecturers, _names in programs:
                    for st in students_by_prog[prog.program_id]:
                        await standing.compute_and_record(
                            AcademicStandingCreate(student_id=st.student_id, semester_id=sem.semester_id)
                        )
                await session.commit()

        # ── Finance: fee structures, per-semester charges + payments (FCFA) ───
        recorder = cs_lecturers[0][0].user_id  # any valid user as created/recorded_by
        tuition_fs = FeeStructure(
            fee_name="Tuition", fee_code="TUITION-UG", fee_category="TUITION",
            amount=Decimal("350000"), currency="XAF", is_mandatory=True, created_by=recorder,
        )
        registration_fs = FeeStructure(
            fee_name="Registration", fee_code="REGISTRATION-UG", fee_category="REGISTRATION",
            amount=Decimal("50000"), currency="XAF", is_mandatory=True, created_by=recorder,
        )
        session.add_all([tuition_fs, registration_fs])
        await session.flush()

        for si, sem in enumerate(sems):
            current = si == 3  # S4 is in progress → still outstanding
            for prog, _lecturers, _names in programs:
                for st in students_by_prog[prog.program_id]:
                    for fs in (tuition_fs, registration_fs):
                        amount = fs.amount
                        # Completed semesters fully paid; current: registration paid,
                        # tuition partially paid (a balance remains outstanding).
                        if not current:
                            paid, status = amount, FeeStatus.PAID
                        elif fs is registration_fs:
                            paid, status = amount, FeeStatus.PAID
                        else:
                            paid, status = Decimal("100000"), FeeStatus.PARTIAL
                        charge = FeeCharge(
                            student_id=st.student_id, semester_id=sem.semester_id,
                            fee_structure_id=fs.fee_structure_id, amount=amount,
                            amount_paid=paid, due_date=sem.end_date,
                            description=f"{fs.fee_name} — {sem.name}", status=status,
                        )
                        session.add(charge)
                        await session.flush()
                        if paid > 0:
                            session.add(Payment(
                                student_id=st.student_id, charge_id=charge.charge_id,
                                amount=paid, payment_method=PaymentMethod.MOBILE_MONEY,
                                payment_date=sem.start_date,
                                receipt_number=f"RCPT-{str(charge.charge_id)[:8]}",
                                recorded_by=recorder,
                            ))
        await session.commit()

        # ── Course materials (current semester) ───────────────────────────────
        # Give every current-semester course a syllabus, lecture notes and a link
        # so the student app's "Course Materials" screen has content.
        current_sem_idx = 3
        materials_added = 0
        for prog, _lecturers, _names in programs:
            for course in courses_by_prog_sem[(prog.program_id, current_sem_idx)]:
                uploader = lecturer_user[course.course_id]
                session.add_all([
                    CourseMaterial(
                        course_id=course.course_id, title=f"{course.code} Course Syllabus",
                        material_type="SYLLABUS",
                        description="Course outline, grading policy and reading list.",
                        file_path=f"static/public/materials/{course.code.lower()}_syllabus.pdf",
                        uploaded_by=uploader, is_published=True,
                    ),
                    CourseMaterial(
                        course_id=course.course_id, title="Week 1 — Lecture Notes",
                        material_type="DOCUMENT",
                        description="Introductory lecture slides.",
                        file_path=f"static/public/materials/{course.code.lower()}_week1.pdf",
                        uploaded_by=uploader, is_published=True,
                    ),
                    CourseMaterial(
                        course_id=course.course_id, title="Recommended Reading",
                        material_type="LINK",
                        description="Supplementary online resource.",
                        external_url="https://opentextbc.ca/",
                        uploaded_by=uploader, is_published=True,
                    ),
                ])
                materials_added += 3
        await session.commit()

        # ── Attendance (current semester) ─────────────────────────────────────
        # 4 weekly sessions per current-semester course, one record per enrolled
        # student. Deterministic status: mostly PRESENT, with some LATE/ABSENT.
        current_sem = sems[current_sem_idx]
        attend_status_cycle = [
            AttendanceStatus.PRESENT, AttendanceStatus.PRESENT, AttendanceStatus.PRESENT,
            AttendanceStatus.LATE, AttendanceStatus.PRESENT, AttendanceStatus.ABSENT,
            AttendanceStatus.PRESENT, AttendanceStatus.EXCUSED,
        ]
        sessions_added = records_added = 0
        for prog, _lecturers, _names in programs:
            prog_students = students_by_prog[prog.program_id]
            for course in courses_by_prog_sem[(prog.program_id, current_sem_idx)]:
                recorder_uid = lecturer_user[course.course_id]
                for week in range(4):
                    sess = AttendanceSession(
                        course_id=course.course_id,
                        session_date=date(
                            current_sem.start_date.year,
                            current_sem.start_date.month,
                            min(1 + week * 7, 28),
                        ),
                        topic=f"Week {week + 1} session",
                        created_by=recorder_uid,
                    )
                    session.add(sess)
                    await session.flush()
                    sessions_added += 1
                    for sidx, st in enumerate(prog_students):
                        session.add(AttendanceRecord(
                            attendance_session_id=sess.attendance_session_id,
                            student_id=st.student_id,
                            status=attend_status_cycle[(sidx + week) % len(attend_status_cycle)],
                            recorded_by=recorder_uid,
                        ))
                        records_added += 1
            await session.commit()

        # ── Announcements (school-wide) ───────────────────────────────────────
        author_uid = recorder  # a valid staff user id (reused from finance block)
        announcements = [
            ("Welcome to the 2025/2026 Second Semester",
             "Lectures resume Monday. Please complete course registration and "
             "clear any outstanding fees before the second week.",
             PriorityLevel.HIGH, True, False),
            ("Second Semester Fee Deadline",
             "All tuition balances must be settled by the end of week 4. "
             "Students with outstanding balances may be blocked from exams.",
             PriorityLevel.URGENT, True, True),
            ("Library Extended Opening Hours",
             "The main library is now open until 10 PM on weekdays during the "
             "semester to support your studies.",
             PriorityLevel.NORMAL, False, False),
            ("Mid-Semester Assessment Timetable Released",
             "The continuous assessment timetable is now available. Check your "
             "course pages for dates and venues.",
             PriorityLevel.HIGH, False, False),
        ]
        ann_rows: list[Announcement] = []
        for title, content, priority, pinned, urgent in announcements:
            ann = Announcement(
                title=title, content=content, author_id=author_uid,
                target_type=AnnouncementTarget.ALL, priority=priority,
                is_pinned=pinned, is_urgent=urgent, published_at=now,
            )
            session.add(ann)
            ann_rows.append(ann)
        await session.flush()

        # ── Notifications (per student) ───────────────────────────────────────
        fee_announcement = ann_rows[1]
        notifs_added = 0
        for prog, _lecturers, _names in programs:
            for st in students_by_prog[prog.program_id]:
                student_user_id = st.user_id
                session.add_all([
                    Notification(
                        user_id=student_user_id, title="Results published",
                        message="Your 2025/2026 First Semester results are now available.",
                        notification_type=NotificationType.GRADE_POSTED,
                        is_read=False, action_url="/grades",
                    ),
                    Notification(
                        user_id=student_user_id, title="Outstanding tuition balance",
                        message="You have an outstanding tuition balance for the current semester.",
                        notification_type=NotificationType.FEE_REMINDER,
                        is_read=False, action_url="/finance",
                    ),
                    Notification(
                        user_id=student_user_id, title=fee_announcement.title,
                        message="A new announcement was posted.",
                        notification_type=NotificationType.ANNOUNCEMENT,
                        reference_type="announcement",
                        reference_id=fee_announcement.announcement_id,
                        is_read=True, read_at=now, action_url="/announcements",
                    ),
                ])
                notifs_added += 3
        await session.commit()

        print(
            "Demo seed complete — 2 faculties / 2 programmes, 4 semesters, "
            "48 courses, 7 lecturers, 20 students, full CS+MGT enrolments + "
            "published CA/EXAM grades for 3 semesters + computed GPA/CGPA + "
            "fee structures, charges & payments (FCFA) + "
            f"{materials_added} course materials, {sessions_added} attendance "
            f"sessions / {records_added} records, {len(ann_rows)} announcements, "
            f"{notifs_added} notifications."
        )


if __name__ == "__main__":
    asyncio.run(seed_demo())
