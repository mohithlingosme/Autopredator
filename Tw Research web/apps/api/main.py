import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from settings import settings

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.log_level.upper(), logging.INFO),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Autopredator API",
    description="Backend API for Autopredator platform",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/healthz")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "environment": settings.environment}

@app.get("/readyz")
async def readiness_check():
    """Readiness check endpoint - includes DB check if needed"""
    # TODO: Add database connectivity check here
    return {"status": "ready", "environment": settings.environment}

@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Welcome to Autopredator API", "version": "1.0.0"}

if __name__ == "__main__":
    logger.info(f"Starting API server on {settings.api_host}:{settings.api_port}")
    uvicorn.run(
        "main:app",
        host=settings.api_host,
        port=settings.api_port,
        reload=settings.api_reload,
        log_level=settings.log_level.lower()
    )
