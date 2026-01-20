"""
Pytest configuration and fixtures for FleetCommand tests.
"""
import asyncio
import uuid
from typing import AsyncGenerator, Dict, Any

import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from apps.api.app.core.config import settings
from apps.api.app.core.security import get_password_hash
from apps.api.app.db.base import Base
from apps.api.app.main import app
from apps.api.app.models import Org, User, UserOrgMembership


# Test database URL
TEST_DATABASE_URL = "postgresql+asyncpg://postgres:password@localhost:5432/fleetcommand_test"


@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
async def test_db_engine():
    """Create test database engine."""
    # Create test database engine
    engine = create_async_engine(TEST_DATABASE_URL, echo=False)

    # Create all tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    # Drop all tables after tests
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()


@pytest.fixture
async def db_session(test_db_engine) -> AsyncGenerator[AsyncSession, None]:
    """Create database session for tests."""
    async_session = sessionmaker(test_db_engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        yield session
        await session.rollback()


@pytest.fixture
async def client() -> AsyncGenerator[AsyncClient, None]:
    """Create HTTP client for API tests."""
    async with AsyncClient(app=app, base_url="http://testserver") as client:
        yield client


@pytest.fixture
async def test_org(db_session: AsyncSession) -> Org:
    """Create test organization."""
    org = Org(
        id=uuid.uuid4(),
        name="Test Organization",
        status="active",
    )
    db_session.add(org)
    await db_session.commit()
    await db_session.refresh(org)
    return org


@pytest.fixture
async def test_user(db_session: AsyncSession, test_org: Org) -> Dict[str, Any]:
    """Create test user with organization membership."""
    user = User(
        id=uuid.uuid4(),
        email="test@example.com",
        password_hash=get_password_hash("testpassword"),
        first_name="Test",
        last_name="User",
        status="active",
        email_verified=True,
    )
    db_session.add(user)

    # Create membership
    membership = UserOrgMembership(
        user_id=user.id,
        org_id=test_org.id,
        role="Admin",
        status="active",
    )
    db_session.add(membership)

    await db_session.commit()
    await db_session.refresh(user)

    return {
        "id": str(user.id),
        "email": user.email,
        "password": "testpassword",
        "first_name": user.first_name,
        "last_name": user.last_name,
        "org_id": str(test_org.id),
        "role": membership.role,
    }


@pytest.fixture
async def test_user_token(client: AsyncClient, test_user: Dict[str, Any]) -> str:
    """Get access token for test user."""
    login_data = {
        "username": test_user["email"],
        "password": test_user["password"],
    }
    response = await client.post("/api/v1/auth/login", data=login_data)
    return response.json()["access_token"]


@pytest.fixture
async def authenticated_client(client: AsyncClient, test_user_token: str) -> AsyncClient:
    """Create authenticated HTTP client."""
    client.headers.update({"Authorization": f"Bearer {test_user_token}"})
    return client


# Playwright fixtures for E2E tests
@pytest.fixture(scope="session")
def browser_context_args(browser_context_args):
    """Configure browser context for E2E tests."""
    return {
        **browser_context_args,
        "viewport": {
            "width": 1280,
            "height": 720,
        }
    }


@pytest.fixture
def test_user_e2e():
    """Test user data for E2E tests."""
    return {
        "email": "e2e@example.com",
        "password": "e2epassword123",
        "first_name": "E2E",
        "last_name": "Test",
    }
