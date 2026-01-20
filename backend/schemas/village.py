"""Village schema definitions."""

from typing import Optional

from pydantic import BaseModel, ConfigDict


class Village(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    county: str
    state: str
    description: Optional[str] = None
