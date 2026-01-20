# Village Connect Backend

FastAPI-based backend service for the Village Connect application. Provides data ingestion from community sources and REST API endpoints for the mobile app.

## Features

- **REST API** - Efficient endpoints for mobile app
- **Data Scrapers** - Automated ingestion from community event sources
- **Async Support** - High-performance async request handling
- **API Documentation** - Auto-generated OpenAPI/Swagger docs

## Prerequisites

- Python 3.9 or higher
- pip (Python package manager)

## Setup

### 1. Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Run Development Server

```bash
# Using the app directly
python app.py

# Or using uvicorn
uvicorn backend.app:app --reload --host 0.0.0.0 --port 8000
```

The server will start on `http://localhost:8000`

## API Documentation

Once the server is running, you can access:

- **Interactive API Docs (Swagger)**: http://localhost:8000/docs
- **Alternative API Docs (ReDoc)**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

## Project Structure

```
backend/
├── app.py              # Main FastAPI application
├── requirements.txt    # Python dependencies
├── scrapers/          # Data ingestion modules
│   └── __init__.py
├── api/               # API route definitions
│   └── __init__.py
├── models/            # Data models and schemas
│   └── __init__.py
└── tests/             # Backend tests
    └── __init__.py
```

## API Endpoints

### Health Check
```
GET /
GET /health
GET /api/v1/health
```

### Events (Mock data)
```
GET /events
GET /api/v1/events
```

### Recreation Centers (Mock data)
```
GET /rec_centers
```

### Villages (Mock data)
```
GET /villages
```

### Example Fixtures

Sample JSON fixtures live in `docs/examples/`, with JSON schema definitions in `docs/schemas/`.

*More endpoints will be added as features are implemented.*

## Development

### Linting

```bash
# Check code with flake8
flake8 .

# Format code with black
black .

# Type checking with mypy
mypy . --ignore-missing-imports
```

### Testing

```bash
# Run tests with pytest
pytest tests/ -v

# Run tests with coverage
pytest tests/ --cov=. --cov-report=html
```

## Environment Variables

Create a `.env` file in the backend directory:

```env
# Example environment variables
DATABASE_URL=sqlite:///./village_connect.db
API_KEY=your_api_key_here
DEBUG=True
```

## Deployment

### Docker (Coming Soon)

```bash
docker build -t village-connect-backend .
docker run -p 8000:8000 village-connect-backend
```

### Production

For production deployment:

1. Set `DEBUG=False` in environment
2. Use a production ASGI server (uvicorn with workers)
3. Set up proper database (PostgreSQL recommended)
4. Configure CORS for production domains
5. Enable HTTPS/SSL

```bash
uvicorn backend.app:app --host 0.0.0.0 --port 8000 --workers 4
```

## Contributing

See the main [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

Apache License 2.0 - See [LICENSE](../LICENSE) for details.
