"""
RecCenter model for recreation centers
"""
from sqlalchemy import Column, Integer, String
from database import Base


class RecCenter(Base):
    """
    RecCenter model representing recreation centers in the community
    """

    __tablename__ = "rec_centers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    address = Column(String, nullable=False)
    phone = Column(String, nullable=True)
    # e.g., "Mon-Fri: 8AM-5PM"
    hours = Column(String, nullable=True)
    # Comma-separated list of amenities
    amenities = Column(String, nullable=True)

    def __repr__(self):
        return (
            f"<RecCenter(id={self.id}, name='{self.name}', "
            f"address='{self.address}')>"
        )
