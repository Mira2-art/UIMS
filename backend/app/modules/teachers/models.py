from app.db.sis_models import Lecturer

Teacher = Lecturer  # alias to avoid breaking existing imports

__all__ = ["Lecturer", "Teacher"]
