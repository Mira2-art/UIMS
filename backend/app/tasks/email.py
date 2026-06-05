"""
Background email tasks via Celery.

Run the worker with:
    cd backend && source env/bin/activate
    celery -A app.core.celery_app worker --loglevel=info --queues=email

All tasks use Gmail SMTP with TLS (port 587).
Set GMAIL_FROM and GMAIL_APP_PASSWORD in .env before enabling.
Set EMAIL_ENABLED=true to actually send (false = log only, useful in dev).
"""

from __future__ import annotations

import logging
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from app.core.celery_app import celery_app
from app.core.config import settings
from app.core.templates import render_template

logger = logging.getLogger(__name__)


def _send_smtp(to: str, subject: str, html_body: str, text_body: str | None = None) -> None:
    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = settings.gmail_from
    msg["To"] = to
    if text_body:
        msg.attach(MIMEText(text_body, "plain"))
    msg.attach(MIMEText(html_body, "html"))

    with smtplib.SMTP(settings.smtp_host, settings.smtp_port) as server:
        server.ehlo()
        server.starttls()
        server.ehlo()
        server.login(settings.gmail_from, settings.gmail_app_password)
        server.sendmail(settings.gmail_from, to, msg.as_string())


@celery_app.task(
    bind=True,
    name="email.send",
    queue="email",
    max_retries=3,
    default_retry_delay=60,
    autoretry_for=(Exception,),
    retry_backoff=True,
)
def send_email_task(
    self,
    to: str,
    subject: str,
    html_body: str,
    text_body: str | None = None,
) -> dict[str, str]:
    if not settings.email_enabled:
        logger.info("[EMAIL DISABLED] Would send to=%s subject=%s", to, subject)
        return {"status": "skipped", "reason": "email_disabled"}

    try:
        _send_smtp(to, subject, html_body, text_body)
        logger.info("Email sent to=%s subject=%s", to, subject)
        return {"status": "sent", "to": to}
    except Exception as exc:
        logger.error("Email failed to=%s error=%s", to, exc)
        raise self.retry(exc=exc) from exc


# ── Pre-built email helpers ────────────────────────────────────────────────────


def send_welcome_email(to: str, first_name: str) -> None:
    html = render_template("email/welcome.html", first_name=first_name)
    text = render_template("email/welcome.txt", first_name=first_name)
    send_email_task.apply_async(
        args=[to, "Welcome to Trustech SIS", html, text],
        queue="email",
    )


def send_verification_email(to: str, first_name: str, token: str) -> None:
    html = render_template("email/verify_email.html", first_name=first_name, token=token)
    text = render_template("email/verify_email.txt", first_name=first_name, token=token)
    send_email_task.apply_async(
        args=[to, "Trustech — Verify your email", html, text],
        queue="email",
    )


def send_password_reset_email(to: str, first_name: str, raw_token: str) -> None:
    html = render_template("email/password_reset.html", first_name=first_name, token=raw_token)
    text = render_template("email/password_reset.txt", first_name=first_name, token=raw_token)
    send_email_task.apply_async(
        args=[to, "Trustech — Password Reset", html, text],
        queue="email",
    )


def send_grade_published_email(
    to: str, first_name: str, course_code: str, letter_grade: str
) -> None:
    html = render_template(
        "email/grade_published.html",
        first_name=first_name,
        course_code=course_code,
        letter_grade=letter_grade,
    )
    text = render_template(
        "email/grade_published.txt",
        first_name=first_name,
        course_code=course_code,
        letter_grade=letter_grade,
    )
    send_email_task.apply_async(
        args=[to, f"Grade Posted — {course_code}", html, text],
        queue="email",
    )


def send_fee_reminder_email(
    to: str, first_name: str, outstanding_amount: str, due_date: str
) -> None:
    html = render_template(
        "email/fee_reminder.html",
        first_name=first_name,
        outstanding_amount=outstanding_amount,
        due_date=due_date,
    )
    text = render_template(
        "email/fee_reminder.txt",
        first_name=first_name,
        outstanding_amount=outstanding_amount,
        due_date=due_date,
    )
    send_email_task.apply_async(
        args=[to, "Trustech — Fee Payment Reminder", html, text],
        queue="email",
    )
