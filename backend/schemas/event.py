"""Event schema definitions."""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict


class Event(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    description: Optional[str] = None
    start_time: datetime
    end_time: Optional[datetime] = None
    location: str
    rec_center_id: int
