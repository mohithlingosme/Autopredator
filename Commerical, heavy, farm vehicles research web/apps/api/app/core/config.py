"""
Configuration settings for FleetCommand API.

Uses Pydantic for validation and type safety.
"""
import os
from typing import List, Optional

from pydantic import BaseSettings, validator


class Settings(BaseSettings):
    """Application settings with validation."""

    # Environment
    APP_ENV: str = "development"
    DEBUG: bool = False

    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    LOG_LEVEL: str = "INFO"

    # Database
    DATABASE_URL: str

    # Redis
    REDIS_URL: str = "redis://localhost:6379"

    # JWT
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # CORS
    CORS_ORIGINS: List[str] = ["http://localhost:3000"]

    # API
    API_V1_PREFIX: str = "/api/v1"
    API_TITLE: str = "FleetCommand API"
    API_DESCRIPTION: str = "Multi-tenant fleet management platform API"
    API_VERSION: str = "1.0.0"

    # Security
    SECRET_KEY: str
    ALLOWED_HOSTS: List[str] = ["*"]

    # Email (optional for local dev)
    SMTP_SERVER: Optional[str] = None
    SMTP_PORT: Optional[int] = None
    SMTP_USERNAME: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None

    class Config:
        env_file = ".env"
        case_sensitive = True

    @validator("CORS_ORIGINS", pre=True)
    def parse_cors_origins(cls, v):
        if isinstance(v, str):
            # Handle comma-separated string
            return [origin.strip() for origin in v.split(",")]
        return v

    @validator("ALLOWED_HOSTS", pre=True)
    def parse_allowed_hosts(cls, v):
        if isinstance(v, str):
            return [host.strip() for host in v.split(",")]
        return v

    @validator("DEBUG")
    def validate_debug(cls, v, values):
        if "APP_ENV" in values and values["APP_ENV"] == "development":
            return True
        return v


# Create settings instance
settings = Settings()
