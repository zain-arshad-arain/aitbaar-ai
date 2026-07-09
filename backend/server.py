from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import random
import os

load_dotenv()
from main import run_pipeline

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"status": "running", "app": "Aitbaar AI"}

@app.post("/analyze")
def analyze(req: dict):
    try:
        result = run_pipeline(
            req.get("message_text", ""),
            req.get("url", ""),
            req.get("phone", ""),
            req.get("sender_name", ""),
            req.get("email", "")
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/actions/warn-user")
def warn_user():
    return {"status": "success", "action": "warn_user"}

@app.post("/actions/log-incident")
def log_incident():
    if random.random() < 0.3:
        raise HTTPException(status_code=503, detail="Service unavailable")
    return {"status": "success", "incident_id": "INC-001"}

@app.post("/actions/send-alert")
def send_alert():
    return {"status": "success", "alert_sent": True}

@app.post("/actions/draft-community-post")
def draft_post():
    return {"status": "success", "post_drafted": True}

@app.post("/actions/schedule-recheck")
def schedule_recheck():
    return {"status": "success", "scheduled": True}