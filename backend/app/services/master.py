import json
from pathlib import Path
from typing import List, Optional

MASTER_PATH = Path(__file__).parent.parent / "data" / "jpx_master.json"

_stocks = json.loads(MASTER_PATH.read_text(encoding="utf-8"))
_by_code = {s["code"]: s for s in _stocks}


def search(query: str, limit: int = 20) -> List[dict]:
    q = query.strip().lower()
    if not q:
        return []
    results = [
        s
        for s in _stocks
        if q in s["code"]
        or q in s["name"].lower()
        or q in s["name_en"].lower()
    ]
    return results[:limit]


def lookup(code: str) -> Optional[dict]:
    return _by_code.get(code)
