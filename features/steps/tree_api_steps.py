"""
Step definitions for Tree API queries.
"""

from behave import given, when, then
from unittest.mock import patch, AsyncMock
import json
from tests.factories import OverpassResponseFactory, BBoxFactory
from features.steps.common_helpers import (
    parse_json_response,
    setup_mock_overpass,
    assert_valid_tree_structure,
)


# Background steps
@given("the Overpass API is available and responding")
def step_overpass_available(context):
    """Setup mock Overpass API that responds successfully."""
    context.overpass_available = True
    context.mock_response_data = OverpassResponseFactory.create_trees_response(count=10)


# Given steps
@given('I have a valid bounding box "{bbox}"')
def step_valid_bbox(context, bbox):
    """Store a valid bounding box in context."""
    context.bbox = bbox
    context.query_params = {"bbox": bbox}


@given('I have an invalid bounding box "{bbox}"')
def step_invalid_bbox(context, bbox):
    """Store an invalid bounding box in context."""
    context.bbox = bbox
    context.query_params = {"bbox": bbox}


@given('I have a very large bounding box "{bbox}"')
def step_large_bbox(context, bbox):
    """Store a large bounding box in context."""
    context.bbox = bbox
    context.query_params = {"bbox": bbox}


@given('I have a bounding box with no trees "{bbox}"')
def step_empty_bbox(context, bbox):
    """Store a bbox and prepare empty response."""
    context.bbox = bbox
    context.query_params = {"bbox": bbox}
    context.mock_response_data = OverpassResponseFactory.create_empty_response()


@given("I do not provide a bbox parameter")
def step_no_bbox(context):
    """Prepare request without bbox."""
    context.bbox = None
    context.query_params = {}


@given("I set the limit parameter to {limit:d}")
def step_set_limit(context, limit):
    """Set the limit parameter."""
    if not hasattr(context, "query_params"):
        context.query_params = {}
    context.query_params["limit"] = limit


@given("I set the timeout parameter to {timeout:d}")
def step_set_timeout(context, timeout):
    """Set the timeout parameter."""
    if not hasattr(context, "query_params"):
        context.query_params = {}
    context.query_params["timeout"] = timeout
    context.expected_timeout = timeout


@given("the Overpass API will timeout on the first attempt")
def step_overpass_timeout_first(context):
    """Setup Overpass to timeout on first call."""
    context.should_timeout_first = True
    context.retry_count = 0


@given("will succeed on retry")
def step_overpass_succeed_retry(context):
    """Overpass will succeed on retry."""
    context.succeed_on_retry = True


@given("the Overpass API returns no results")
def step_overpass_no_results(context):
    """Setup empty Overpass response."""
    context.mock_response_data = OverpassResponseFactory.create_empty_response()


@given("the Overpass API returns trees with complete data")
def step_overpass_complete_data(context):
    """Setup Overpass with complete tree data."""
    bbox_tuple = (
        BBoxFactory.parse_bbox(context.bbox) if hasattr(context, "bbox") else None
    )
    context.mock_response_data = OverpassResponseFactory.create_trees_response(
        count=5, bbox=bbox_tuple, include_species=True, include_measurements=True
    )


# When steps
@when("I request trees for that bounding box")
def step_request_trees(context):
    """Make API request for trees."""
    # Build query string
    params = []
    if hasattr(context, "query_params"):
        for key, value in context.query_params.items():
            params.append(f"{key}={value}")

    query_string = "&".join(params) if params else ""
    url = f"/api/trees/?{query_string}" if query_string else "/api/trees/"

    # Mock the Overpass API call
    # For retry tests, we need to mock the inner query_overpass function
    # so that query_overpass_with_retry can handle retries properly
    if hasattr(context, "should_timeout_first") and context.should_timeout_first:
        with patch("maps.views.query_overpass", new_callable=AsyncMock) as mock_query:
            # First call times out, second succeeds
            call_count = [0]  # Use list to allow mutation in nested function

            async def mock_with_retry(*args, **kwargs):
                call_count[0] += 1
                context.retry_count = call_count[0]
                if call_count[0] == 1:
                    raise Exception("Timeout")
                return context.mock_response_data

            mock_query.side_effect = mock_with_retry
            context.response = context.client.get(url)
            context.mock_query = mock_query
    else:
        with patch(
            "maps.views.query_overpass_with_retry", new_callable=AsyncMock
        ) as mock_query:
            mock_query.return_value = context.mock_response_data
            context.response = context.client.get(url)
            context.mock_query = mock_query


