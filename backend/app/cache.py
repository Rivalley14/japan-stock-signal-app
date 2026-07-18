import json
import sqlite3
import time
from pathlib import Path
from typing import Any, Optional

DB_PATH = Path(__file__).parent / "cache.db"


def _get_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.execute(
        "CREATE TABLE IF NOT EXISTS cache ("
        "key TEXT PRIMARY KEY, value TEXT NOT NULL, expires_at REAL NOT NULL)"
    )
    return conn


def get(key: str) -> Optional[Any]:
    conn = _get_conn()
    try:
        row = conn.execute(
            "SELECT value, expires_at FROM cache WHERE key = ?", (key,)
        ).fetchone()
        if row is None:
            return None
        value, expires_at = row
        if expires_at < time.time():
            conn.execute("DELETE FROM cache WHERE key = ?", (key,))
            conn.commit()
            return None
        return json.loads(value)
    finally:
        conn.close()


def set(key: str, value: Any, ttl_seconds: int) -> None:
    conn = _get_conn()
    try:
        conn.execute(
            "INSERT INTO cache (key, value, expires_at) VALUES (?, ?, ?) "
            "ON CONFLICT(key) DO UPDATE SET value = excluded.value, expires_at = excluded.expires_at",
            (key, json.dumps(value), time.time() + ttl_seconds),
        )
        conn.commit()
    finally:
        conn.close()
