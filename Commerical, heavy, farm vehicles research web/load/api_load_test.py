"""
Load testing for general API endpoints.

Uses Locust for distributed load testing.
"""
from locust import HttpUser, task, between
import json


class APIUser(HttpUser):
    """Load testing user for general API endpoints."""

    wait_time = between(1, 3)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.token = None

    def on_start(self):
        """Set up user session with authentication."""
        # Register a new user
        user_data = {
            "email": f"loaduser{self.__class__.user_count}@example.com",
            "password": "testpassword123",
            "first_name": "Load",
            "last_name": "User",
        }

        response = self.client.post("/api/v1/auth/register", json=user_data)
        if response.status_code == 201:
            # Login to get token
            login_data = {
                "username": user_data["email"],
                "password": user_data["password"],
            }
            login_response = self.client.post("/api/v1/auth/login", data=login_data)
            if login_response.status_code == 200:
                self.token = login_response.json()["access_token"]
                self.client.headers.update({"Authorization": f"Bearer {self.token}"})

    @task(3)
    def get_current_user(self):
        """Test getting current user profile."""
        if self.token:
            self.client.get("/api/v1/auth/me")

    @task(2)
    def health_check(self):
        """Test health check endpoint."""
        self.client.get("/health")

    @task(1)
    def refresh_token(self):
        """Test token refresh."""
        if self.token:
            # Get refresh token from login response (would need to store it)
            # For now, just test the endpoint structure
            pass

    @task(1)
    def logout(self):
        """Test logout endpoint."""
        if self.token:
            self.client.post("/api/v1/auth/logout")
            self.token = None
