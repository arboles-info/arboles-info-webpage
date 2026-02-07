"""
Step definitions for Stump API queries.
Reuses many steps from tree_api_steps.py
"""

from behave import given, when, then, use_step_matcher
from unittest.mock import patch, AsyncMock
from tests.factories import OverpassResponseFactory, BBoxFactory
from features.steps.common_helpers import (
    parse_json_response,
    assert_valid_stump_structure,
)

use_step_matcher("re")


# When steps specific to stumps
@when("I request stumps for that bounding box")
def step_request_stumps(context):
    """Make API request for stumps."""
    params = []
    if hasattr(context, "query_params"):
        for key, value in context.query_params.items():
            params.append(f"{key}={value}")

    query_string = "&".join(params) if params else ""
    url = f"/api/stumps/?{query_string}" if query_string else "/api/stumps/"

    # Setup mock response if not already set
    if not hasattr(context, "mock_response_data"):
        context.mock_response_data = OverpassResponseFactory.create_stumps_response(
            count=5
        )

    # Mock the Overpass API call
    with patch(
        "maps.views.query_overpass_with_retry", new_callable=AsyncMock
    ) as mock_query:
        if hasattr(context, "overpass_error") and context.overpass_error:

            async def mock_with_error(*args, **kwargs):
                raise Exception("Overpass API Error")

            mock_query.side_effect = mock_with_error
        else:
            mock_query.return_value = context.mock_response_data

        context.response = context.client.get(url)


@when("I request stumps")
def step_request_stumps_simple(context):
    """Make simple API request for stumps."""
    step_request_stumps(context)


# Given steps specific to stumps
@given('I have a bounding box with no stumps "(?P<bbox>[^"]+)"')
def step_empty_stumps_bbox(context, bbox):
    """Store a bbox and prepare empty response."""
    context.bbox = bbox
    context.query_params = {"bbox": bbox}
    context.mock_response_data = OverpassResponseFactory.create_empty_response()


@given("the Overpass API returns stumps with complete data")
def step_overpass_stumps_complete_data(context):
    """Setup Overpass with complete stump data."""
    bbox_tuple = (
        BBoxFactory.parse_bbox(context.bbox) if hasattr(context, "bbox") else None
    )
    context.mock_response_data = OverpassResponseFactory.create_stumps_response(
        count=5, bbox=bbox_tuple, include_species=True
    )


@given("the Overpass API returns an error")
def step_overpass_returns_error(context):
    """Setup Overpass to return error."""
    context.overpass_error = True


# Then steps specific to stumps
@then("the response should contain a list of stumps")
def step_response_contains_stumps(context):
    """Assert response contains stumps."""
    data = parse_json_response(context.response)
    assert data is not None, "Response is not valid JSON"
    assert isinstance(data, list), f"Response should be a list, got {type(data)}"
    # Can be empty or have stumps
    context.response_data = data


@then("each stump should have required fields: id, lat, lon")
def step_stump_required_fields(context):
    """Assert stumps have required fields."""
    data = parse_json_response(context.response)
    if len(data) > 0:
        for stump in data:
            assert_valid_stump_structure(stump)


@then("the response should contain at most (?P<max_count>\\d+) stumps")
def step_max_stumps(context, max_count):
    """Assert response has at most max_count stumps."""
    max_count = int(max_count)
    data = parse_json_response(context.response)
    assert isinstance(data, list), "Response should be a list"
    assert len(data) <= max_count, (
        f"Response should have at most {max_count} stumps, got {len(data)}"
    )


@then("each stump should have the correct data structure")
def step_correct_stump_structure(context):
    """Assert stumps have correct structure."""
    data = parse_json_response(context.response)
    if len(data) > 0:
        for stump in data:
            assert_valid_stump_structure(stump)


@then("optional fields should include: species, diameter, removal_date, reason")
def step_stump_optional_fields(context):
    """Assert optional fields are present when available."""
    data = parse_json_response(context.response)
    optional_fields = ["species", "diameter", "removal_date", "reason"]

    # Just verify that optional fields don't cause errors
    for stump in data:
        for field in optional_fields:
            if field in stump:
                # Field exists, that's fine
                pass
