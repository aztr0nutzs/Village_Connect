# Backend

This directory contains the backend API service for Village Connect.

## Technology Stack

- **Framework:** FastAPI (recommended) or Firebase
- **Language:** Python 3.9+
- **Database:** TBD (PostgreSQL, Firebase Firestore, or similar)

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # Application entry point
│   ├── config.py            # Configuration management
│   ├── models/              # Data models
│   ├── routes/              # API route handlers
│   ├── services/            # Business logic
│   └── utils/               # Utility functions
├── tests/                   # Test files
├── requirements.txt         # Python dependencies
└── README.md               # This file
```

## Getting Started

### Prerequisites

- Python 3.9 or higher
- pip (Python package manager)
- Virtual environment (recommended)

### Installation

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   ```

3. Activate the virtual environment:
   - On Windows: `venv\Scripts\activate`
   - On macOS/Linux: `source venv/bin/activate`

4. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

### Running the Application

To run the development server:

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

### Running Tests

To run the test suite:

```bash
pytest
```

## API Documentation

When running the application, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Development

### Adding a New Endpoint

1. Create a new route file in `app/routes/`
2. Define your route handlers
3. Register the router in `app/main.py`

### Database Migrations

TBD - Will be added once database technology is selected

## Environment Variables

Create a `.env` file in the backend directory with the following variables:

```
DATABASE_URL=your_database_url
SECRET_KEY=your_secret_key
DEBUG=True
```

## Deployment

TBD - Deployment instructions will be added later
