"""
Middleware for FleetCommand API.

Provides request logging, correlation IDs, security headers, and audit logging.
"""
import json
import logging
import time
import uuid
from typing import Callable

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger(__name__)


class CorrelationIdMiddleware(BaseHTTPMiddleware):
    """Middleware to add correlation ID to requests."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Generate correlation ID if not present
        correlation_id = request.headers.get("X-Correlation-ID", str(uuid.uuid4()))
        request.state.correlation_id = correlation_id

        # Add to response headers
        response = await call_next(request)
        response.headers["X-Correlation-ID"] = correlation_id
        return response


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware to log incoming requests."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        start_time = time.time()

        # Log request
        correlation_id = getattr(request.state, 'correlation_id', 'unknown')
        logger.info(
            f"Request started: {request.method} {request.url.path}",
            extra={
                "correlation_id": correlation_id,
                "method": request.method,
                "path": request.url.path,
                "query": str(request.url.query),
                "user_agent": request.headers.get("User-Agent", ""),
                "ip": request.client.host if request.client else "unknown",
            }
        )

        response = await call_next(request)

        # Log response
        duration = time.time() - start_time
        logger.info(
            f"Request completed: {response.status_code} in {duration:.3f}s",
            extra={
                "correlation_id": correlation_id,
                "status_code": response.status_code,
                "duration": duration,
            }
        )

        return response


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Middleware to add security headers to responses."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        response = await call_next(request)

        # Security headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"

        # Remove server header
        response.headers.pop("Server", None)

        return response


class AuditLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware to log audit events."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # This would integrate with your audit logging system
        # For now, just pass through
        return await call_next(request)
