"""
Daily Sun Event Scraper
Fetches and parses community events from Daily Sun
"""
import logging
import hashlib
from datetime import datetime
from typing import List, Optional, Dict, Any
from urllib.parse import urljoin, urlparse
from urllib.robotparser import RobotFileParser
import httpx
from bs4 import BeautifulSoup
from apscheduler.schedulers.background import BackgroundScheduler
from sqlalchemy.orm import Session

from backend.database import SessionLocal, init_db
from backend.models.event import Event, Source

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Daily Sun configuration
DAILY_SUN_BASE_URL = "https://www.snl24.com/dailysun"
DAILY_SUN_EVENTS_URL = f"{DAILY_SUN_BASE_URL}/news"
SOURCE_NAME = "Daily Sun"
USER_AGENT = "VillageConnect/1.0 (+https://github.com/aztr0nutzs/Village_Connect)"


class DailySunScraper:
    """
    Scraper for Daily Sun community events
    """
    
    def __init__(self, base_url: str = DAILY_SUN_BASE_URL):
        self.base_url = base_url
        self.events_url = DAILY_SUN_EVENTS_URL
        self.source_name = SOURCE_NAME
        self.robot_parser = RobotFileParser()
        self.robot_parser.set_url(f"{base_url}/robots.txt")
        self.headers = {
            "User-Agent": USER_AGENT,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.5",
            "Accept-Encoding": "gzip, deflate",
            "Connection": "keep-alive",
        }
    
    def check_robots_txt(self, url: str) -> bool:
        """
        Check if URL is allowed by robots.txt
        
        Args:
            url: URL to check
            
        Returns:
            True if allowed, False otherwise
        """
        try:
            self.robot_parser.read()
            return self.robot_parser.can_fetch(USER_AGENT, url)
        except Exception as e:
            logger.warning(f"Could not read robots.txt: {e}. Proceeding with caution.")
            return True  # If robots.txt can't be read, proceed with caution
    
    async def fetch_page(self, url: str) -> Optional[str]:
        """
        Fetch HTML content from URL
        
        Args:
            url: URL to fetch
            
        Returns:
            HTML content or None if failed
        """
        if not self.check_robots_txt(url):
            logger.warning(f"URL blocked by robots.txt: {url}")
            return None
        
        try:
            async with httpx.AsyncClient(headers=self.headers, timeout=30.0, follow_redirects=True) as client:
                response = await client.get(url)
                response.raise_for_status()
                return response.text
        except httpx.HTTPStatusError as e:
            logger.error(f"HTTP error fetching {url}: {e}")
            return None
        except Exception as e:
            logger.error(f"Error fetching {url}: {e}")
            return None
    
    def parse_events_from_html(self, html: str, base_url: str) -> List[Dict[str, Any]]:
        """
        Parse events from HTML content
        
        Args:
            html: HTML content
            base_url: Base URL for resolving relative links
            
        Returns:
            List of event dictionaries
        """
        events = []
        
        try:
            soup = BeautifulSoup(html, 'lxml')
            
            # Look for common event/article patterns
            # This is a generic parser that works with many news sites
            article_selectors = [
                'article',
                'div.article',
                'div.news-item',
                'div.event-item',
                'div[class*="article"]',
                'div[class*="event"]',
                'div[class*="post"]'
            ]
            
            articles = []
            for selector in article_selectors:
                found = soup.select(selector)
                if found:
                    articles = found
                    logger.info(f"Found {len(articles)} articles using selector: {selector}")
                    break
            
            if not articles:
                logger.warning("No articles found with known selectors")
                return events
            
            for article in articles:
                try:
                    event = self._parse_single_event(article, base_url)
                    if event:
                        events.append(event)
                except Exception as e:
                    logger.error(f"Error parsing individual event: {e}")
                    continue
        
        except Exception as e:
            logger.error(f"Error parsing HTML: {e}")
        
        return events
    
    def _parse_single_event(self, article: Any, base_url: str) -> Optional[Dict[str, Any]]:
        """
        Parse a single event from an article element
        
        Args:
            article: BeautifulSoup article element
            base_url: Base URL for resolving relative links
            
        Returns:
            Event dictionary or None
        """
        # Extract title
        title_elem = (
            article.find('h1') or 
            article.find('h2') or 
            article.find('h3') or
            article.find('a', class_='title') or
            article.find(class_='title') or
            article.find('a')
        )
        
        if not title_elem:
            return None
        
        title = title_elem.get_text(strip=True)
        if not title or len(title) < 5:
            return None
        
        # Extract URL
        link_elem = article.find('a', href=True)
        url = None
        if link_elem and link_elem.get('href'):
            url = urljoin(base_url, link_elem['href'])
        
        # Extract description
        description_elem = (
            article.find('p') or
            article.find(class_='description') or
            article.find(class_='excerpt') or
            article.find(class_='summary')
        )
        description = description_elem.get_text(strip=True) if description_elem else None
        
        # Extract date (if available)
        date_elem = (
            article.find('time') or
            article.find(class_='date') or
            article.find(class_='published') or
            article.find(class_='timestamp')
        )
        
        event_date = None
        if date_elem:
            date_str = date_elem.get('datetime') or date_elem.get_text(strip=True)
            event_date = self._parse_date(date_str)
        
        # Extract location (if available)
        location = None
        location_elem = (
            article.find(class_='location') or
            article.find(class_='venue') or
            article.find(class_='place')
        )
        if location_elem:
            location = location_elem.get_text(strip=True)
        
        # Generate external_id from URL or title
        external_id = self._generate_external_id(url or title)
        
        return {
            'title': title,
            'description': description,
            'event_date': event_date,
            'location': location,
            'url': url,
            'external_id': external_id
        }
    
    def _parse_date(self, date_str: str) -> Optional[datetime]:
        """
        Parse date string to datetime
        
        Args:
            date_str: Date string
            
        Returns:
            datetime object or None
        """
        if not date_str:
            return None
        
        # Try common date formats
        formats = [
            '%Y-%m-%d',
            '%Y-%m-%dT%H:%M:%S',
            '%Y-%m-%dT%H:%M:%S.%f',
            '%Y-%m-%dT%H:%M:%SZ',
            '%d/%m/%Y',
            '%d-%m-%Y',
            '%B %d, %Y',
            '%b %d, %Y',
        ]
        
        for fmt in formats:
            try:
                return datetime.strptime(date_str, fmt)
            except ValueError:
                continue
        
        logger.debug(f"Could not parse date: {date_str}")
        return None
    
    def _generate_external_id(self, source_string: str) -> str:
        """
        Generate a unique external ID from a source string
        
        Args:
            source_string: String to hash
            
        Returns:
            External ID
        """
        return hashlib.md5(source_string.encode()).hexdigest()
    
    def save_events_to_db(self, events: List[Dict[str, Any]], db: Session):
        """
        Save or update events in the database
        
        Args:
            events: List of event dictionaries
            db: Database session
        """
        # Get or create source
        source = db.query(Source).filter(Source.name == self.source_name).first()
        if not source:
            source = Source(
                name=self.source_name,
                url=self.base_url
            )
            db.add(source)
            db.commit()
            db.refresh(source)
            logger.info(f"Created new source: {self.source_name}")
        
        saved_count = 0
        updated_count = 0
        
        for event_data in events:
            try:
                # Check if event exists
                existing_event = db.query(Event).filter(
                    Event.external_id == event_data['external_id']
                ).first()
                
                if existing_event:
                    # Update existing event
                    existing_event.title = event_data['title']
                    existing_event.description = event_data.get('description')
                    existing_event.event_date = event_data.get('event_date')
                    existing_event.location = event_data.get('location')
                    existing_event.url = event_data.get('url')
                    existing_event.updated_at = datetime.utcnow()
                    updated_count += 1
                    logger.debug(f"Updated event: {event_data['title']}")
                else:
                    # Create new event
                    new_event = Event(
                        title=event_data['title'],
                        description=event_data.get('description'),
                        event_date=event_data.get('event_date'),
                        location=event_data.get('location'),
                        url=event_data.get('url'),
                        external_id=event_data['external_id'],
                        source_id=source.id
                    )
                    db.add(new_event)
                    saved_count += 1
                    logger.debug(f"Created new event: {event_data['title']}")
                
                db.commit()
                
            except Exception as e:
                logger.error(f"Error saving event {event_data.get('title')}: {e}")
                db.rollback()
                continue
        
        logger.info(f"Saved {saved_count} new events, updated {updated_count} events")
    
    async def fetch_and_store_events(self):
        """
        Main method to fetch events from Daily Sun and store them
        """
        logger.info("Starting Daily Sun event fetch...")
        
        # Fetch HTML
        html = await self.fetch_page(self.events_url)
        if not html:
            logger.error("Failed to fetch events page")
            return
        
        # Parse events
        events = self.parse_events_from_html(html, self.base_url)
        logger.info(f"Parsed {len(events)} events")
        
        if not events:
            logger.warning("No events found")
            return
        
        # Save to database
        db = SessionLocal()
        try:
            self.save_events_to_db(events, db)
        finally:
            db.close()
        
        logger.info("Daily Sun event fetch completed")


