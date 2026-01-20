from fastapi.testclient import TestClient

from backend.app import app


client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_events() -> None:
    response = client.get("/events")

    assert response.status_code == 200
    payload = response.json()
    assert isinstance(payload, list)
    assert payload
    assert {"id", "title", "start_time", "location", "rec_center_id"}.issubset(
        payload[0].keys()
    )


def test_rec_centers() -> None:
    response = client.get("/rec_centers")

    assert response.status_code == 200
    payload = response.json()
    assert isinstance(payload, list)
    assert payload
    assert {"id", "name", "address", "village_id"}.issubset(payload[0].keys())


def test_villages() -> None:
    response = client.get("/villages")

    assert response.status_code == 200
    payload = response.json()
    assert isinstance(payload, list)
    assert payload
    assert {"id", "name", "county", "state"}.issubset(payload[0].keys())
