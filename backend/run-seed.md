# Trustech — Seeding & Demo Credentials

How to seed the database and the verified login credentials for the demo data.
Run all commands from the `backend/` directory with the venv active.

## Run the seeds

```bash
cd backend
source env/bin/activate          # Windows: env\Scripts\activate

python -m app.db.seed            # roles, client apps, semesters, bootstrap admin
python -m app.db.seed_demo       # faculties, courses, staff, students, grades, GPA/CGPA
```

Both are **idempotent** (safe to re-run). If PostgreSQL is unreachable they
automatically fall back to async SQLite (`trustech.db`).

> Re-seeding from scratch: if `seed_demo` prints "already seeded", reset first —
> delete `trustech.db` (SQLite) or recreate the Postgres DB (`alembic upgrade head`),
> then run the two seeds again.

What `seed_demo` creates: **2 faculties → 2 departments → 2 programmes**
(Computer Science + Management), **4 semesters** (2024/2025 S1+S2, 2025/2026 S3
completed + S4 current — Cameroon **October** calendar), **6 courses/semester**,
**7 lecturers** (+ a Dean per faculty), **10 students/programme**. The 3 completed
semesters carry published **CA (/30) + EXAM (/70)** grades; the system
auto-computes each semester's **GPA** and the cumulative **CGPA** (4.0 scale).

All demo accounts use password **`Password123!`**.

---

## Samira Ambani — credentials (verified)

| Field | Value |
|---|---|
| Name | **Samira Ambani** |
| Email (login) | `cs.student1@trustech.cm` |
| Password | `Password123!` |
| Matric | `CS24-001` |
| Programme | B.Sc. Computer Science |
| Current CGPA | 3.35 (51 credits, 3 completed semesters of published CA+EXAM) |
| App | Student app (`trustech_mobile`) |

---

## Computer Science staff (Pro app — `trustech_mobile_pro`)

Same password **`Password123!`**.

| Lecturer | Email (login) | Role / teaches |
|---|---|---|
| **Pr. Bernard Eyenga** | `csc.lecturer1@trustech.cm` | **Dean** — enters & publishes **exams (/70)**, faculty-scoped; also teaches Intro to Computing, Programming II |
| **Dr. Solange Mbella** | `csc.lecturer2@trustech.cm` | **Programming lecturer** — Programming I (CSC103) & Object-Oriented Programming (CSC203); enters **CA (/30)** |
| Dr. Thomas Awono | `csc.lecturer3@trustech.cm` | CS lecturer — enters CA (/30) |
| Dr. Rose Kamga | `csc.lecturer4@trustech.cm` | CS lecturer — enters CA (/30) |

> Grading split: **lecturers enter CA (/30)**; the **Dean** (or Secretariat/Admin)
> enters and publishes the **exam (/70)** for the faculty's courses. Students only
> see grades once published.

Other CS students follow the pattern `cs.student2…10@trustech.cm`
(matric `CS24-002 … CS24-010`). Bootstrap admin: `admin@trustech.cm` / `ChangeMe123!`.

---

## Accessing the API over the local network

Bind to `0.0.0.0` (all interfaces) so phones on the same WiFi can reach it:

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- API docs (Swagger): **`http://10.216.91.251:8000/docs`** (it's `/docs`, not `/api/v1/docs`).
- From the laptop itself: `http://localhost:8000/docs` also works.

Three conditions for it to work "each time" over the network:

1. **Bind `0.0.0.0`** — not a fixed IP (binding an unassigned IP causes `Errno 99: Cannot assign requested address`).
2. **Same WiFi** for phone + laptop, and the laptop firewall allows inbound `:8000`.
3. **`10.216.91.251` is dynamic** (DHCP) — it can change on reconnect/reboot. If it
   does, run `hostname -I` for the new one and update `ApiConfig.baseUrl` in both
   apps. For a permanent address, set a static IP / DHCP reservation on your router.
