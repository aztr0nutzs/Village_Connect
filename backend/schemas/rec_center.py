"""
Recreation Center schema definition using Pydantic
"""
from datetime import datetime
from typing import Optional, Dict, List
from pydantic import BaseModel, Field, ConfigDict


class RecCenter(BaseModel):
    """Canonical Recreation Center model for Village Connect"""
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id": "660e8400-e29b-41d4-a716-446655440001",
                "name": "Everglades Recreation Center",
                "address": "5497 Marsh Bend Trail, The Villages, FL 32163",
                "phone": "(352) 674-1800",
                "email": "info@evergladesrec.org",
                "website": "https://www.districtgov.org/everglades",
                "hours": {
                    "Monday": "8:00 AM - 9:00 PM",
                    "Tuesday": "8:00 AM - 9:00 PM",
                    "Wednesday": "8:00 AM - 9:00 PM",
                    "Thursday": "8:00 AM - 9:00 PM",
                    "Friday": "8:00 AM - 9:00 PM",
                    "Saturday": "8:00 AM - 5:00 PM",
                    "Sunday": "Closed"
                },
                "facilities": [
                    "Pool",
                    "Fitness Center",
                    "Tennis Courts",
                    "Pickleball Courts",
                    "Softball Fields",
                    "Meeting Rooms"
                ],
                "village": "The Villages",
                "latitude": 28.9142,
                "longitude": -81.9739,
                "created_at": "2024-01-20T10:00:00",
                "updated_at": "2024-01-20T10:00:00"
            }
        }
    )
    
    id: str = Field(..., description="Unique identifier for the recreation center")
    name: str = Field(..., description="Recreation center name")
    address: str = Field(..., description="Full street address")
    phone: Optional[str] = Field(None, description="Contact phone number")
    email: Optional[str] = Field(None, description="Contact email address")
    website: Optional[str] = Field(None, description="Website URL")
    hours: Dict[str, str] = Field(
        default_factory=dict,
        description="Operating hours (e.g., {'Monday': '8:00 AM - 9:00 PM'})"
    )
    facilities: List[str] = Field(
        default_factory=list,
        description="List of available facilities (e.g., ['Pool', 'Gym', 'Tennis Courts'])"
    )
    village: str = Field(..., description="Village name")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")
    created_at: datetime = Field(..., description="Timestamp when record was created")
    updated_at: datetime = Field(..., description="Timestamp when record was last updated")

