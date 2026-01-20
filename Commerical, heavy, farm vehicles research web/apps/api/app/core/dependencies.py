"""
Dependencies for FleetCommand API.

Provides authentication and authorization dependencies.
"""
import uuid
from typing import Optional

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import verify_token
from app.db.base import get_db
from app.models import User, UserOrgMembership

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Get current authenticated user.

    Args:
        token: JWT access token
        db: Database session

    Returns:
        Authenticated user

    Raises:
        HTTPException: If token is invalid or user not found
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    # Verify token
    payload = verify_token(token, token_type="access")
    if not payload:
        raise credentials_exception

    user_id = payload.get("sub")
    if not user_id:
        raise credentials_exception

    # Get user from database
    user = await db.get(User, uuid.UUID(user_id))
    if not user:
        raise credentials_exception

    if user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is not active",
        )

    return user


async def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """
    Get current active user.

    Args:
        current_user: Authenticated user

    Returns:
        Active user

    Raises:
        HTTPException: If user is not active
    """
    if current_user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is not active",
        )
    return current_user


def require_org_access(
    required_roles: Optional[list[str]] = None,
    allow_all_orgs: bool = False,
):
    """
    Dependency factory for organization access control.

    Args:
        required_roles: List of required roles (e.g., ["Admin", "Manager"])
        allow_all_orgs: If True, user can access any organization

    Returns:
        Dependency function
    """
    async def org_access_dependency(
        request: Request,
        current_user: User = Depends(get_current_active_user),
        db: AsyncSession = Depends(get_db),
    ) -> dict:
        """
        Check organization access and role permissions.

        Returns:
            Dict with user, org_id, and membership info
        """
        # Get org_id from header or request
        org_id = request.headers.get("X-Org-Id")
        if not org_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="X-Org-Id header is required",
            )

        try:
            org_uuid = uuid.UUID(org_id)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid X-Org-Id format",
            )

        # Check if user is member of the organization
        membership = await db.execute(
            db.query(UserOrgMembership).filter(
                UserOrgMembership.user_id == current_user.id,
                UserOrgMembership.org_id == org_uuid,
                UserOrgMembership.status == "active",
            )
        )
        membership = membership.scalar_one_or_none()

        if not membership:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied: not a member of this organization",
            )

        # Check role permissions if required
        if required_roles and membership.role not in required_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied: required role {required_roles}, got {membership.role}",
            )

        return {
            "user": current_user,
            "org_id": org_uuid,
            "membership": membership,
        }

    return org_access_dependency


# Convenience dependencies for common role requirements
require_admin = require_org_access(required_roles=["Admin"])
require_manager_or_above = require_org_access(required_roles=["Admin", "Manager"])
require_operator_or_above = require_org_access(required_roles=["Admin", "Manager", "Operator"])
require_any_active_member = require_org_access()


async def get_request_metadata(request: Request) -> dict:
    """
    Extract request metadata for logging and audit.

    Args:
        request: FastAPI request object

    Returns:
        Dict with request metadata
    """
    return {
        "ip_address": request.client.host if request.client else None,
        "user_agent": request.headers.get("user-agent"),
        "method": request.method,
        "url": str(request.url),
    }
