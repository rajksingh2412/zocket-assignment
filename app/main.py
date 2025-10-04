from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import sqlite3
from prometheus_client import Counter, generate_latest
from fastapi.responses import Response

app = FastAPI()

# Pydantic model for request
class Task(BaseModel):
    title: str
    description: str

# Pydantic model for response (with ID)
class TaskOut(Task):
    id: int

# Prometheus counter for all HTTP requests
REQUEST_COUNT = Counter("http_requests_total", "Total HTTP requests")

# DB utility: get connection
def get_db():
    return sqlite3.connect("tasks.db", check_same_thread=False)

@app.on_event("startup")
def startup():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT
        )
    """)
    conn.commit()
    conn.close()

@app.post("/tasks")
def create_task(task: Task):
    REQUEST_COUNT.inc()
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO tasks (title, description) VALUES (?, ?)", (task.title, task.description))
    conn.commit()
    conn.close()
    return {"message": "Task created"}

@app.get("/tasks", response_model=List[TaskOut])
def list_tasks():
    REQUEST_COUNT.inc()
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, description FROM tasks")
    rows = cursor.fetchall()
    conn.close()
    return [{"id": row[0], "title": row[1], "description": row[2]} for row in rows]

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type="text/plain")
