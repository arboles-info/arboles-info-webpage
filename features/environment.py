"""
Behave environment configuration for BDD tests.

This module sets up and tears down the test environment for each scenario.
"""

import os
import django
from django.conf import settings
from django.test.utils import setup_test_environment, teardown_test_environment


def before_all(context):
    """
    Setup before all tests run.
    Configure Django settings and test environment.
    """
    # Set Django settings module
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "arboles_info_project.settings")

    # Setup Django
    django.setup()

    # Setup test environment
    setup_test_environment()

    # Store test configuration in context
    context.config.setup_logging()


def before_feature(context, feature):
    """
    Setup before each feature.
    """
    # Add feature-specific setup here if needed
    pass


def before_scenario(context, scenario):
    """
    Setup before each scenario.
    Initialize test client and mock data.
    """
    from django.test import Client

    # Create Django test client
    context.client = Client()

    # Initialize mock responses storage
    context.mock_responses = {}

    # Initialize scenario data storage
    context.scenario_data = {}

    # Tag-based setup
    if "slow" in scenario.effective_tags:
        # Setup for slow tests
        context.timeout = 120
    else:
        context.timeout = 30


def after_scenario(context, scenario):
    """
    Cleanup after each scenario.
    """
    # Clear scenario data
    if hasattr(context, "scenario_data"):
        context.scenario_data.clear()

    if hasattr(context, "mock_responses"):
        context.mock_responses.clear()


def after_feature(context, feature):
    """
    Cleanup after each feature.
    """
    pass


def after_all(context):
    """
    Cleanup after all tests.
    """
    teardown_test_environment()
