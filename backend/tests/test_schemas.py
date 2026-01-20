"""
Test schemas and validate example fixtures
"""
import json
import os
from pathlib import Path
import pytest
from datetime import datetime
from pydantic import ValidationError

from backend.schemas import Event, EventSource, RecCenter, Village


# Get the path to example fixtures
FIXTURES_DIR = Path(__file__).parent.parent.parent / "docs" / "examples"


class TestEventSchema:
    """Test Event schema validation"""

    def test_event_from_example_fixture(self):
        """Test that example_event.json loads and validates correctly"""
        with open(FIXTURES_DIR / "example_event.json", "r") as f:
            event_data = json.load(f)
        
        # Should not raise any validation errors
        event = Event(**event_data)
        
        # Verify key fields
        assert event.id == "550e8400-e29b-41d4-a716-446655440000"
        assert event.title == "Community Yoga Class"
        assert event.location == "Everglades Recreation Center"
        assert event.village == "The Villages"
        assert event.category == "Recreation"
        assert event.source.name == "District Recreation"
        assert isinstance(event.start_time, datetime)
        assert isinstance(event.created_at, datetime)

    def test_event_with_valid_data(self):
        """Test Event model with valid data"""
        event_data = {
            "id": "test-123",
            "title": "Test Event",
            "start_time": "2024-02-01T10:00:00",
            "location": "Test Location",
            "village": "Test Village",
            "category": "Test Category",
            "source": {
                "name": "Test Source",
                "url": "https://example.com"
            },
            "created_at": "2024-01-20T10:00:00",
            "updated_at": "2024-01-20T10:00:00"
        }
        event = Event(**event_data)
        assert event.title == "Test Event"
        assert event.description is None  # Optional field

    def test_event_missing_required_field(self):
        """Test that missing required fields raise ValidationError"""
        event_data = {
            "id": "test-123",
            "title": "Test Event",
            # Missing start_time (required)
            "location": "Test Location",
            "village": "Test Village",
            "category": "Test Category",
            "source": {
                "name": "Test Source",
                "url": "https://example.com"
            },
            "created_at": "2024-01-20T10:00:00",
            "updated_at": "2024-01-20T10:00:00"
        }
        with pytest.raises(ValidationError):
            Event(**event_data)

    def test_event_invalid_datetime(self):
        """Test that invalid datetime format raises ValidationError"""
        event_data = {
            "id": "test-123",
            "title": "Test Event",
            "start_time": "not-a-datetime",  # Invalid datetime
            "location": "Test Location",
            "village": "Test Village",
            "category": "Test Category",
            "source": {
                "name": "Test Source",
                "url": "https://example.com"
            },
            "created_at": "2024-01-20T10:00:00",
            "updated_at": "2024-01-20T10:00:00"
        }
        with pytest.raises(ValidationError):
            Event(**event_data)

    def test_event_source_validation(self):
        """Test EventSource nested model validation"""
        source_data = {
            "name": "Test Source",
            "url": "https://example.com"
        }
        source = EventSource(**source_data)
        assert source.name == "Test Source"
        assert source.url == "https://example.com"

    def test_event_source_missing_field(self):
        """Test that EventSource missing required field raises ValidationError"""
        source_data = {
            "name": "Test Source"
            # Missing url (required)
        }
        with pytest.raises(ValidationError):
            EventSource(**source_data)


