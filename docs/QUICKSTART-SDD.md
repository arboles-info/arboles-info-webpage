# Quick Start: Specification-Driven Development

## 5-Minute Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. View Existing Specifications
```bash
# List all feature files
ls -la features/*.feature

# Read a feature file
cat features/tree_queries.feature
```

### 3. Run Tests (Once dependencies are installed)
```bash
# Run all BDD tests
make behave

# Run critical tests only
make behave-critical

# Run excluding slow tests
make behave-no-slow
```

## What You Have Now

### 3 Feature Files with 27 Scenarios
- **tree_queries.feature**: 10 scenarios for tree API
- **stump_queries.feature**: 10 scenarios for stump API  
- **map_display.feature**: 7 scenarios for map display

### Complete Test Infrastructure
- Step definitions (75+ steps)
- Test data factories
- Mock Overpass API responses
- Pytest fixtures (15+)
- Configuration files

### Makefile Commands
```bash
make behave              # All BDD tests
make behave-critical     # Critical only
make behave-wip          # Work in progress
make pytest              # Pytest tests
make test-all            # Everything
make test-coverage       # With coverage report
```

## Your First Test Run

```bash
# 1. Install (if you haven't)
pip install -r requirements.txt

# 2. Run critical tests (fast)
make behave-critical

# 3. See detailed output
make behave
```

## Write Your First Feature

### 1. Create Feature File
Create `features/my_feature.feature`:

```gherkin
Feature: My New Feature
  As a user
  I want to do something
  So that I achieve a goal

  @critical
  Scenario: Basic functionality
    Given I have some setup
    When I perform an action
    Then I see the expected result
```

### 2. Run to See Missing Steps
```bash
make behave
```

Behave will show you the missing step definitions to implement.

### 3. Implement Steps
Create `features/steps/my_steps.py`:

```python
from behave import given, when, then

@given('I have some setup')
def step_impl(context):
    context.ready = True

@when('I perform an action')
def step_impl(context):
    context.result = perform_action()

@then('I see the expected result')
def step_impl(context):
    assert context.result == expected
```

### 4. Implement Feature
Write your actual code in `maps/views.py` or wherever appropriate.

### 5. Verify
```bash
make behave
```

## Key Files to Know

- `features/*.feature` - Specifications in Gherkin
- `features/steps/*.py` - Step implementations  
- `tests/factories.py` - Test data generators
- `tests/conftest.py` - Pytest fixtures
- `docs/BDD-GUIDE.md` - Complete documentation

## Common Commands

```bash
# Development
make behave              # Run all BDD tests
make behave-critical     # Critical tests only
make behave-no-slow      # Skip slow tests
make pytest              # Run pytest tests

# Coverage
make test-coverage       # Generate coverage report
# Open htmlcov/index.html to see report

# Specific tags
behave --tags=critical   # Critical scenarios
behave --tags=wip        # Work in progress
behave --tags=-slow      # Exclude slow tests
```

## Example: Testing Tree API

**Feature** (`features/tree_queries.feature`):
```gherkin
@critical
Scenario: Query trees in valid bounding box
  Given I have a valid bounding box "40.4,-3.7,40.5,-3.6"
  When I request trees for that bounding box
  Then I should receive a successful response
  And the response should contain a list of trees
```

**Run it**:
```bash
make behave-critical
```

## Read More

- **Complete Guide**: `docs/BDD-GUIDE.md`
- **Implementation Summary**: `docs/SDD-IMPLEMENTATION-SUMMARY.md`
- **README**: `README.md` (updated with testing section)

## Troubleshooting

### Tests won't run
```bash
pip install -r requirements.txt
```

### Can't find behave
```bash
which behave
# or
pip install behave-django
```

### Import errors
Make sure you're in the project root:
```bash
cd /path/to/arboles-info-maps
export PYTHONPATH=.
```

## Next Steps

1. Read `docs/BDD-GUIDE.md` for comprehensive documentation
2. Explore existing feature files
3. Run tests: `make behave`
4. Write your own feature
5. Implement and test!

---

**You're ready to go!** Start with `make behave` to see it in action.
