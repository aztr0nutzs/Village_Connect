"""
Recreation Center schema for Village Connect.
"""

from typing import List, Optional

from pydantic import BaseModel, Field


class RecCenter(BaseModel):
    """Schema for recreation centers in The Villages."""

    id: str = Field(..., description="Unique identifier for the recreation center")
    name: str = Field(..., description="Name of the recreation center")
    address: Optional[str] = Field(
        None, description="Street address of the recreation center"
    )
    village_id: Optional[str] = Field(
        None, description="Reference to the village this center belongs to"
    )
    phone: Optional[str] = Field(
        None, description="Phone number for the recreation center"
    )
    email: Optional[str] = Field(
        None, description="Email address for the recreation center"
    )
    website: Optional[str] = Field(
        None, description="Website URL for the recreation center"
    )
    amenities: Optional[List[str]] = Field(
        None,
        description="List of amenities available (e.g., pool, tennis courts, gym)",
    )
    hours_of_operation: Optional[str] = Field(
        None, description="Operating hours description"
    )
    latitude: Optional[float] = Field(
        None, description="Latitude coordinate for map display"
    )
    longitude: Optional[float] = Field(
        None, description="Longitude coordinate for map display"
    )

    model_config = {"extra": "forbid"}
