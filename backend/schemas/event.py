"""
Event schema definition using Pydantic
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict


class EventSource(BaseModel):
    """Source information for an event"""
    name: str = Field(..., description="Name of the data source")
    url: str = Field(..., description="URL to the event source")


class Event(BaseModel):
    """Canonical Event model for Village Connect"""
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id": "550e8400-e29b-41d4-a716-446655440000",
                "title": "Community Yoga Class",
                "description": "Join us for a relaxing yoga session suitable for all levels",
                "start_time": "2024-02-01T09:00:00",
                "end_time": "2024-02-01T10:30:00",
                "location": "Everglades Recreation Center",
                "address": "5497 Marsh Bend Trail, The Villages, FL 32163",
                "village": "The Villages",
                "category": "Recreation",
                "source": {
                    "name": "District Recreation",
                    "url": "https://www.districtgov.org/events"
                },
                "created_at": "2024-01-20T10:00:00",
                "updated_at": "2024-01-20T10:00:00"
            }
        }
    )
    
    id: str = Field(..., description="Unique identifier for the event")
    title: str = Field(..., description="Event title")
    description: Optional[str] = Field(None, description="Detailed event description")
    start_time: datetime = Field(..., description="Event start date and time")
    end_time: Optional[datetime] = Field(None, description="Event end date and time")
    location: str = Field(..., description="Location name or venue")
    address: Optional[str] = Field(None, description="Full street address")
    village: str = Field(..., description="Village name (e.g., 'The Villages')")
    category: str = Field(..., description="Event category (e.g., 'Recreation', 'Social', 'Sports')")
    source: EventSource = Field(..., description="Source information")
    created_at: datetime = Field(..., description="Timestamp when record was created")
    updated_at: datetime = Field(..., description="Timestamp when record was last updated")

