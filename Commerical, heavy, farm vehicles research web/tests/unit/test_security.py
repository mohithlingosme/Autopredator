"""
Unit tests for security utilities.
"""
import pytest
from datetime import timedelta

from apps.api.app.core.security import (
    create_access_token,
    create_refresh_token,
    verify_token,
    verify_password,
    get_password_hash,
)


class TestPasswordHashing:
    """Test password hashing and verification."""

    def test_get_password_hash(self):
        """Test password hashing."""
        password = "testpassword123"
        hashed = get_password_hash(password)

        assert hashed != password
        assert len(hashed) > 0

    def test_verify_password_correct(self):
        """Test password verification with correct password."""
        password = "testpassword123"
        hashed = get_password_hash(password)

        assert verify_password(password, hashed) is True

    def test_verify_password_incorrect(self):
        """Test password verification with incorrect password."""
        password = "testpassword123"
        wrong_password = "wrongpassword"
        hashed = get_password_hash(password)

        assert verify_password(wrong_password, hashed) is False


class TestJWTokens:
    """Test JWT token creation and verification."""

    def test_create_access_token(self):
        """Test access token creation."""
        subject = "test_user_id"
        token = create_access_token(subject)

        assert isinstance(token, str)
        assert len(token) > 0

    def test_create_access_token_with_expiry(self):
        """Test access token creation with custom expiry."""
        subject = "test_user_id"
        expires_delta = timedelta(minutes=30)
        token = create_access_token(subject, expires_delta)

        assert isinstance(token, str)
        assert len(token) > 0

    def test_create_refresh_token(self):
        """Test refresh token creation."""
        subject = "test_user_id"
        token = create_refresh_token(subject)

        assert isinstance(token, str)
        assert len(token) > 0

    def test_verify_token_valid(self):
        """Test token verification with valid token."""
        subject = "test_user_id"
        token = create_access_token(subject)
        decoded_subject = verify_token(token)

        assert decoded_subject == subject

    def test_verify_token_invalid(self):
        """Test token verification with invalid token."""
        invalid_token = "invalid.jwt.token"
        decoded_subject = verify_token(invalid_token)

        assert decoded_subject is None

    def test_verify_token_expired(self):
        """Test token verification with expired token."""
        subject = "test_user_id"
        # Create token that expires immediately
        expires_delta = timedelta(seconds=-1)
        token = create_access_token(subject, expires_delta)
        decoded_subject = verify_token(token)

        assert decoded_subject is None
