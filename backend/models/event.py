"""
Event model for community events
"""
from sqlalchemy import Column, Integer, String, Boolean
from database import Base


class Event(Base):
    """
    Event model representing community events
    Based on the TypeScript Event interface from villages-connect/src/screens/Events.tsx
    """

    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False, index=True)
    description = Column(String, nullable=False)
    date = Column(String, nullable=False)  # ISO date format (e.g., "2024-01-25")
    time = Column(
        String, nullable=False
    )  # Human-readable time (e.g., "2:00 PM - 4:00 PM")
    location = Column(String, nullable=False, index=True)
    category = Column(
        String, nullable=False, index=True
    )  # social, educational, fitness, entertainment, volunteer
    capacity = Column(Integer, nullable=False)
    registered = Column(Integer, default=0)
    is_registered = Column(
        Boolean, default=False
    )  # User's registration status (per-user in future)

    def __repr__(self):
        return (
            f"<Event(id={self.id}, title='{self.title}', "
            f"date='{self.date}', location='{self.location}')>"
        )
