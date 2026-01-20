# Daily Sun Event Scraper

This module provides automated event ingestion from Daily Sun community news.

## Features

- **Automated Scraping**: Fetches community events from Daily Sun website
- **Robots.txt Compliance**: Respects robots.txt restrictions
- **Duplicate Prevention**: Updates existing events instead of creating duplicates
- **Source Attribution**: Every event includes source.name and source.url
- **Scheduled Updates**: APScheduler runs scraper every 60 minutes
- **Error Handling**: Graceful error handling with comprehensive logging

## Usage

### CLI Mode (One-time Fetch)

```bash
python -m backend.scrapers.dailysun
```

This will:
1. Initialize the database
2. Fetch events from Daily Sun
3. Parse and normalize event data
4. Save or update events in the database

### Background Scheduler Mode

```python
from backend.scrapers.dailysun import start_scheduler, stop_scheduler

# Start the scheduler (runs every 60 minutes)
start_scheduler()

# Your application runs here...

# Stop the scheduler when done
stop_scheduler()
```

## Database Schema

### Sources Table
- `id`: Primary key
- `name`: Source name (e.g., "Daily Sun")
- `url`: Source URL
- `created_at`, `updated_at`: Timestamps

### Events Table
- `id`: Primary key
- `title`: Event title
- `description`: Event description
- `event_date`: When the event occurs
- `location`: Event location
- `url`: Link to full event details
- `external_id`: Unique identifier (prevents duplicates)
- `source_id`: Foreign key to sources table
- `created_at`, `updated_at`: Timestamps

## Testing

Run the test suite:

```bash
pytest tests/test_dailysun.py -v
```

Tests cover:
- HTML parsing with fixture data
- Database operations
- Duplicate prevention
- Source attribution
- Date parsing
- Error handling

## Implementation Details

### Event Parsing

The scraper uses BeautifulSoup to parse HTML and extract:
- Title (from h1, h2, h3, or link elements)
- Description (from p or description class)
- Date (from time element or date class)
- Location (from location class)
- URL (from anchor tags)

### Duplicate Prevention

Events are identified by `external_id` (MD5 hash of URL or title). When an event with the same `external_id` is found, it's updated instead of creating a duplicate.

### Logging

The scraper logs all operations:
- INFO: Successful operations
- WARNING: Non-critical issues (e.g., robots.txt warnings)
- ERROR: Failed operations
- DEBUG: Detailed parsing information

## Configuration

Environment variables (optional):
- `DATABASE_URL`: Database connection string (default: sqlite:///./village_connect.db)

## Dependencies

- httpx: Async HTTP client
- beautifulsoup4: HTML parsing
- lxml: XML/HTML parser
- APScheduler: Job scheduling
- sqlalchemy: Database ORM
