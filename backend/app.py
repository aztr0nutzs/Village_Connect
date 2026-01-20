"""Village Connect API Server."""

import json
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

FIXTURES_DIR = Path(__file__).resolve().parent / "fixtures"
EVENTS_FIXTURE = FIXTURES_DIR / "events.json"
REC_CENTERS_FIXTURE = FIXTURES_DIR / "rec_centers.json"
VILLAGES_FIXTURE = FIXTURES_DIR / "villages.json"


app = FastAPI(
    title="Village Connect API",
    description="API for community events, residents, and services",
    version="0.1.0",
)

# CORS middleware for mobile app access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def load_fixture(path: Path) -> list[dict]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8") as file:
        return json.load(file)


def health_payload() -> dict:
    return {"status": "ok"}


@app.get("/")
async def root() -> dict:
    return {
        "status": "ok",
        "message": "Village Connect API is running",
        "version": "0.1.0",
    }


@app.get("/health")
async def health() -> dict:
    return health_payload()


@app.get("/events")
async def get_events() -> list[dict]:
    return load_fixture(EVENTS_FIXTURE)


@app.get("/rec_centers")
async def get_rec_centers() -> list[dict]:
    return load_fixture(REC_CENTERS_FIXTURE)


@app.get("/villages")
async def get_villages() -> list[dict]:
    return load_fixture(VILLAGES_FIXTURE)


@app.get("/api/v1/events")
async def legacy_events() -> list[dict]:
    return load_fixture(EVENTS_FIXTURE)


@app.get("/api/v1/health")
async def legacy_health() -> dict:
    return health_payload()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