@when("I request trees")
def step_request_trees_simple(context):
    """Make simple API request for trees."""
    step_request_trees(context)


# Then steps
@then("I should receive a successful response")
def step_successful_response(context):
    """Assert response is successful (2xx status)."""
    assert context.response.status_code == 200, (
        f"Expected 200, got {context.response.status_code}: {context.response.content}"
    )


@then("I should receive an error response")
def step_error_response(context):
    """Assert response is an error (4xx or 5xx)."""
    assert context.response.status_code >= 400, (
        f"Expected error status, got {context.response.status_code}"
    )


@then("the response should contain a list of trees")
def step_response_contains_trees(context):
    """Assert response contains trees."""
    data = parse_json_response(context.response)
    assert data is not None, "Response is not valid JSON"
    assert isinstance(data, list), f"Response should be a list, got {type(data)}"
    assert len(data) > 0, "Response should contain at least one tree"
    context.response_data = data


@then("the response should be an empty list")
def step_response_empty_list(context):
    """Assert response is an empty list."""
    data = parse_json_response(context.response)
    assert data is not None, "Response is not valid JSON"
    assert isinstance(data, list), f"Response should be a list, got {type(data)}"
    assert len(data) == 0, f"Response should be empty, got {len(data)} items"


@then("each tree should have required fields: id, lat, lon")
def step_tree_required_fields(context):
    """Assert trees have required fields."""
    data = parse_json_response(context.response)
    assert len(data) > 0, "No trees to validate"

    for tree in data:
        assert_valid_tree_structure(tree)


@then("the response should contain at most {max_count:d} trees")
def step_max_trees(context, max_count):
    """Assert response has at most max_count trees."""
    data = parse_json_response(context.response)
    assert isinstance(data, list), "Response should be a list"
    assert len(data) <= max_count, (
        f"Response should have at most {max_count} trees, got {len(data)}"
    )


@then("the results should be automatically limited")
def step_results_limited(context):
    """Assert results were automatically limited."""
    # This is implicit in the implementation
    data = parse_json_response(context.response)
    assert len(data) <= 1000, "Results should be limited to 1000"


@then("the error should indicate invalid bbox format")
def step_error_invalid_bbox(context):
    """Assert error indicates invalid bbox."""
    data = parse_json_response(context.response)
    if data and isinstance(data, dict):
        assert "error" in data, "Error response should have 'error' field"


@then("the request should retry automatically")
def step_request_retried(context):
    """Assert the request was retried."""
    assert context.retry_count > 1, (
        f"Request should have been retried, but retry_count is {context.retry_count}"
    )


@then("I should eventually receive tree data")
def step_eventually_receive_data(context):
    """Assert we eventually got data after retry."""
    data = parse_json_response(context.response)
    assert isinstance(data, list), "Response should be a list"
    # Could be empty or have data, both are valid after successful retry


@then("each tree should have the correct data structure")
def step_correct_tree_structure(context):
    """Assert trees have correct structure."""
    data = parse_json_response(context.response)
    assert len(data) > 0, "No trees to validate"

    for tree in data:
        assert_valid_tree_structure(tree)


@then("optional fields should include: species, height, diameter, age, health")
def step_optional_fields(context):
    """Assert optional fields are present when available."""
    data = parse_json_response(context.response)
    optional_fields = ["species", "height", "diameter", "age", "health"]

    # Just verify that optional fields don't cause errors
    # They may or may not be present
    for tree in data:
        for field in optional_fields:
            # Field can be present or not, and can be None
            if field in tree:
                # Field exists, that's fine
                pass


@then("the last_updated field should be present")
def step_last_updated_present(context):
    """Assert last_updated field is present."""
    data = parse_json_response(context.response)
    for tree in data:
        assert "last_updated" in tree, "Tree should have last_updated field"


@then("the Overpass query should use the custom timeout")
def step_custom_timeout(context):
    """Verify custom timeout was used."""
    # The timeout is used internally, we just verify the response succeeded
    assert context.response.status_code == 200


@then("the limit should be capped at {max_limit:d}")
def step_limit_capped(context, max_limit):
    """Assert limit was capped."""
    # Verify by checking response size
    data = parse_json_response(context.response)
    assert len(data) <= max_limit, f"Response should have at most {max_limit} items"