class TestRecCenterSchema:
    """Test Recreation Center schema validation"""

    def test_rec_center_from_example_fixture(self):
        """Test that example_rec_center.json loads and validates correctly"""
        with open(FIXTURES_DIR / "example_rec_center.json", "r") as f:
            rec_center_data = json.load(f)
        
        # Should not raise any validation errors
        rec_center = RecCenter(**rec_center_data)
        
        # Verify key fields
        assert rec_center.id == "660e8400-e29b-41d4-a716-446655440001"
        assert rec_center.name == "Everglades Recreation Center"
        assert rec_center.village == "The Villages"
        assert rec_center.latitude == 28.9142
        assert rec_center.longitude == -81.9739
        assert len(rec_center.facilities) == 6
        assert "Pool" in rec_center.facilities
        assert isinstance(rec_center.hours, dict)
        assert isinstance(rec_center.created_at, datetime)

    def test_rec_center_with_valid_data(self):
        """Test RecCenter model with valid data"""
        rec_center_data = {
            "id": "test-rec-123",
            "name": "Test Recreation Center",
            "address": "123 Test St, Test City, FL 12345",
            "village": "Test Village",
            "latitude": 28.5,
            "longitude": -81.5,
            "created_at": "2024-01-20T10:00:00",
            "updated_at": "2024-01-20T10:00:00"
        }
        rec_center = RecCenter(**rec_center_data)
        assert rec_center.name == "Test Recreation Center"
        assert rec_center.phone is None  # Optional field
        assert rec_center.email is None  # Optional field
        assert rec_center.facilities == []  # Default empty list
        assert rec_center.hours == {}  # Default empty dict

    def test_rec_center_missing_required_field(self):
        """Test that missing required fields raise ValidationError"""
        rec_center_data = {
            "id": "test-rec-123",
            "name": "Test Recreation Center",
            "address": "123 Test St",
            # Missing village (required)
            "latitude": 28.5,
            "longitude": -81.5,
            "created_at": "2024-01-20T10:00:00",
            "updated_at": "2024-01-20T10:00:00"
        }
        with pytest.raises(ValidationError):
            RecCenter(**rec_center_data)

    def test_rec_center_invalid_coordinates(self):
        """Test that invalid coordinate types raise ValidationError"""
        rec_center_data = {
            "id": "test-rec-123",
            "name": "Test Recreation Center",
            "address": "123 Test St",
            "village": "Test Village",
            "latitude": "not-a-number",  # Invalid - should be float
            "longitude": -81.5,
            "created_at": "2024-01-20T10:00:00",
            "updated_at": "2024-01-20T10:00:00"
        }
        with pytest.raises(ValidationError):
            RecCenter(**rec_center_data)


class TestVillageSchema:
    """Test Village schema validation"""

    def test_village_from_example_fixture(self):
        """Test that example_village.json loads and validates correctly"""
        with open(FIXTURES_DIR / "example_village.json", "r") as f:
            village_data = json.load(f)
        
        # Should not raise any validation errors
        village = Village(**village_data)
        
        # Verify key fields
        assert village.id == "770e8400-e29b-41d4-a716-446655440002"
        assert village.name == "The Villages"
        assert village.region == "Central Florida"
        assert len(village.zip_codes) == 4
        assert "32159" in village.zip_codes
        assert village.description is not None

    def test_village_with_valid_data(self):
        """Test Village model with valid data"""
        village_data = {
            "id": "test-village-123",
            "name": "Test Village",
            "region": "Test Region",
            "zip_codes": ["12345", "67890"]
        }
        village = Village(**village_data)
        assert village.name == "Test Village"
        assert village.description is None  # Optional field
        assert len(village.zip_codes) == 2

    def test_village_missing_required_field(self):
        """Test that missing required fields raise ValidationError"""
        village_data = {
            "id": "test-village-123",
            "name": "Test Village",
            # Missing region (required)
            "zip_codes": ["12345"]
        }
        with pytest.raises(ValidationError):
            Village(**village_data)

    def test_village_empty_zip_codes(self):
        """Test that Village allows empty zip_codes list"""
        village_data = {
            "id": "test-village-123",
            "name": "Test Village",
            "region": "Test Region",
            "zip_codes": []  # Empty list is valid
        }
        village = Village(**village_data)
        assert village.zip_codes == []

    def test_village_invalid_zip_codes_type(self):
        """Test that invalid zip_codes type raises ValidationError"""
        village_data = {
            "id": "test-village-123",
            "name": "Test Village",
            "region": "Test Region",
            "zip_codes": "12345"  # Should be a list, not a string
        }
        with pytest.raises(ValidationError):
            Village(**village_data)


class TestSchemaIntegration:
    """Integration tests for schemas"""

    def test_all_example_fixtures_exist(self):
        """Test that all required example fixtures exist"""
        assert (FIXTURES_DIR / "example_event.json").exists()
        assert (FIXTURES_DIR / "example_rec_center.json").exists()
        assert (FIXTURES_DIR / "example_village.json").exists()

    def test_all_fixtures_are_valid_json(self):
        """Test that all example fixtures are valid JSON"""
        for fixture_file in ["example_event.json", "example_rec_center.json", "example_village.json"]:
            with open(FIXTURES_DIR / fixture_file, "r") as f:
                data = json.load(f)  # Should not raise JSONDecodeError
                assert isinstance(data, dict)

    def test_schemas_can_be_imported(self):
        """Test that all schemas can be imported from the package"""
        from backend.schemas import Event, EventSource, RecCenter, Village
        assert Event is not None
        assert EventSource is not None
        assert RecCenter is not None
        assert Village is not None
