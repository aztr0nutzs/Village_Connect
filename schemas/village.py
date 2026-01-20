"""
Village metadata schema for Village Connect.
"""

from typing import List, Optional

from pydantic import BaseModel, Field


class Village(BaseModel):
    """Schema for village metadata in The Villages community."""

    id: str = Field(..., description="Unique identifier for the village")
    name: str = Field(..., description="Name of the village")
    district: Optional[str] = Field(None, description="District the village belongs to")
    region: Optional[str] = Field(
        None, description="Region within The Villages (e.g., North, Central, South)"
    )
    zip_code: Optional[str] = Field(None, description="ZIP code for the village")
    established_year: Optional[int] = Field(
        None, description="Year the village was established"
    )
    population: Optional[int] = Field(
        None, description="Approximate population of the village"
    )
    description: Optional[str] = Field(None, description="Description of the village")
    featured_amenities: Optional[List[str]] = Field(
        None, description="Notable amenities in this village"
    )

    model_config = {"extra": "forbid"}
