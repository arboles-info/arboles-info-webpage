"""
Common step helpers and utilities for BDD tests.
"""

import json
from unittest.mock import patch, AsyncMock
from tests.factories import OverpassResponseFactory


def parse_json_response(response):
    """Parse JSON response from Django test client."""
    try:
        return json.loads(response.content)
    except:
        return None


def setup_mock_overpass(context, response_data, status_code=200, should_timeout=False):
    """
    Setup mock for Overpass API calls.
    Stores the mock in context for later verification.
    """

    async def mock_query(*args, **kwargs):
        if should_timeout:
            raise Exception("Timeout")
        return response_data

    context.mock_overpass_query = mock_query
    context.mock_response_data = response_data


def assert_valid_tree_structure(tree_dict):
    """Assert that a tree dictionary has the required structure."""
    required_fields = ["id", "lat", "lon"]
    for field in required_fields:
        assert field in tree_dict, f"Tree missing required field: {field}"

    # Verify types
    assert isinstance(tree_dict["id"], str), "Tree id must be string"
    assert isinstance(tree_dict["lat"], (int, float)), "Tree lat must be number"
    assert isinstance(tree_dict["lon"], (int, float)), "Tree lon must be number"

    # Optional fields
    optional_fields = ["species", "height", "diameter", "age", "health", "last_updated"]
    for field in optional_fields:
        if field in tree_dict and tree_dict[field] is not None:
            if field in ["height", "diameter"]:
                assert isinstance(tree_dict[field], (int, float)), (
                    f"{field} must be number"
                )
            elif field == "age":
                assert isinstance(tree_dict[field], int), f"{field} must be integer"


def assert_valid_stump_structure(stump_dict):
    """Assert that a stump dictionary has the required structure."""
    required_fields = ["id", "lat", "lon"]
    for field in required_fields:
        assert field in stump_dict, f"Stump missing required field: {field}"

    # Verify types
    assert isinstance(stump_dict["id"], str), "Stump id must be string"
    assert isinstance(stump_dict["lat"], (int, float)), "Stump lat must be number"
    assert isinstance(stump_dict["lon"], (int, float)), "Stump lon must be number"

    # Optional fields
    optional_fields = ["species", "diameter", "removal_date", "reason"]
    for field in optional_fields:
        if field in stump_dict and stump_dict[field] is not None:
            if field == "diameter":
                assert isinstance(stump_dict[field], (int, float)), (
                    f"{field} must be number"
                )


def create_bbox_tuple(bbox_string):
    """Convert bbox string to tuple of floats."""
    try:
        parts = bbox_string.split(",")
        return tuple(float(p.strip()) for p in parts)
    except:
        return None
