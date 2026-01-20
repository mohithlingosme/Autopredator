"""
Configuration management for FleetCommand Worker.

Uses Pydantic for validation and type safety.
"""
import secrets
from typing import List, Optional

from pydantic import field_validator, ValidationInfo, Field
from pydantic_settings import BaseSettings


class WorkerSettings(BaseSettings):
    """
    Worker settings with validation.

    All settings can be overridden with environment variables.
    """

    # Application
    APP_ENV: str = Field(default="development", description="Application environment")
    LOG_LEVEL: str = Field(default="INFO", description="Logging level")
    SECRET_KEY: str = Field(
        default_factory=lambda: secrets.token_urlsafe(32),
        description="Secret key for encryption"
    )

    # Database
    DATABASE_URL: str = Field(
        default="postgresql://user:password@localhost/fleetcommand",
        description="PostgreSQL database URL"
    )

    @field_validator("DATABASE_URL")
    @classmethod
    def validate_database_url(cls, v: str) -> str:
        """Validate database URL format."""
        if not v.startswith(("postgresql://", "postgresql+asyncpg://")):
            raise ValueError("Database URL must be a valid PostgreSQL URL")
        return v

    # Redis
    REDIS_URL: str = Field(
        default="redis://localhost:6379",
        description="Redis URL for queues and caching"
    )

    @field_validator("REDIS_URL")
    @classmethod
    def validate_redis_url(cls, v: str) -> str:
        """Validate Redis URL format."""
        if not v.startswith(("redis://", "rediss://", "unix://")):
            raise ValueError("Redis URL must be a valid Redis URL")
        return v

    # Worker Configuration
    WORKER_CONCURRENCY: int = Field(default=4, description="Number of worker processes")
    WORKER_QUEUES: List[str] = Field(
        default=["default", "maintenance", "reports"],
        description="Worker queues to listen on"
    )
    WORKER_MAX_JOBS_PER_WORKER: int = Field(
        default=1000,
        description="Maximum jobs per worker before restart"
    )

    @field_validator("WORKER_CONCURRENCY", "WORKER_MAX_JOBS_PER_WORKER")
    @classmethod
    def validate_positive_int(cls, v: int, info: ValidationInfo) -> int:
        """Validate positive integer values."""
        if v <= 0:
            raise ValueError(f"{info.field_name} must be positive")
        return v

    # Email Configuration
    SMTP_SERVER: Optional[str] = Field(default=None, description="SMTP server")
    SMTP_PORT: Optional[int] = Field(default=587, description="SMTP port")
    SMTP_USERNAME: Optional[str] = Field(default=None, description="SMTP username")
    SMTP_PASSWORD: Optional[str] = Field(default=None, description="SMTP password")

    @field_validator("SMTP_PORT")
    @classmethod
    def validate_smtp_port(cls, v: Optional[int]) -> Optional[int]:
        """Validate SMTP port."""
        if v is not None and (v < 1 or v > 65535):
            raise ValueError("SMTP port must be between 1 and 65535")
        return v

    # AWS Configuration
    AWS_REGION: str = Field(default="us-east-1", description="AWS region")
    AWS_ACCESS_KEY_ID: Optional[str] = Field(default=None, description="AWS access key ID")
    AWS_SECRET_ACCESS_KEY: Optional[str] = Field(default=None, description="AWS secret access key")
    AWS_S3_BUCKET: Optional[str] = Field(default=None, description="S3 bucket name")

    # Monitoring
    SENTRY_DSN: Optional[str] = Field(default=None, description="Sentry DSN")

    @field_validator("SENTRY_DSN")
    @classmethod
    def validate_sentry_dsn(cls, v: Optional[str]) -> Optional[str]:
        """Validate Sentry DSN format."""
        if v is not None and not v.startswith(("http://", "https://")):
            raise ValueError("Sentry DSN must be a valid URL")
        return v

    # Job Scheduling (cron expressions)
    MAINTENANCE_CLEANUP_SCHEDULE: str = Field(
        default="0 2 * * *",
        description="Cron schedule for maintenance cleanup (daily at 2 AM)"
    )
    REPORT_GENERATION_SCHEDULE: str = Field(
        default="0 6 * * 1",
        description="Cron schedule for report generation (weekly Monday at 6 AM)"
    )

    # Job Timeouts
    JOB_TIMEOUT_DEFAULT: int = Field(default=300, description="Default job timeout in seconds")
    JOB_TIMEOUT_MAINTENANCE: int = Field(default=3600, description="Maintenance job timeout in seconds")
    JOB_TIMEOUT_REPORTS: int = Field(default=1800, description="Report job timeout in seconds")

    # Retry Configuration
    JOB_MAX_RETRIES: int = Field(default=3, description="Maximum job retry attempts")
    JOB_RETRY_DELAY: int = Field(default=60, description="Delay between retries in seconds")

    class Config:
        """Pydantic configuration."""
        env_file = ".env"
        case_sensitive = True


# Global settings instance
worker_settings = WorkerSettings()
