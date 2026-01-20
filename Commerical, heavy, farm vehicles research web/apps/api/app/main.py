"""
Main FastAPI application for FleetCommand API.

Configures the FastAPI app with routers, middleware, and dependencies.
"""
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse

from app.api.v1.api import api_router
from app.core.config import settings
from app.core.middleware import (
    AuditLoggingMiddleware,
    CorrelationIdMiddleware,
    RequestLoggingMiddleware,
    SecurityHeadersMiddleware,
)
from app.db.base import create_tables


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """
    Application lifespan context manager.

    Handles startup and shutdown events.
    """
    # Startup
    if settings.APP_ENV == "development":
        # Create tables on startup in development
        await create_tables()

    yield

    # Shutdown
    # Add cleanup logic here if needed


app = FastAPI(
    title="FleetCommand API",
    description="Multi-tenant fleet management platform API",
    version="1.0.0",
    openapi_url=f"{settings.API_V1_PREFIX}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# Set up middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=settings.ALLOWED_HOSTS if hasattr(settings, 'ALLOWED_HOSTS') else ["*"],
)

app.add_middleware(AuditLoggingMiddleware)
app.add_middleware(SecurityHeadersMiddleware)

# Add exception handlers
app.add_exception_handler(HTTPException, http_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(SQLAlchemyError, sqlalchemy_exception_handler)
app.add_exception_handler(IntegrityError, integrity_error_handler)
app.add_exception_handler(Exception, generic_exception_handler)


@app.get("/health")
async def health_check() -> dict:
    """Health check endpoint."""
    return {"status": "healthy", "service": "fleetcommand-api"}


@app.get("/ready")
async def readiness_check() -> dict:
    """Readiness check endpoint."""
    # Add database connectivity check here
    from app.db.session import get_db
    try:
        # Simple database connectivity check
        db = next(get_db())
        db.execute("SELECT 1")
        return {"status": "ready", "service": "fleetcommand-api"}
    except Exception:
        return {"status": "not ready", "service": "fleetcommand-api"}


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Global exception handler."""
    # Log the exception
    # You can add more sophisticated error handling here
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )


# Include API routers
app.include_router(
    api_router,
    prefix=settings.API_V1_PREFIX,
)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.APP_ENV == "development",
        log_level=settings.LOG_LEVEL.lower(),
    )
