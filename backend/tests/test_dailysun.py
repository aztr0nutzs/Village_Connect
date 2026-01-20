"""
Unit tests for Daily Sun scraper
"""
import pytest
import os
from datetime import datetime
from unittest.mock import Mock, patch, AsyncMock
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from backend.scrapers.dailysun import DailySunScraper
from backend.database import Base
from backend.models.event import Event, Source


# Test database setup
TEST_DATABASE_URL = "sqlite:///:memory:"


@pytest.fixture
def test_db():
    """
    Create test database
    """
    engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    TestSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    db = TestSessionLocal()
    yield db

    db.close()
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def scraper():
    """
    Create scraper instance
    """
    return DailySunScraper()


@pytest.fixture
def sample_html():
    """
    Load sample HTML fixture
    """
    fixture_path = os.path.join(
        os.path.dirname(__file__),
        'fixtures',
        'dailysun_sample.html'
    )
    with open(fixture_path, 'r', encoding='utf-8') as f:
        return f.read()


class TestDailySunScraper:
    """
    Test suite for Daily Sun scraper
    """

    def test_scraper_initialization(self, scraper):
        """
        Test scraper initializes correctly
        """
        assert scraper.base_url == "https://www.snl24.com/dailysun"
        assert scraper.source_name == "Daily Sun"
        assert "User-Agent" in scraper.headers

    def test_check_robots_txt(self, scraper):
        """
        Test robots.txt checking
        """
        # Should return True for most URLs (or if robots.txt can't be read)
        result = scraper.check_robots_txt("https://www.snl24.com/dailysun/news")
        assert isinstance(result, bool)

    @pytest.mark.asyncio
    async def test_fetch_page_success(self, scraper):
        """
        Test successful page fetching
        """
        mock_response = Mock()
        mock_response.text = "<html><body>Test</body></html>"
        mock_response.raise_for_status = Mock()

        with patch('httpx.AsyncClient') as mock_client:
            mock_client.return_value.__aenter__.return_value.get = AsyncMock(return_value=mock_response)
            scraper.check_robots_txt = Mock(return_value=True)

            result = await scraper.fetch_page("https://example.com")

            assert result == "<html><body>Test</body></html>"

    @pytest.mark.asyncio
    async def test_fetch_page_blocked_by_robots(self, scraper):
        """
        Test page fetch blocked by robots.txt
        """
        scraper.check_robots_txt = Mock(return_value=False)

        result = await scraper.fetch_page("https://example.com")

        assert result is None

    def test_parse_events_from_html(self, scraper, sample_html):
        """
        Test parsing events from HTML fixture
        """
        events = scraper.parse_events_from_html(sample_html, "https://www.snl24.com/dailysun")

        # Should parse all 5 events from fixture
        assert len(events) == 5

        # Verify first event
        first_event = events[0]
        assert "Soweto Community Festival" in first_event['title']
        assert first_event['description'] is not None
        assert "Soweto" in first_event['location']
        assert first_event['url'] is not None
        assert first_event['external_id'] is not None
        assert isinstance(first_event['event_date'], datetime)

    def test_parse_events_attributes(self, scraper, sample_html):
        """
        Test that all parsed events have required attributes
        """
        events = scraper.parse_events_from_html(sample_html, "https://www.snl24.com/dailysun")

        for event in events:
            # Required fields
            assert 'title' in event
            assert 'external_id' in event

            # Title should not be empty
            assert len(event['title']) > 0

            # External ID should be a valid hash
            assert len(event['external_id']) == 32  # MD5 hash length

    def test_parse_single_event_with_all_fields(self, scraper):
        """
        Test parsing a single event with all fields present
        """
        from bs4 import BeautifulSoup

        html = """
        <article class="article">
            <h2><a href="/test-event">Test Event</a></h2>
            <p>Test description</p>
            <time datetime="2026-02-15T10:00:00">February 15, 2026</time>
            <span class="location">Test Location</span>
        </article>
        """

        soup = BeautifulSoup(html, 'lxml')
        article = soup.find('article')

        event = scraper._parse_single_event(article, "https://example.com")

        assert event is not None
        assert event['title'] == "Test Event"
        assert event['description'] == "Test description"
        assert event['location'] == "Test Location"
        assert event['url'] == "https://example.com/test-event"
        assert isinstance(event['event_date'], datetime)

    def test_parse_single_event_minimal(self, scraper):
        """
        Test parsing event with minimal information
        """
        from bs4 import BeautifulSoup

        html = """
        <article>
            <h2>Minimal Event Title</h2>
        </article>
        """

        soup = BeautifulSoup(html, 'lxml')
        article = soup.find('article')

        event = scraper._parse_single_event(article, "https://example.com")

        assert event is not None
        assert event['title'] == "Minimal Event Title"
        assert event['external_id'] is not None

    def test_parse_single_event_no_title(self, scraper):
        """
        Test that events without title are skipped
        """
        from bs4 import BeautifulSoup

        html = """
        <article>
            <p>No title here</p>
        </article>
        """

        soup = BeautifulSoup(html, 'lxml')
        article = soup.find('article')

        event = scraper._parse_single_event(article, "https://example.com")

        assert event is None

    def test_parse_date_formats(self, scraper):
        """
        Test various date format parsing
        """
        # ISO format
        date1 = scraper._parse_date("2026-02-15")
        assert date1 == datetime(2026, 2, 15)

        # ISO with time
        date2 = scraper._parse_date("2026-02-15T10:00:00")
        assert date2 == datetime(2026, 2, 15, 10, 0, 0)

        # Slash format
        date3 = scraper._parse_date("15/02/2026")
        assert date3 == datetime(2026, 2, 15)

        # Month name format
        date4 = scraper._parse_date("February 15, 2026")
        assert date4 == datetime(2026, 2, 15)

        # Invalid format
        date5 = scraper._parse_date("invalid date")
        assert date5 is None

    def test_generate_external_id(self, scraper):
        """
        Test external ID generation
        """
        id1 = scraper._generate_external_id("test string")
        id2 = scraper._generate_external_id("test string")
        id3 = scraper._generate_external_id("different string")

        # Same input should generate same ID
        assert id1 == id2

        # Different input should generate different ID
        assert id1 != id3

        # Should be MD5 hash (32 chars)
        assert len(id1) == 32

    def test_save_events_to_db(self, scraper, test_db):
        """
        Test saving events to database
        """
        events = [
            {
                'title': 'Test Event 1',
                'description': 'Test description',
                'event_date': datetime(2026, 2, 15),
                'location': 'Test Location',
                'url': 'https://example.com/event1',
                'external_id': 'test_id_1'
            },
            {
                'title': 'Test Event 2',
                'description': None,
                'event_date': None,
                'location': None,
                'url': 'https://example.com/event2',
                'external_id': 'test_id_2'
            }
        ]

        scraper.save_events_to_db(events, test_db)

        # Verify source was created
        source = test_db.query(Source).filter(Source.name == "Daily Sun").first()
        assert source is not None
        assert source.url == scraper.base_url

        # Verify events were created
        saved_events = test_db.query(Event).all()
        assert len(saved_events) == 2

        # Verify first event
        event1 = test_db.query(Event).filter(Event.external_id == 'test_id_1').first()
        assert event1.title == 'Test Event 1'
        assert event1.description == 'Test description'
        assert event1.location == 'Test Location'
        assert event1.source_id == source.id

    def test_save_events_avoid_duplicates(self, scraper, test_db):
        """
        Test that duplicate events are updated, not duplicated
        """
        event_data = {
            'title': 'Test Event',
            'description': 'Original description',
            'event_date': datetime(2026, 2, 15),
            'location': 'Test Location',
            'url': 'https://example.com/event',
            'external_id': 'test_id'
        }

        # Save event first time
        scraper.save_events_to_db([event_data], test_db)

        # Verify one event exists
        events = test_db.query(Event).all()
        assert len(events) == 1
        assert events[0].description == 'Original description'

        # Update event data
        event_data['description'] = 'Updated description'
        event_data['location'] = 'New Location'

        # Save same event again
        scraper.save_events_to_db([event_data], test_db)

        # Verify still only one event exists (updated, not duplicated)
        events = test_db.query(Event).all()
        assert len(events) == 1
        assert events[0].description == 'Updated description'
        assert events[0].location == 'New Location'

    def test_event_source_attribution(self, scraper, test_db):
        """
        Test that 100% of events include source.name and source.url
        """
        events = [
            {
                'title': f'Test Event {i}',
                'description': 'Test',
                'event_date': None,
                'location': None,
                'url': f'https://example.com/event{i}',
                'external_id': f'test_id_{i}'
            }
            for i in range(10)
        ]

        scraper.save_events_to_db(events, test_db)

        # Verify all events have source attribution
        saved_events = test_db.query(Event).all()
        assert len(saved_events) == 10

        for event in saved_events:
            # Each event must have a source
            assert event.source is not None
            assert event.source.name == "Daily Sun"
            assert event.source.url == scraper.base_url

    @pytest.mark.asyncio
    async def test_fetch_and_store_events_integration(self, scraper, test_db, sample_html):
        """
        Test complete fetch and store workflow
        """
        # Mock the fetch_page method
        scraper.fetch_page = AsyncMock(return_value=sample_html)

        # Mock SessionLocal to use our test_db
        with patch('backend.scrapers.dailysun.SessionLocal', return_value=test_db):
            await scraper.fetch_and_store_events()

        # Verify events were saved
        events = test_db.query(Event).all()
        assert len(events) == 5

        # Verify source
        source = test_db.query(Source).first()
        assert source.name == "Daily Sun"
