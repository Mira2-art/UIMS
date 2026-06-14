"""Unit tests for the Trustech grading scale + CA/EXAM combination.

Pure functions — no DB required (only the app deps installed).
"""

from decimal import Decimal

from app.modules.grades.service import (
    _compute_letter_grade,
    _grade_points,
    compute_course_grade,
)


def test_letter_bands():
    cases = {
        "100": "A+",
        "96": "A+",
        "95.99": "A",
        "80": "A",
        "79.99": "B+",
        "70": "B+",
        "69.99": "B",
        "60": "B",
        "59.99": "C+",
        "55": "C+",
        "54.99": "C",
        "50": "C",
        "49.99": "D+",
        "45": "D+",
        "44.99": "D",
        "40": "D",
        "39.99": "F",
        "0": "F",
    }
    for total, expected in cases.items():
        assert _compute_letter_grade(Decimal(total)) == expected, total


def test_course_grade_ca_plus_exam():
    # CA 27/30 (weight 30) + EXAM 56/70 (weight 70) = 83.00 -> A
    items = [
        (Decimal("27"), Decimal("30"), Decimal("30")),
        (Decimal("56"), Decimal("70"), Decimal("70")),
    ]
    total, letter = compute_course_grade(items)
    assert total == Decimal("83.00")
    assert letter == "A"


def test_course_grade_split_ca_components():
    # CA as 3x10 (each max 10, weight 10) all full = 30; EXAM 35/70 (weight 70) = 35; total 65 -> B
    items = [
        (Decimal("10"), Decimal("10"), Decimal("10")),
        (Decimal("10"), Decimal("10"), Decimal("10")),
        (Decimal("10"), Decimal("10"), Decimal("10")),
        (Decimal("35"), Decimal("70"), Decimal("70")),
    ]
    total, letter = compute_course_grade(items)
    assert total == Decimal("65.00")
    assert letter == "B"


def test_course_grade_fail():
    items = [
        (Decimal("5"), Decimal("30"), Decimal("30")),
        (Decimal("20"), Decimal("70"), Decimal("70")),
    ]
    total, letter = compute_course_grade(items)
    assert total == Decimal("25.00")
    assert letter == "F"


def test_grade_points_4_scale():
    # 4.0 scale (Cameroon convention).
    assert _grade_points("A+") == Decimal("4.0")
    assert _grade_points("A") == Decimal("4.0")
    assert _grade_points("B+") == Decimal("3.5")
    assert _grade_points("B") == Decimal("3.0")
    assert _grade_points("C") == Decimal("2.0")
    assert _grade_points("D") == Decimal("1.0")
    assert _grade_points("F") == Decimal("0.0")
