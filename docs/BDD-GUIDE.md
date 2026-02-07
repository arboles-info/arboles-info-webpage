# BDD (Behavior-Driven Development) Guide

## Introduction

This project uses **Behavior-Driven Development (BDD)** with **Behave** to specify and test functionality through human-readable scenarios written in Gherkin syntax.

## What is BDD?

BDD is a software development approach where:
- **Specifications drive development**: You write what the system should do before implementing it
- **Living documentation**: Tests serve as up-to-date documentation
- **Collaboration**: Non-technical stakeholders can read and contribute to specifications
- **Outside-in development**: Start from user perspective, work inward to implementation

## Tools We Use

- **behave**: Python BDD framework (like Cucumber for Ruby)
- **pytest**: Modern Python testing framework
- **factory-boy**: Test data factories
- **responses**: HTTP request mocking

## Directory Structure

```
arboles-info-maps/
├── features/                    # BDD specifications
│   ├── steps/                   # Step implementations
│   │   ├── __init__.py
│   │   ├── common_helpers.py    # Shared helpers
│   │   ├── tree_api_steps.py    # Tree API steps
│   │   ├── stump_api_steps.py   # Stump API steps
│   │   └── map_display_steps.py # Map display steps
│   ├── environment.py           # Behave hooks
│   ├── tree_queries.feature     # Tree API specs
│   ├── stump_queries.feature    # Stump API specs
│   └── map_display.feature      # Map display specs
├── tests/                       # Additional pytest tests
│   ├── conftest.py              # Pytest fixtures
│   └── factories.py             # Test data factories
├── behave.ini                   # Behave configuration
└── pytest.ini                   # Pytest configuration
```

## Writing Feature Files

Feature files use Gherkin syntax with keywords:
- **Feature**: High-level description
- **Background**: Setup for all scenarios
- **Scenario**: Single test case
- **Given**: Preconditions
- **When**: Action
- **Then**: Expected outcome
- **And**: Additional step

### Example Feature

```gherkin
Feature: Tree Data Queries
  As a developer
  I want to query tree data via API
  So that I can display trees on the map

  Background:
    Given the Overpass API is available and responding

  @critical
  Scenario: Query trees in a valid bounding box
    Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
    When I request trees for that bounding box
    Then I should receive a successful response
    And the response should contain a list of trees
    And each tree should have required fields: id, lat, lon
```

## Running Tests

### Run all BDD tests
```bash
make behave
```

### Run critical tests only
```bash
make behave-critical
```

### Run tests excluding slow ones
```bash
make behave-no-slow
```

### Run work-in-progress tests
```bash
make behave-wip
```

### Run pytest tests
```bash
make pytest
```

### Run all tests (Django + BDD + pytest)
```bash
make test-all
```

### Run with coverage
```bash
make test-coverage
```

## Scenario Tags

Use tags to organize and filter tests:

- `@critical`: Core functionality that must always work
- `@slow`: Tests that take significant time
- `@wip`: Work in progress, under development
- `@integration`: Integration tests

### Examples
```gherkin
@critical @slow
Scenario: Handle large dataset

@wip
Scenario: Future feature being developed
```

## Writing Step Definitions

Step definitions connect Gherkin steps to Python code.

### Location
Put step definitions in `features/steps/`:
- `tree_api_steps.py`: Tree API steps
- `stump_api_steps.py`: Stump API steps
- `map_display_steps.py`: Map page steps

### Example Step Definition

```python
from behave import given, when, then

@given('I have a valid bounding box "{bbox}"')
def step_valid_bbox(context, bbox):
    """Store bbox in context."""
    context.bbox = bbox
    context.query_params = {'bbox': bbox}

@when('I request trees for that bounding box')
def step_request_trees(context):
    """Make API request."""
    url = f"/api/trees/?bbox={context.bbox}"
    context.response = context.client.get(url)

@then('I should receive a successful response')
def step_successful_response(context):
    """Assert 200 status."""
    assert context.response.status_code == 200
```

## Context Object

The `context` object passes data between steps:

