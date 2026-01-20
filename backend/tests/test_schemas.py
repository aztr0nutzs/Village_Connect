"""
Tests to validate that JSON fixtures match the canonical schemas.
"""

import json
from pathlib import Path

import pytest

from schemas import Event, RecCenter, Village

# Base path for the project
PROJECT_ROOT = Path(__file__).parent.parent.parent


class TestEventSchema:
    """Tests for Event schema validation."""

    def test_event_fixture_validates(self):
        """Test that the event.json fixture validates against Event schema."""
        fixture_path = PROJECT_ROOT / "docs" / "examples" / "event.json"
        with open(fixture_path) as f:
            event_data = json.load(f)

        event = Event(**event_data)

        assert event.id == "evt-001"
        assert event.title == "Community Pickleball Tournament"
        assert event.category == "sports"
        assert event.is_recurring is False
        assert event.registration_required is True

    def test_event_required_fields(self):
        """Test that Event schema enforces required fields."""
        with pytest.raises(Exception):
            Event()  # Missing required fields

    def test_event_minimal_valid(self):
        """Test Event with only required fields."""
        event = Event(
            id="test-001",
            title="Test Event",
            start_time="2024-01-01T10:00:00Z",
        )
        assert event.id == "test-001"
        assert event.title == "Test Event"


class TestRecCenterSchema:
    """Tests for RecCenter schema validation."""

    def test_rec_center_fixture_validates(self):
        """Test that rec_center.json fixture validates against RecCenter schema."""
        fixture_path = PROJECT_ROOT / "docs" / "examples" / "rec_center.json"
        with open(fixture_path) as f:
            rec_center_data = json.load(f)

        rec_center = RecCenter(**rec_center_data)

        assert rec_center.id == "rc-001"
        assert rec_center.name == "Mulberry Grove Recreation Center"
        assert "Swimming Pool" in rec_center.amenities
        assert rec_center.latitude == 28.9001
        assert rec_center.longitude == -81.9750

    def test_rec_center_required_fields(self):
        """Test that RecCenter schema enforces required fields."""
        with pytest.raises(Exception):
            RecCenter()  # Missing required fields

    def test_rec_center_minimal_valid(self):
        """Test RecCenter with only required fields."""
        rec_center = RecCenter(
            id="test-rc-001",
            name="Test Recreation Center",
        )
        assert rec_center.id == "test-rc-001"
        assert rec_center.name == "Test Recreation Center"


class TestVillageSchema:
    """Tests for Village schema validation."""

    def test_village_fixture_validates(self):
        """Test that village.json fixture validates against Village schema."""
        fixture_path = PROJECT_ROOT / "docs" / "examples" / "village.json"
        with open(fixture_path) as f:
            village_data = json.load(f)

        village = Village(**village_data)

        assert village.id == "vil-001"
        assert village.name == "Mulberry Grove"
        assert village.district == "District 5"
        assert village.region == "Central"
        assert village.established_year == 2005
        assert "Recreation Center" in village.featured_amenities

    def test_village_required_fields(self):
        """Test that Village schema enforces required fields."""
        with pytest.raises(Exception):
            Village()  # Missing required fields

    def test_village_minimal_valid(self):
        """Test Village with only required fields."""
        village = Village(
            id="test-vil-001",
            name="Test Village",
        )
        assert village.id == "test-vil-001"
        assert village.name == "Test Village"


class TestAllFixturesValid:
    """Integration test to verify all fixtures load without errors."""

    def test_load_all_fixtures(self):
        """Test that all JSON fixtures in docs/examples/ can be loaded."""
        examples_dir = PROJECT_ROOT / "docs" / "examples"
        schema_map = {
            "event.json": Event,
            "rec_center.json": RecCenter,
            "village.json": Village,
        }

        for filename, schema in schema_map.items():
            fixture_path = examples_dir / filename
            assert fixture_path.exists(), f"Missing fixture: {filename}"

            with open(fixture_path) as f:
                data = json.load(f)

            instance = schema(**data)
            assert instance is not None, f"Failed to create {schema.__name__}"