# Scheduler for periodic updates
scheduler = None


def start_scheduler():
    """
    Start background scheduler to run scraper every 60 minutes
    """
    global scheduler
    
    if scheduler is not None:
        logger.warning("Scheduler already running")
        return
    
    scheduler = BackgroundScheduler()
    
    async def job():
        scraper = DailySunScraper()
        await scraper.fetch_and_store_events()
    
    # Schedule job every 60 minutes
    scheduler.add_job(
        lambda: __import__('asyncio').run(job()),
        'interval',
        minutes=60,
        id='dailysun_scraper',
        name='Daily Sun Event Scraper',
        replace_existing=True
    )
    
    scheduler.start()
    logger.info("Scheduler started - Daily Sun scraper will run every 60 minutes")


def stop_scheduler():
    """
    Stop the background scheduler
    """
    global scheduler
    
    if scheduler is not None:
        scheduler.shutdown()
        scheduler = None
        logger.info("Scheduler stopped")


# CLI entry point
async def main():
    """
    Main CLI entry point
    """
    logger.info("Daily Sun Scraper - CLI Mode")
    
    # Initialize database
    init_db()
    logger.info("Database initialized")
    
    # Create scraper and fetch events
    scraper = DailySunScraper()
    await scraper.fetch_and_store_events()
    
    logger.info("Scraping completed successfully")


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
