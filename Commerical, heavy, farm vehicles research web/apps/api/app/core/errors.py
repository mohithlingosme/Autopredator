"""
Error handlers for FleetCommand API.

Provides centralized error handling and response formatting.
"""
from typing import Any, Dict

from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import ValidationError
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

from app.core.config import settings


def format_error_response(
    status_code: int,
    message: str,
    error_code: str | None = None,
    details: Dict[str, Any] | None = None,
) -> Dict[str, Any]:
    """
    Format error response.

    Args:
        status_code: HTTP status code
        message: Human-readable error message
        error_code: Machine-readable error code
        details: Additional error details

    Returns:
        Formatted error response
    """
    response = {
        "error": {
            "message": message,
            "status_code": status_code,
        }
    }

    if error_code:
        response["error"]["code"] = error_code

    if details:
        response["error"]["details"] = details

    if settings.APP_ENV == "development":
        # Add stack trace in development
        import traceback
        response["error"]["traceback"] = traceback.format_exc()

    return response


async def http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """Handle HTTP exceptions."""
    return JSONResponse(
        status_code=exc.status_code,
        content=format_error_response(
            status_code=exc.status_code,
            message=exc.detail,
            error_code="HTTP_EXCEPTION",
        ),
    )


async def validation_exception_handler(request: Request, exc: ValidationError) -> JSONResponse:
    """Handle Pydantic validation errors."""
    return JSONResponse(
        status_code=422,
        content=format_error_response(
            status_code=422,
            message="Validation error",
            error_code="VALIDATION_ERROR",
            details={"errors": exc.errors()},
        ),
    )


async def sqlalchemy_exception_handler(request: Request, exc: SQLAlchemyError) -> JSONResponse:
    """Handle SQLAlchemy exceptions."""
    # Log the error for debugging
    if settings.APP_ENV == "development":
        print(f"SQLAlchemy error: {exc}")

    # Don't expose internal database errors in production
    message = "Database error occurred"
    if settings.APP_ENV == "development":
        message = str(exc)

    return JSONResponse(
        status_code=500,
        content=format_error_response(
            status_code=500,
            message=message,
            error_code="DATABASE_ERROR",
        ),
    )


async def integrity_error_handler(request: Request, exc: IntegrityError) -> JSONResponse:
    """Handle database integrity constraint violations."""
    # Check for specific constraint violations
    error_message = "Data integrity constraint violated"

    if "unique constraint" in str(exc).lower():
        error_message = "Unique constraint violated"
    elif "foreign key constraint" in str(exc).lower():
        error_message = "Foreign key constraint violated"
    elif "check constraint" in str(exc).lower():
        error_message = "Check constraint violated"

    return JSONResponse(
        status_code=400,
        content=format_error_response(
            status_code=400,
            message=error_message,
            error_code="INTEGRITY_ERROR",
        ),
    )


async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Handle unexpected exceptions."""
    # Log the error
    print(f"Unexpected error: {exc}")

    return JSONResponse(
        status_code=500,
        content=format_error_response(
            status_code=500,
            message="Internal server error",
            error_code="INTERNAL_ERROR",
        ),
    )
