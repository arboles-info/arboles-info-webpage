Feature: Interactive Map Display
  As a user interested in urban forestry
  I want to view an interactive map with tree and stump locations
  So that I can explore and learn about trees in different areas

  @critical
  Scenario: Load the main map page
    Given I am on the welcome page
    When I navigate to "/mapa/"
    Then I should see the map page
    And the page should have a map container
    And the page should load without errors

  @critical
  Scenario: Map page loads successfully
    When I request the map page
    Then I should receive a successful response
    And the response should contain "map" element
    And the response should include Leaflet.js library

  Scenario: Welcome page has link to map
    Given I am on the welcome page
    Then I should see a link or button to access the map
    And the link should direct to the map page

  @critical
  Scenario: Map page includes required JavaScript
    When I request the map page
    Then the page should include Leaflet.js for map rendering
    And the page should include custom map initialization code

  Scenario: Map page has proper meta tags
    When I request the map page
    Then the page should have a viewport meta tag
    And the page should have a charset meta tag
    And the page should have a descriptive title

  Scenario: Robots.txt is accessible
    When I request "/robots.txt"
    Then I should receive a successful response
    And the response should be text/plain
    And the response should contain robot directives

  Scenario: Welcome page loads successfully
    When I request the welcome page
    Then I should receive a successful response
    And the response should contain welcome content
    And the page should have proper HTML structure
