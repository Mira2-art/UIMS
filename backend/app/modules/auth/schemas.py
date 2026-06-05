from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, field_validator


class DeviceInfo(BaseModel):
    device_id: str
    device_name: str
    platform: str  # ios | android | web
    os_version: str | None = None
    app_version: str | None = None


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    first_name: str
    last_name: str
    phone: str | None = None
    client_id: str
    device_info: DeviceInfo

    @field_validator("password")
    @classmethod
    def password_min_length(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v


class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    client_id: str
    device_info: DeviceInfo


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    refresh_token: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

    @field_validator("new_password")
    @classmethod
    def password_min_length(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str

    @field_validator("new_password")
    @classmethod
    def password_min_length(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v


class VerifyEmailConfirm(BaseModel):
    token: str


class UserRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    user_id: UUID
    email: str
    first_name: str
    last_name: str
    phone: str | None
    status: str
    email_verified: bool
    created_at: datetime


class RoleCreate(BaseModel):
    role_name: str
    role_code: str
    description: str | None = None


class RoleRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    role_id: UUID
    role_name: str
    role_code: str
    description: str | None
    is_system: bool


class PermissionCreate(BaseModel):
    permission_name: str
    permission_code: str
    module: str
    description: str | None = None


class PermissionRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    permission_id: UUID
    permission_name: str
    permission_code: str
    module: str
    description: str | None


class AssignPermissionRequest(BaseModel):
    permission_id: UUID


class AssignRoleRequest(BaseModel):
    role_id: UUID


# ── Client App schemas ─────────────────────────────────────────────────────────


class ClientAppCreate(BaseModel):
    name: str
    platform: str
    description: str | None = None


class ClientAppRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    client_app_id: UUID
    client_id: str
    name: str
    platform: str
    description: str | None
    is_active: bool
    created_at: datetime