```python
# Set data
context.bbox = "40.4,-3.7,40.5,-3.6"
context.response = client.get("/api/trees/")

# Access data
if context.response.status_code == 200:
    # ...
```

## Test Data Factories

Use factories in `tests/factories.py` to generate test data:

```python
from tests.factories import OverpassResponseFactory, BBoxFactory

# Create mock Overpass response with 10 trees
response = OverpassResponseFactory.create_trees_response(count=10)

# Create valid bounding box
bbox = BBoxFactory.create_valid_bbox()

# Create large bounding box
large_bbox = BBoxFactory.create_large_bbox()
```

## Mocking External APIs

Use `unittest.mock` to mock Overpass API:

```python
from unittest.mock import patch, AsyncMock

@when('I request trees')
def step_request_trees(context):
    with patch('maps.views.query_overpass_with_retry', new_callable=AsyncMock) as mock_query:
        mock_query.return_value = context.mock_response_data
        context.response = context.client.get('/api/trees/?bbox=...')
```

## BDD Workflow

### 1. Write Specification (Red)
Create `.feature` file describing desired behavior:
```gherkin
Scenario: New feature
  Given some precondition
  When I perform an action
  Then I see the expected result
```

### 2. Run Tests (See Failure)
```bash
make behave
```
Tests fail because steps aren't implemented.

### 3. Implement Steps
Create step definitions in `features/steps/`:
```python
@given('some precondition')
def step_impl(context):
    # Setup
    pass
```

### 4. Implement Feature
Write actual application code in `maps/views.py`, etc.

### 5. Run Tests (Green)
```bash
make behave
```
Tests pass!

### 6. Refactor
Improve code while keeping tests green.

## Best Practices

### Do:
- Write specifications before code
- Use descriptive scenario names
- Keep scenarios focused (one behavior per scenario)
- Use Background for common setup
- Tag scenarios appropriately
- Keep step definitions DRY (Don't Repeat Yourself)
- Mock external dependencies (Overpass API)

### Don't:
- Write implementation details in Gherkin
- Make scenarios interdependent
- Use technical jargon in feature files
- Test multiple things in one scenario
- Hard-code test data (use factories)

## Example: Adding a New Feature

### 1. Create Feature File
`features/my_new_feature.feature`:
```gherkin
Feature: My New Feature
  As a user
  I want to do something
  So that I achieve a goal

  Scenario: Basic usage
    Given I am prepared
    When I do the thing
    Then I see the result
```

### 2. Run to See Missing Steps
```bash
make behave
```
Output shows missing step definitions.

### 3. Implement Steps
`features/steps/my_steps.py`:
```python
from behave import given, when, then

@given('I am prepared')
def step_impl(context):
    context.ready = True

@when('I do the thing')
def step_impl(context):
    context.result = do_something()

@then('I see the result')
def step_impl(context):
    assert context.result is not None
```

### 4. Implement Feature
Write actual code in your Django app.

### 5. Verify
```bash
make behave
```

## Continuous Integration

Tests run automatically on every push via GitHub Actions.

See `.github/workflows/tests.yml` for CI configuration.

## Troubleshooting

### Tests won't run
```bash
# Install dependencies
pip install -r requirements.txt

# Check setup
make check-deps
```

### Import errors
```bash
# Ensure you're in project root
cd /path/to/arboles-info-maps

# Check PYTHONPATH
export PYTHONPATH=.
```

### Mock not working
Verify you're patching the correct path:
```python
# Patch where it's used, not where it's defined
patch('maps.views.query_overpass')  # ✓ Correct
patch('maps.overpass_api.query')     # ✗ Wrong
```

## Resources

- [Behave Documentation](https://behave.readthedocs.io/)
- [Gherkin Reference](https://cucumber.io/docs/gherkin/reference/)
- [pytest Documentation](https://docs.pytest.org/)
- [BDD Best Practices](https://cucumber.io/docs/bdd/)

## Next Steps

1. Read existing feature files in `features/`
2. Run tests: `make behave`
3. Try writing a new scenario
4. Implement the steps
5. Make it pass!

Happy testing!
