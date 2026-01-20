"""
Event schema for community events in Village Connect.
"""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class Event(BaseModel):
    """Schema for community events."""

    id: str = Field(..., description="Unique identifier for the event")
    title: str = Field(..., description="Title of the event")
    description: Optional[str] = Field(
        None, description="Detailed description of the event"
    )
    start_time: datetime = Field(..., description="Event start date and time")
    end_time: Optional[datetime] = Field(None, description="Event end date and time")
    location: Optional[str] = Field(None, description="Location or venue of the event")
    rec_center_id: Optional[str] = Field(
        None, description="Reference to the recreation center hosting the event"
    )
    category: Optional[str] = Field(
        None, description="Category of the event (e.g., sports, social, education)"
    )
    is_recurring: bool = Field(False, description="Whether the event repeats regularly")
    registration_required: bool = Field(
        False, description="Whether registration is required to attend"
    )
    contact_info: Optional[str] = Field(
        None, description="Contact information for the event organizer"
    )
    created_at: Optional[datetime] = Field(
        None, description="Timestamp when the event was created"
    )
    updated_at: Optional[datetime] = Field(
        None, description="Timestamp when the event was last updated"
    )

    model_config = {"extra": "forbid"}
