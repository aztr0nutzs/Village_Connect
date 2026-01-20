"""Recreation center schema definitions."""

from typing import Optional

from pydantic import BaseModel, ConfigDict


class RecCenter(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    address: str
    phone: Optional[str] = None
    village_id: int
