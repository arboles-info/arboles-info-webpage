"""
Test data factories for generating realistic test data.
Uses factory_boy for creating test fixtures.
"""

from datetime import datetime
from typing import Dict, List
import factory
from faker import Faker

fake = Faker()


class OverpassResponseFactory:
    """Factory for creating mock Overpass API responses."""

    @staticmethod
    def create_tree_element(
        tree_id: int = None,
        lat: float = None,
        lon: float = None,
        species: str = None,
        height: float = None,
        diameter: float = None,
        age: int = None,
        health: str = None,
    ) -> Dict:
        """Create a single tree element in OSM format."""
        if tree_id is None:
            tree_id = fake.random_int(min=1000000, max=9999999)
        if lat is None:
            lat = fake.latitude()
        if lon is None:
            lon = fake.longitude()

        element = {
            "type": "node",
            "id": tree_id,
            "lat": lat,
            "lon": lon,
            "tags": {"natural": "tree"},
        }

        # Add optional tags
        if species:
            element["tags"]["species"] = species
        if height:
            element["tags"]["height"] = str(height)
        if diameter:
            element["tags"]["diameter"] = str(diameter)
        if age:
            element["tags"]["age"] = age
        if health:
            element["tags"]["health"] = health

        return element

    @staticmethod
    def create_stump_element(
        stump_id: int = None,
        lat: float = None,
        lon: float = None,
        species: str = None,
        diameter: float = None,
        removal_reason: str = None,
    ) -> Dict:
        """Create a single stump element in OSM format."""
        if stump_id is None:
            stump_id = fake.random_int(min=1000000, max=9999999)
        if lat is None:
            lat = fake.latitude()
        if lon is None:
            lon = fake.longitude()

        element = {
            "type": "node",
            "id": stump_id,
            "lat": lat,
            "lon": lon,
            "tags": {"natural": "tree_stump"},
        }

        # Add optional tags
        if species:
            element["tags"]["species"] = species
        if diameter:
            element["tags"]["diameter"] = str(diameter)
        if removal_reason:
            element["tags"]["removal_reason"] = removal_reason

        return element

    @classmethod
    def create_trees_response(
        cls,
        count: int = 5,
        bbox: tuple = None,
        include_species: bool = True,
        include_measurements: bool = False,
    ) -> Dict:
        """Create a complete Overpass API response with multiple trees."""
        elements = []

        # Use bbox if provided, otherwise use random coordinates
        if bbox:
            min_lat, min_lon, max_lat, max_lon = bbox
        else:
            min_lat, min_lon, max_lat, max_lon = 40.4, -3.7, 40.5, -3.6

        for i in range(count):
            lat = fake.pyfloat(min_value=min_lat, max_value=max_lat, right_digits=6)
            lon = fake.pyfloat(min_value=min_lon, max_value=max_lon, right_digits=6)

            species = (
                fake.random_element(
                    [
                        "Quercus ilex",
                        "Pinus pinea",
                        "Platanus × hispanica",
                        "Acer negundo",
                        "Robinia pseudoacacia",
                    ]
                )
                if include_species
                else None
            )

            height = (
                fake.pyfloat(min_value=3.0, max_value=25.0, right_digits=1)
                if include_measurements
                else None
            )
            diameter = (
                fake.pyfloat(min_value=0.2, max_value=1.5, right_digits=2)
                if include_measurements
                else None
            )

            elements.append(
                cls.create_tree_element(
                    tree_id=1000000 + i,
                    lat=lat,
                    lon=lon,
                    species=species,
                    height=height,
                    diameter=diameter,
                )
            )

        return {"version": 0.6, "generator": "Mock Overpass API", "elements": elements}

    @classmethod
    def create_stumps_response(
        cls, count: int = 3, bbox: tuple = None, include_species: bool = True
    ) -> Dict:
        """Create a complete Overpass API response with multiple stumps."""
        elements = []

        # Use bbox if provided, otherwise use random coordinates
        if bbox:
            min_lat, min_lon, max_lat, max_lon = bbox
        else:
            min_lat, min_lon, max_lat, max_lon = 40.4, -3.7, 40.5, -3.6

        for i in range(count):
            lat = fake.pyfloat(min_value=min_lat, max_value=max_lat, right_digits=6)
            lon = fake.pyfloat(min_value=min_lon, max_value=max_lon, right_digits=6)

            species = (
                fake.random_element(
                    ["Quercus ilex", "Pinus pinea", "Platanus × hispanica"]
                )
                if include_species
                else None
            )

            elements.append(
                cls.create_stump_element(
                    stump_id=2000000 + i,
                    lat=lat,
                    lon=lon,
                    species=species,
                    diameter=fake.pyfloat(min_value=0.2, max_value=1.2, right_digits=2),
                )
            )

        return {"version": 0.6, "generator": "Mock Overpass API", "elements": elements}

    @staticmethod
    def create_empty_response() -> Dict:
        """Create an empty Overpass API response."""
        return {"version": 0.6, "generator": "Mock Overpass API", "elements": []}

    @staticmethod
    def create_error_response(
        status_code: int = 500, message: str = "Internal Server Error"
    ) -> Dict:
        """Create an error response."""
        return {"error": message, "status": status_code}


class BBoxFactory:
    """Factory for creating bounding box test data."""

    @staticmethod
    def create_valid_bbox(
        center_lat: float = 40.45, center_lon: float = -3.65, size: float = 0.1
    ) -> str:
        """Create a valid bounding box string."""
        half_size = size / 2
        min_lat = center_lat - half_size
        min_lon = center_lon - half_size
        max_lat = center_lat + half_size
        max_lon = center_lon + half_size
        return f"{min_lat},{min_lon},{max_lat},{max_lon}"

    @staticmethod
    def create_large_bbox() -> str:
        """Create a large bounding box (> 0.01 area)."""
        return "40.0,-4.0,41.0,-3.0"

    @staticmethod
    def create_small_bbox() -> str:
        """Create a small bounding box."""
        return "40.45,-3.65,40.46,-3.64"

    @staticmethod
    def create_invalid_bbox() -> str:
        """Create an invalid bounding box string."""
        return "invalid-format"

    @staticmethod
    def parse_bbox(bbox_string: str) -> tuple:
        """Parse bbox string into tuple."""
        try:
            parts = bbox_string.split(",")
            return tuple(float(p) for p in parts)
        except:
            return None
