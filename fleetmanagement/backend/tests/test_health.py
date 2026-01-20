import pytest
from fastapi.testclient import TestClient
from main import app  # Adjust import if app factory differs

client = TestClient(app)

@pytest.mark.unit
def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert "status" in response.json()
