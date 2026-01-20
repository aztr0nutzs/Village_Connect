"""
CLI entry point for Daily Sun scraper
Usage: python -m backend.scrapers.dailysun
"""
import asyncio
from backend.scrapers.dailysun import main

if __name__ == "__main__":
    asyncio.run(main())
