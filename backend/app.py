"""
Village Connect API Server
FastAPI application for serving community data
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

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


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "ok",
        "message": "Village Connect API is running",
        "version": "0.1.0",
    }


@app.get("/api/v1/events")
async def get_events():
    """Get community events - placeholder endpoint"""
    return {"events": [], "message": "Events endpoint - to be implemented"}


@app.get("/api/v1/health")
async def health_check():
    """API health check"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
