Feature: Tree Data Queries
  As a developer integrating with the tree API
  I want to query tree data via the REST API
  So that I can display trees on the interactive map

  Background:
    Given the Overpass API is available and responding

  @critical
  Scenario: Query trees in a valid bounding box
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    When I request trees for that bounding box
    Then I should receive a successful response
    And the response should contain a list of trees
    And each tree should have required fields: id, lat, lon

  @critical
  Scenario: Query trees with limit parameter
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    And I set the limit parameter to 10
    When I request trees for that bounding box
    Then I should receive a successful response
    And the response should contain at most 10 trees

  @critical
  Scenario: Handle missing bbox parameter
    Given I do not provide a bbox parameter
    When I request trees
    Then I should receive a successful response
    And the response should be an empty list

  Scenario: Handle invalid bbox format
    Given I have an invalid bounding box "invalid-format"
    When I request trees for that bounding box
    Then I should receive an error response
    And the error should indicate invalid bbox format

  @critical
  Scenario: Automatically limit results for large area
    Given I have a very large bounding box "40.0,-4.0,41.0,-3.0"
    When I request trees for that bounding box
    Then I should receive a successful response
    And the results should be automatically limited
    And the response should contain at most 1000 trees

  @slow
  Scenario: Handle Overpass API timeout with retry
    Given the Overpass API will timeout on the first attempt
    But will succeed on retry
    And I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    When I request trees for that bounding box
    Then the request should retry automatically
    And I should eventually receive tree data

  Scenario: Handle empty result set
    Given I have a bounding box with no trees "0.0,0.0,0.1,0.1"
    And the Overpass API returns no results
    When I request trees for that bounding box
    Then I should receive a successful response
    And the response should be an empty list

  Scenario: Verify tree data structure
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    And the Overpass API returns trees with complete data
    When I request trees for that bounding box
    Then each tree should have the correct data structure
    And optional fields should include: species, height, diameter, age, health
    And the last_updated field should be present

  @critical
  Scenario: Query with custom timeout parameter
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    And I set the timeout parameter to 30
    When I request trees for that bounding box
    Then the Overpass query should use the custom timeout
    And I should receive a successful response

  Scenario: Maximum limit enforcement
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    And I set the limit parameter to 5000
    When I request trees for that bounding box
    Then the limit should be capped at 1000
    And the response should contain at most 1000 trees
