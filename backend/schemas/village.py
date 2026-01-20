"""
Village metadata schema definition using Pydantic
"""
from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict


class Village(BaseModel):
    """Canonical Village metadata model for Village Connect"""
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id": "770e8400-e29b-41d4-a716-446655440002",
                "name": "The Villages",
                "region": "Central Florida",
                "zip_codes": ["32159", "32162", "32163", "34785"],
                "description": "America's premier active adult retirement community in Central Florida"
            }
        }
    )
    
    id: str = Field(..., description="Unique identifier for the village")
    name: str = Field(..., description="Village name")
    region: str = Field(..., description="Geographic region or district")
    zip_codes: List[str] = Field(
        default_factory=list,
        description="List of zip codes associated with the village"
    )
    description: Optional[str] = Field(None, description="Village description")

