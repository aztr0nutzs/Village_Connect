"""
Event data models
"""
from datetime import datetime
from typing import Optional
from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey
from sqlalchemy.orm import relationship
from pydantic import BaseModel, Field
from backend.database import Base


class Source(Base):
    """
    SQLAlchemy model for event sources
    """
    __tablename__ = "sources"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), unique=True, nullable=False, index=True)
    url = Column(String(512), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationship
    events = relationship("Event", back_populates="source")


class Event(Base):
    """
    SQLAlchemy model for events
    """
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(512), nullable=False)
    description = Column(Text, nullable=True)
    event_date = Column(DateTime, nullable=True)
    location = Column(String(512), nullable=True)
    url = Column(String(1024), nullable=True)
    external_id = Column(String(255), unique=True, nullable=True, index=True)
    
    # Source attribution
    source_id = Column(Integer, ForeignKey("sources.id"), nullable=False)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationship
    source = relationship("Source", back_populates="events")


# Pydantic schemas for API validation


class SourceSchema(BaseModel):
    """
    Pydantic schema for Source
    """
    id: Optional[int] = None
    name: str = Field(..., max_length=255)
    url: str = Field(..., max_length=512)
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class EventSchema(BaseModel):
    """
    Pydantic schema for Event
    """
    id: Optional[int] = None
    title: str = Field(..., max_length=512)
    description: Optional[str] = None
    event_date: Optional[datetime] = None
    location: Optional[str] = Field(None, max_length=512)
    url: Optional[str] = Field(None, max_length=1024)
    external_id: Optional[str] = Field(None, max_length=255)
    source_id: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class EventWithSourceSchema(BaseModel):
    """
    Event schema with source information
    """
    id: Optional[int] = None
    title: str
    description: Optional[str] = None
    event_date: Optional[datetime] = None
    location: Optional[str] = None
    url: Optional[str] = None
    external_id: Optional[str] = None
    source: SourceSchema
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
