"""
Authentication endpoints for FleetCommand API.

Provides JWT-based authentication with refresh tokens.
"""
import uuid
from datetime import timedelta
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    get_password_hash,
    verify_password,
    verify_token,
)
from app.db.base import get_db
from app.models import User
from app.schemas.auth import (
    RefreshTokenRequest,
    TokenResponse,
    UserLogin,
    UserRegister,
    UserResponse,
    UserWithOrgsResponse,
)

router = APIRouter()

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register_user(
    user_data: UserRegister,
    db: AsyncSession = Depends(get_db),
) -> Any:
    """
    Register a new user.

    Creates a new user account with the provided information.
    """
    # Check if user already exists
    existing_user = await db.execute(
        db.query(User).filter(User.email == user_data.email)
    )
    if existing_user.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this email already exists",
        )

    # Create new user
    hashed_password = get_password_hash(user_data.password)
    user = User(
        email=user_data.email,
        password_hash=hashed_password,
        first_name=user_data.first_name,
        last_name=user_data.last_name,
    )

    db.add(user)
    await db.commit()
    await db.refresh(user)

    return UserResponse.from_orm(user)


@router.post("/login", response_model=TokenResponse)
async def login_user(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db),
) -> Any:
    """
    Authenticate user and return JWT tokens.

    Validates user credentials and returns access and refresh tokens.
    """
    # Find user by email
    user = await db.execute(
        db.query(User).filter(User.email == form_data.username)
    )
    user = user.scalar_one_or_none()

    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is not active",
        )

    # Create tokens
    access_token = create_access_token(
        data={"sub": str(user.id), "type": "access"}
    )
    refresh_token = create_refresh_token(
        data={"sub": str(user.id), "type": "refresh"}
    )

    # Update last login
    user.last_login_at = db.func.now()
    await db.commit()

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh_access_token(
    token_data: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db),
) -> Any:
    """
    Refresh access token using refresh token.

    Validates refresh token and returns new access and refresh tokens.
    """
    # Verify refresh token
    payload = verify_token(token_data.refresh_token, token_type="refresh")
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    # Get user
    user = await db.get(User, uuid.UUID(user_id))
    if not user or user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )

    # Create new tokens
    access_token = create_access_token(
        data={"sub": str(user.id), "type": "access"}
    )
    refresh_token = create_refresh_token(
        data={"sub": str(user.id), "type": "refresh"}
    )

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


@router.post("/logout")
async def logout_user(
    token: str = Depends(oauth2_scheme),
) -> Any:
    """
    Logout user by invalidating tokens.

    Note: In a production system, you would typically add tokens to a blacklist.
    For now, this is a placeholder that just returns success.
    """
    # TODO: Implement token blacklisting
    return {"message": "Successfully logged out"}


@router.get("/me", response_model=UserWithOrgsResponse)
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> Any:
    """
    Get current authenticated user information.

    Returns user details along with their organization memberships.
    """
    # Verify token and get user
    payload = verify_token(token, token_type="access")
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token",
        )

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token",
        )

    # Get user with organization memberships
    user = await db.execute(
        db.query(User).filter(User.id == uuid.UUID(user_id))
    )
    user = user.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Get user's organizations
    org_memberships = []
    for membership in user.org_memberships:
        if membership.status == "active":
            org_memberships.append({
                "org_id": str(membership.org_id),
                "org_name": membership.org.name,
                "role": membership.role,
                "joined_at": membership.joined_at.isoformat() if membership.joined_at else None,
            })

    user_response = UserWithOrgsResponse.from_orm(user)
    user_response.organizations = org_memberships

    return user_response
