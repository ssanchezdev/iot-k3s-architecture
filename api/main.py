from fastapi import FastAPI, Request
from datetime import datetime

app = FastAPI(title="IoT Telemetry Gateway")

@app.get("/health")
async def health_check():
    return{
        "status": "online",
        "timestamp": datetime.now().isoformat()
    }

@app.post("/api/v1/telemetry")
async def ingest_data(request: Request):
    payload = await request.json()
    return{
        "status": "accepted",
        "device": payload.get("device_id", "unknown"),
        "time": datetime.now().isoformat()
    }