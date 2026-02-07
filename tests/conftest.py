"""
Pytest configuration and fixtures for testing.
"""

import pytest
import responses as responses_module
from unittest.mock import Mock, patch, AsyncMock
from django.test import Client
from tests.factories import OverpassResponseFactory, BBoxFactory


@pytest.fixture
def client():
    """Django test client fixture."""
    return Client()


@pytest.fixture
def overpass_factory():
    """Overpass response factory fixture."""
    return OverpassResponseFactory()


@pytest.fixture
def bbox_factory():
    """BBox factory fixture."""
    return BBoxFactory()


@pytest.fixture
def mock_overpass_success():
    """Mock a successful Overpass API response."""
    mock_response = OverpassResponseFactory.create_trees_response(count=10)
    return mock_response


@pytest.fixture
def mock_overpass_empty():
    """Mock an empty Overpass API response."""
    return OverpassResponseFactory.create_empty_response()


@pytest.fixture
def mock_overpass_stumps():
    """Mock a successful Overpass API response for stumps."""
    return OverpassResponseFactory.create_stumps_response(count=5)


@pytest.fixture
def valid_bbox():
    """Valid bounding box string."""
    return "40.4,-3.7,40.5,-3.6"


@pytest.fixture
def large_bbox():
    """Large bounding box string."""
    return BBoxFactory.create_large_bbox()


@pytest.fixture
def invalid_bbox():
    """Invalid bounding box string."""
    return BBoxFactory.create_invalid_bbox()


@pytest.fixture
def responses():
    """
    Responses mock fixture for mocking HTTP requests.
    Automatically starts and stops the responses mock.
    """
    with responses_module.RequestsMock() as rsps:
        yield rsps


@pytest.fixture
def mock_overpass_api():
    """
    Mock the Overpass API calls using responses.
    """
    with responses_module.RequestsMock() as rsps:
        # Default successful response
        rsps.add(
            responses_module.POST,
            "https://maps.mail.ru/osm/tools/overpass/api/interpreter",
            json=OverpassResponseFactory.create_trees_response(count=5),
            status=200,
        )
        yield rsps


@pytest.fixture
def mock_overpass_timeout():
    """Mock Overpass API timeout."""
    with responses_module.RequestsMock() as rsps:
        rsps.add(
            responses_module.POST,
            "https://maps.mail.ru/osm/tools/overpass/api/interpreter",
            body=responses_module.ConnectionError("Connection timeout"),
        )
        yield rsps


@pytest.fixture
def mock_overpass_error():
    """Mock Overpass API error response."""
    with responses_module.RequestsMock() as rsps:
        rsps.add(
            responses_module.POST,
            "https://maps.mail.ru/osm/tools/overpass/api/interpreter",
            json={"error": "Internal Server Error"},
            status=500,
        )
        yield rsps


@pytest.fixture
async def async_mock_overpass():
    """
    Mock for async Overpass API calls.
    Returns a context manager that can be used with patch.
    """
    mock = AsyncMock()
    mock.return_value = OverpassResponseFactory.create_trees_response(count=5)
    return mock


@pytest.fixture
def tree_data_sample():
    """Sample tree data in the expected format."""
    return {
        "id": "tree_1234567",
        "lat": 40.4168,
        "lon": -3.7038,
        "species": "Quercus ilex",
        "height": 12.5,
        "diameter": 0.8,
        "age": None,
        "health": "good",
        "last_updated": "2024-02-07T00:00:00",
    }


@pytest.fixture
def stump_data_sample():
    """Sample stump data in the expected format."""
    return {
        "id": "stump_2234567",
        "lat": 40.4200,
        "lon": -3.7050,
        "species": "Pinus pinea",
        "diameter": 0.6,
        "removal_date": "2024-01-15T00:00:00",
        "reason": "Disease",
    }


# Django-specific fixtures
@pytest.fixture(scope="session")
def django_db_setup():
    """
    Setup for Django database tests.
    This is called once per test session.
    """
    pass


@pytest.fixture
def db_with_cleanup(db):
    """
    Database fixture that ensures cleanup after each test.
    """
    yield db
    # Cleanup code here if needed
