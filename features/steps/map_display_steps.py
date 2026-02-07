"""
Step definitions for Map Display features.
"""

from behave import given, when, then


# Given steps
@given("I am on the welcome page")
def step_on_welcome_page(context):
    """Simulate being on welcome page."""
    context.current_page = "/"
    # Make an actual request to get the response
    context.response = context.client.get("/")


# When steps
@when('I navigate to "{url}"')
def step_navigate_to(context, url):
    """Navigate to a specific URL."""
    context.response = context.client.get(url)


@when("I request the map page")
def step_request_map_page(context):
    """Request the map page."""
    context.response = context.client.get("/mapa/")


@when("I request the welcome page")
def step_request_welcome_page(context):
    """Request the welcome page."""
    context.response = context.client.get("/")


@when('I request "{url}"')
def step_request_url(context, url):
    """Request a specific URL."""
    context.response = context.client.get(url)


# Then steps
@then("I should see the map page")
def step_see_map_page(context):
    """Assert map page is displayed."""
    assert context.response.status_code == 200, (
        f"Expected 200, got {context.response.status_code}"
    )
    content = context.response.content.decode("utf-8")
    assert "map" in content.lower(), "Map page should contain 'map' reference"


@then("the page should have a map container")
def step_has_map_container(context):
    """Assert page has map container element."""
    content = context.response.content.decode("utf-8")
    # Look for common map container patterns
    assert (
        'id="map"' in content
        or 'class="map"' in content
        or "leaflet" in content.lower()
    ), "Page should have a map container element"


@then("the page should load without errors")
def step_loads_without_errors(context):
    """Assert page loaded successfully."""
    assert context.response.status_code == 200, (
        f"Page should load without errors, got status {context.response.status_code}"
    )


@then('the response should contain "{text}" element')
def step_contains_element(context, text):
    """Assert response contains specific text/element."""
    content = context.response.content.decode("utf-8")
    assert text.lower() in content.lower(), f"Response should contain '{text}'"


@then("the response should include Leaflet.js library")
def step_includes_leaflet(context):
    """Assert Leaflet.js is included."""
    content = context.response.content.decode("utf-8")
    assert "leaflet" in content.lower(), "Page should include Leaflet.js library"


@then("I should see a link or button to access the map")
def step_has_map_link(context):
    """Assert page has link to map."""
    content = context.response.content.decode("utf-8")
    # Look for common patterns for map links
    has_link = (
        "mapa" in content.lower() or "map" in content.lower() or "/mapa/" in content
    )
    assert has_link, "Page should have a link to access the map"


@then("the link should direct to the map page")
def step_link_to_map(context):
    """Assert link directs to map page."""
    content = context.response.content.decode("utf-8")
    assert "/mapa/" in content or "/map/" in content, (
        "Link should direct to the map page"
    )


@then("the page should include Leaflet.js for map rendering")
def step_includes_leaflet_for_rendering(context):
    """Assert Leaflet.js is included for rendering."""
    step_includes_leaflet(context)


@then("the page should include custom map initialization code")
def step_includes_map_init(context):
    """Assert page includes map initialization."""
    content = context.response.content.decode("utf-8")
    # Look for JavaScript or script tags
    assert "<script" in content, "Page should include JavaScript"


@then("the page should have a viewport meta tag")
def step_has_viewport_meta(context):
    """Assert page has viewport meta tag."""
    content = context.response.content.decode("utf-8")
    assert "viewport" in content, "Page should have viewport meta tag"


@then("the page should have a charset meta tag")
def step_has_charset_meta(context):
    """Assert page has charset meta tag."""
    content = context.response.content.decode("utf-8")
    assert "charset" in content.lower() or "utf-8" in content.lower(), (
        "Page should have charset meta tag"
    )


@then("the page should have a descriptive title")
def step_has_title(context):
    """Assert page has a title."""
    content = context.response.content.decode("utf-8")
    assert "<title>" in content.lower(), "Page should have a title tag"


@then("the response should be text/plain")
def step_is_text_plain(context):
    """Assert response is text/plain."""
    content_type = context.response.get("Content-Type", "")
    assert "text/plain" in content_type.lower(), (
        f"Response should be text/plain, got {content_type}"
    )


@then("the response should contain robot directives")
def step_contains_robot_directives(context):
    """Assert response contains robot directives."""
    content = context.response.content.decode("utf-8")
    has_directives = (
        "user-agent" in content.lower()
        or "disallow" in content.lower()
        or "allow" in content.lower()
    )
    assert has_directives, "Response should contain robot directives"


@then("the response should contain welcome content")
def step_contains_welcome_content(context):
    """Assert response contains welcome content."""
    content = context.response.content.decode("utf-8")
    # Just check it's not empty and has some meaningful content
    assert len(content) > 100, "Welcome page should have substantial content"


@then("the page should have proper HTML structure")
def step_has_html_structure(context):
    """Assert page has proper HTML structure."""
    content = context.response.content.decode("utf-8")
    assert "<html" in content.lower(), "Page should have <html> tag"
    assert "<head>" in content.lower() or "<head " in content.lower(), (
        "Page should have <head> tag"
    )
    assert "<body" in content.lower(), "Page should have <body> tag"
