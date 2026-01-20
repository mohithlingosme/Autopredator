"""
Authentication schemas for FleetCommand API.

Pydantic models for authentication requests and responses.
"""
from typing import Optional

from pydantic import BaseModel, EmailStr, Field, validator


class UserRegister(BaseModel):
    """Schema for user registration."""

    email: EmailStr = Field(..., description="User email address")
    password: str = Field(..., min_length=8, description="User password")
    first_name: Optional[str] = Field(None, max_length=100, description="User first name")
    last_name: Optional[str] = Field(None, max_length=100, description="User last name")
    org_name: Optional[str] = Field(None, max_length=255, description="Organization name (for new org creation)")

    @validator("password")
    def validate_password_strength(cls, v):
        """Validate password strength."""
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters long")
        if not any(char.isdigit() for char in v):
            raise ValueError("Password must contain at least one digit")
        if not any(char.isupper() for char in v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not any(char.islower() for char in v):
            raise ValueError("Password must contain at least one lowercase letter")
        return v


class UserLogin(BaseModel):
    """Schema for user login."""

    email: EmailStr = Field(..., description="User email address")
    password: str = Field(..., description="User password")


class TokenResponse(BaseModel):
    """Schema for token response."""

    access_token: str = Field(..., description="JWT access token")
    refresh_token: str = Field(..., description="JWT refresh token")
    token_type: str = Field(default="bearer", description="Token type")
    expires_in: int = Field(..., description="Token expiration time in seconds")


class RefreshTokenRequest(BaseModel):
    """Schema for refresh token request."""

    refresh_token: str = Field(..., description="Refresh token")


class UserResponse(BaseModel):
    """Schema for user response."""

    id: str = Field(..., description="User ID")
    email: EmailStr = Field(..., description="User email address")
    first_name: Optional[str] = Field(None, description="User first name")
    last_name: Optional[str] = Field(None, description="User last name")
    status: str = Field(..., description="User status")
    email_verified: bool = Field(..., description="Email verification status")
    created_at: str = Field(..., description="User creation timestamp")

    class Config:
        """Pydantic configuration."""
        from_attributes = True


class UserWithOrgsResponse(UserResponse):
    """Schema for user response with organization memberships."""

    organizations: list[dict] = Field(default_factory=list, description="User's organization memberships")

    class Config:
        """Pydantic configuration."""
        from_attributes = True
