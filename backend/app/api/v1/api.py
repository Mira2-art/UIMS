from fastapi import APIRouter

from app.api.v1.health import router as health_router
from app.modules.academic_structure.router import router as academic_structure_router
from app.modules.administration.router import router as administration_router
from app.modules.attendance.router import router as attendance_router
from app.modules.auth.router import router as auth_router
from app.modules.communication.router import router as communication_router
from app.modules.courses.router import router as courses_router
from app.modules.enrollments.router import router as enrollments_router
from app.modules.finance.router import router as finance_router
from app.modules.grades.router import router as grades_router
from app.modules.students.router import router as students_router
from app.modules.teachers.router import router as teachers_router
from app.modules.users.router import router as users_router

api_router = APIRouter()

api_router.include_router(health_router, tags=["health"])
api_router.include_router(auth_router, prefix="/auth", tags=["auth"])
api_router.include_router(users_router, prefix="/users", tags=["users"])
api_router.include_router(students_router, prefix="/students", tags=["students"])
api_router.include_router(teachers_router, prefix="/teachers", tags=["teachers"])
api_router.include_router(courses_router, prefix="/courses", tags=["courses"])
api_router.include_router(enrollments_router, prefix="/enrollments", tags=["enrollments"])
api_router.include_router(grades_router, prefix="/grades", tags=["grades"])
api_router.include_router(attendance_router, prefix="/attendance", tags=["attendance"])
api_router.include_router(
    academic_structure_router, prefix="/academic-structure", tags=["academic-structure"]
)
api_router.include_router(finance_router, prefix="/finance", tags=["finance"])
api_router.include_router(communication_router, prefix="/communication", tags=["communication"])
api_router.include_router(administration_router, prefix="/administration", tags=["administration"])
