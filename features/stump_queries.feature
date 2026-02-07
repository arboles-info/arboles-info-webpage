Feature: Stump Data Queries
  As a developer integrating with the stump API
  I want to query stump (tree remnant) data via the REST API
  So that I can display stumps alongside trees on the interactive map

  Background:
    Given the Overpass API is available and responding

  @critical
  Scenario: Query stumps in a valid bounding box
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    When I request stumps for that bounding box
    Then I should receive a successful response
    And the response should contain a list of stumps
    And each stump should have required fields: id, lat, lon

  @critical
  Scenario: Query stumps with limit parameter
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    And I set the limit parameter to 10
    When I request stumps for that bounding box
    Then I should receive a successful response
    And the response should contain at most 10 stumps

  @critical
  Scenario: Handle missing bbox parameter
    Given I do not provide a bbox parameter
    When I request stumps
    Then I should receive a successful response
    And the response should be an empty list

  Scenario: Handle invalid bbox format gracefully
    Given I have an invalid bounding box "invalid-format"
    When I request stumps for that bounding box
    Then I should receive a successful response
    And the response should be an empty list

  @critical
  Scenario: Automatically limit results for large area
    Given I have a very large bounding box "40.0,-4.0,41.0,-3.0"
    When I request stumps for that bounding box
    Then I should receive a successful response
    And the results should be automatically limited
    And the response should contain at most 1000 stumps

  Scenario: Handle empty result set
    Given I have a bounding box with no stumps "0.0,0.0,0.1,0.1"
    And the Overpass API returns no results
    When I request stumps for that bounding box
    Then I should receive a successful response
    And the response should be an empty list

  Scenario: Verify stump data structure
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    And the Overpass API returns stumps with complete data
    When I request stumps for that bounding box
    Then each stump should have the correct data structure
    And optional fields should include: species, diameter, removal_date, reason

  @slow
  Scenario: Handle Overpass API errors gracefully
    Given the Overpass API returns an error
    And I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    When I request stumps for that bounding box
    Then I should receive a successful response
    And the response should be an empty list

  @critical
  Scenario: Query with custom timeout parameter
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    And I set the timeout parameter to 30
    When I request stumps for that bounding box
    Then the Overpass query should use the custom timeout
    And I should receive a successful response

  Scenario: Maximum limit enforcement
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    And I set the limit parameter to 5000
    When I request stumps for that bounding box
    Then the limit should be capped at 1000
    And the response should contain at most 1000 stumps
