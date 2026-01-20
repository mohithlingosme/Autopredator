"""
AutoPredator FleetCommand API
FastAPI backend for fleet management system
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="AutoPredator FleetCommand API",
    description="Multi-tenant fleet management platform",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure properly in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    """Health check endpoint for load balancers and monitoring"""
    return {"status": "healthy", "service": "api"}

@app.get("/ready")
async def readiness_check():
    """Readiness check for deployment orchestration"""
    # In production, check database, redis, etc.
    return {"status": "ready", "service": "api"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
