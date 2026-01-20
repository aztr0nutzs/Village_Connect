# Village Connect - Architecture & Design Decisions

This document records important architectural and design decisions made during the development of Village Connect.

## ADR-001: Monorepo Structure

**Date:** 2026-01-20  
**Status:** Accepted

### Context
The project needs to manage both a mobile Flutter application and a backend API service. We need to decide on the repository structure.

### Decision
Adopt a monorepo structure with separate directories for backend and mobile:
- `/backend/` - FastAPI-based Python backend
- `/mobile/` - Flutter mobile application
- `/docs/` - Project documentation

### Consequences
**Positive:**
- Single source of truth for all code
- Easier to coordinate changes across backend and mobile
- Shared CI/CD configuration
- Simplified dependency management

**Negative:**
- Larger repository size
- Need to coordinate build and test processes for different tech stacks
- Potential for coupling between backend and mobile

### Alternatives Considered
- Separate repositories (polyrepo approach)
- Backend as a submodule

---

## ADR-002: Backend Technology Stack

**Date:** 2026-01-20  
**Status:** Accepted

### Context
Need to choose a backend framework for the API and data ingestion layer.

### Decision
Use FastAPI (Python) for the backend API layer.

### Rationale
- Fast, modern Python framework
- Automatic API documentation (OpenAPI/Swagger)
- Async support for better performance
- Strong typing with Pydantic
- Easy to integrate with data scraping libraries
- Good for both API endpoints and background tasks

### Consequences
- Python expertise required for backend development
- Need to manage Python virtual environments
- Excellent ecosystem for web scraping and data processing

---

## ADR-003: Mobile App Location

**Date:** 2026-01-20  
**Status:** Accepted

### Context
The existing Flutter app was in `villages_connect/` directory. Need to decide how to integrate it into the monorepo.

### Decision
Move the existing `villages_connect/` directory to `/mobile/` to create a clear, consistent monorepo structure.

### Consequences
**Positive:**
- Clear separation of concerns
- Consistent naming convention
- Easy to navigate for new developers

**Negative:**
- Breaks any existing absolute path references
- Git history might be harder to track

---

*Add new architectural decision records (ADRs) as the project evolves.*
