from fastapi import FastAPI

app = FastAPI(title="Autopredator Backend", version="0.0.1")


@app.get("/health")
def health() -> dict:
    """Lightweight health endpoint for uptime checks."""
    return {"status": "ok"}
