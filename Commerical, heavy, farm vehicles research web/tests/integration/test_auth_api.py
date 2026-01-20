"""
Integration tests for authentication API endpoints.
"""
import pytest
from httpx import AsyncClient

from apps.api.app.core.config import settings


class TestAuthEndpoints:
    """Test authentication API endpoints."""

    @pytest.mark.asyncio
    async def test_register_user_success(self, client: AsyncClient):
        """Test successful user registration."""
        user_data = {
            "email": "test@example.com",
            "password": "testpassword123",
            "first_name": "Test",
            "last_name": "User",
        }

        response = await client.post("/api/v1/auth/register", json=user_data)

        assert response.status_code == 201
        data = response.json()
        assert "id" in data
        assert data["email"] == user_data["email"]
        assert data["first_name"] == user_data["first_name"]
        assert data["last_name"] == user_data["last_name"]

    @pytest.mark.asyncio
    async def test_register_user_duplicate_email(self, client: AsyncClient):
        """Test registration with duplicate email."""
        user_data = {
            "email": "duplicate@example.com",
            "password": "testpassword123",
        }

        # First registration
        response1 = await client.post("/api/v1/auth/register", json=user_data)
        assert response1.status_code == 201

        # Second registration with same email
        response2 = await client.post("/api/v1/auth/register", json=user_data)
        assert response2.status_code == 400
        assert "already exists" in response2.json()["detail"]

    @pytest.mark.asyncio
    async def test_login_success(self, client: AsyncClient):
        """Test successful login."""
        # First register a user
        user_data = {
            "email": "login@example.com",
            "password": "testpassword123",
        }
        await client.post("/api/v1/auth/register", json=user_data)

        # Then login
        login_data = {
            "username": user_data["email"],
            "password": user_data["password"],
        }
        response = await client.post("/api/v1/auth/login", data=login_data)

        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"
        assert "expires_in" in data

    @pytest.mark.asyncio
    async def test_login_invalid_credentials(self, client: AsyncClient):
        """Test login with invalid credentials."""
        login_data = {
            "username": "nonexistent@example.com",
            "password": "wrongpassword",
        }
        response = await client.post("/api/v1/auth/login", data=login_data)

        assert response.status_code == 401
        assert "Incorrect email or password" in response.json()["detail"]

    @pytest.mark.asyncio
    async def test_refresh_token_success(self, client: AsyncClient):
        """Test successful token refresh."""
        # Register and login first
        user_data = {
            "email": "refresh@example.com",
            "password": "testpassword123",
        }
        await client.post("/api/v1/auth/register", json=user_data)

        login_data = {
            "username": user_data["email"],
            "password": user_data["password"],
        }
        login_response = await client.post("/api/v1/auth/login", data=login_data)
        refresh_token = login_response.json()["refresh_token"]

        # Refresh token
        refresh_data = {"refresh_token": refresh_token}
        response = await client.post("/api/v1/auth/refresh", json=refresh_data)

        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"

    @pytest.mark.asyncio
    async def test_refresh_token_invalid(self, client: AsyncClient):
        """Test refresh with invalid token."""
        refresh_data = {"refresh_token": "invalid.refresh.token"}
        response = await client.post("/api/v1/auth/refresh", json=refresh_data)

        assert response.status_code == 401
        assert "Invalid refresh token" in response.json()["detail"]

    @pytest.mark.asyncio
    async def test_get_current_user_authenticated(self, client: AsyncClient):
        """Test getting current user when authenticated."""
        # Register and login first
        user_data = {
            "email": "current@example.com",
            "password": "testpassword123",
            "first_name": "Current",
            "last_name": "User",
        }
        await client.post("/api/v1/auth/register", json=user_data)

        login_data = {
            "username": user_data["email"],
            "password": user_data["password"],
        }
        login_response = await client.post("/api/v1/auth/login", data=login_data)
        access_token = login_response.json()["access_token"]

        # Get current user
        headers = {"Authorization": f"Bearer {access_token}"}
        response = await client.get("/api/v1/auth/me", headers=headers)

        assert response.status_code == 200
        data = response.json()
        assert data["email"] == user_data["email"]
        assert data["first_name"] == user_data["first_name"]
        assert data["last_name"] == user_data["last_name"]
        assert "organizations" in data

    @pytest.mark.asyncio
    async def test_get_current_user_unauthenticated(self, client: AsyncClient):
        """Test getting current user when not authenticated."""
        response = await client.get("/api/v1/auth/me")

        assert response.status_code == 401
        assert "Not authenticated" in response.json()["detail"]

    @pytest.mark.asyncio
    async def test_logout(self, client: AsyncClient):
        """Test user logout."""
        # Register and login first
        user_data = {
            "email": "logout@example.com",
            "password": "testpassword123",
        }
        await client.post("/api/v1/auth/register", json=user_data)

        login_data = {
            "username": user_data["email"],
            "password": user_data["password"],
        }
        login_response = await client.post("/api/v1/auth/login", data=login_data)
        access_token = login_response.json()["access_token"]

        # Logout
        headers = {"Authorization": f"Bearer {access_token}"}
        response = await client.post("/api/v1/auth/logout", headers=headers)

        assert response.status_code == 200
        assert "Successfully logged out" in response.json()["message"]
