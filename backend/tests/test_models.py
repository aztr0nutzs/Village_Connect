"""
Unit tests for database models
"""
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from database import Base
from models.event import Event
from models.rec_center import RecCenter


# Create a test database in memory
TEST_DATABASE_URL = "sqlite:///:memory:"


@pytest.fixture
def db_session():
    """
    Create a test database session for each test
    """
    engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)


class TestEventModel:
    """Tests for Event model"""

    def test_insert_event(self, db_session):
        """Test inserting an event record"""
        event = Event(
            title="Community Meeting",
            description="Monthly community gathering",
            date="2024-01-25",
            time="2:00 PM - 4:00 PM",
            location="Clubhouse Main Hall",
            category="social",
            capacity=100,
            registered=45,
            is_registered=False,
        )
        db_session.add(event)
        db_session.commit()

        # Verify the event was inserted
        assert event.id is not None
        assert event.title == "Community Meeting"

    def test_fetch_event(self, db_session):
        """Test fetching an event record"""
        # Insert an event
        event = Event(
            title="Fitness Class",
            description="Senior fitness class",
            date="2024-01-26",
            time="10:00 AM - 11:00 AM",
            location="Fitness Center",
            category="fitness",
            capacity=20,
            registered=18,
            is_registered=True,
        )
        db_session.add(event)
        db_session.commit()

        # Fetch the event
        fetched_event = db_session.query(Event).filter_by(title="Fitness Class").first()
        assert fetched_event is not None
        assert fetched_event.title == "Fitness Class"
        assert fetched_event.category == "fitness"
        assert fetched_event.capacity == 20
        assert fetched_event.registered == 18
        assert fetched_event.is_registered is True

    def test_fetch_events_by_category(self, db_session):
        """Test fetching events by category"""
        # Insert multiple events
        events = [
            Event(
                title="Social Event 1",
                description="Social gathering",
                date="2024-01-25",
                time="2:00 PM",
                location="Hall A",
                category="social",
                capacity=50,
                registered=25,
            ),
            Event(
                title="Fitness Event 1",
                description="Exercise class",
                date="2024-01-26",
                time="10:00 AM",
                location="Gym",
                category="fitness",
                capacity=30,
                registered=15,
            ),
            Event(
                title="Social Event 2",
                description="Another social event",
                date="2024-01-27",
                time="3:00 PM",
                location="Hall B",
                category="social",
                capacity=60,
                registered=30,
            ),
        ]
        for event in events:
            db_session.add(event)
        db_session.commit()

        # Fetch social events
        social_events = db_session.query(Event).filter_by(category="social").all()
        assert len(social_events) == 2
        assert all(e.category == "social" for e in social_events)

    def test_update_event(self, db_session):
        """Test updating an event record"""
        # Insert an event
        event = Event(
            title="Update Test Event",
            description="Test event",
            date="2024-01-25",
            time="2:00 PM",
            location="Test Hall",
            category="social",
            capacity=50,
            registered=10,
        )
        db_session.add(event)
        db_session.commit()

        # Update the event
        event.registered = 25
        db_session.commit()

        # Verify the update
        fetched_event = (
            db_session.query(Event).filter_by(title="Update Test Event").first()
        )
        assert fetched_event.registered == 25


class TestRecCenterModel:
    """Tests for RecCenter model"""

    def test_insert_rec_center(self, db_session):
        """Test inserting a rec center record"""
        rec_center = RecCenter(
            name="Main Recreation Center",
            address="123 Village Dr, The Villages, FL",
            phone="352-555-1234",
            hours="Mon-Fri: 8AM-5PM",
            amenities="Fitness, Pool, Classes",
        )
        db_session.add(rec_center)
        db_session.commit()

        # Verify the rec center was inserted
        assert rec_center.id is not None
        assert rec_center.name == "Main Recreation Center"

    def test_fetch_rec_center(self, db_session):
        """Test fetching a rec center record"""
        # Insert a rec center
        rec_center = RecCenter(
            name="Community Center",
            address="456 Main St, The Villages, FL",
            phone="352-555-5678",
            hours="Mon-Sun: 9AM-9PM",
            amenities="Pool, Tennis, Pickleball",
        )
        db_session.add(rec_center)
        db_session.commit()

        # Fetch the rec center
        fetched = db_session.query(RecCenter).filter_by(name="Community Center").first()
        assert fetched is not None
        assert fetched.name == "Community Center"
        assert fetched.address == "456 Main St, The Villages, FL"
        assert fetched.phone == "352-555-5678"
        assert fetched.hours == "Mon-Sun: 9AM-9PM"
        assert fetched.amenities == "Pool, Tennis, Pickleball"

    def test_fetch_all_rec_centers(self, db_session):
        """Test fetching all rec centers"""
        # Insert multiple rec centers
        rec_centers = [
            RecCenter(
                name="Center A",
                address="123 A St",
                phone="352-555-0001",
                hours="8AM-5PM",
                amenities="Pool",
            ),
            RecCenter(
                name="Center B",
                address="456 B St",
                phone="352-555-0002",
                hours="9AM-6PM",
                amenities="Gym",
            ),
            RecCenter(
                name="Center C",
                address="789 C St",
                phone="352-555-0003",
                hours="10AM-7PM",
                amenities="Classes",
            ),
        ]
        for center in rec_centers:
            db_session.add(center)
        db_session.commit()

        # Fetch all rec centers
        all_centers = db_session.query(RecCenter).all()
        assert len(all_centers) == 3
        names = [c.name for c in all_centers]
        assert "Center A" in names
        assert "Center B" in names
        assert "Center C" in names

    def test_rec_center_optional_fields(self, db_session):
        """Test rec center with optional fields"""
        # Insert a rec center with only required fields
        rec_center = RecCenter(name="Minimal Center", address="100 Min St")
        db_session.add(rec_center)
        db_session.commit()

        # Verify the rec center was inserted
        fetched = db_session.query(RecCenter).filter_by(name="Minimal Center").first()
        assert fetched is not None
        assert fetched.name == "Minimal Center"
        assert fetched.address == "100 Min St"
        assert fetched.phone is None
        assert fetched.hours is None
        assert fetched.amenities is None
