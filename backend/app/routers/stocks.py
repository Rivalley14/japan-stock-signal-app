from fastapi import APIRouter, HTTPException, Query

from app import cache, config
from app.services import master, yfinance_client
from app.services import indicators, signal

router = APIRouter(prefix="/stocks", tags=["stocks"])


def _require_known_code(code: str) -> None:
    if master.lookup(code) is None:
        raise HTTPException(status_code=404, detail=f"unknown stock code: {code}")


@router.get("/search")
def search_stocks(q: str = Query(..., min_length=1)):
    return {"results": master.search(q)}


@router.get("/{code}/quote")
def get_quote(code: str):
    _require_known_code(code)
    cache_key = f"quote:{code}"
    cached = cache.get(cache_key)
    if cached is not None:
        return cached
    data = yfinance_client.fetch_quote(code)
    cache.set(cache_key, data, config.QUOTE_TTL_SECONDS)
    return data


@router.get("/{code}/history")
def get_history(code: str, range: str = "6mo", interval: str = "1d"):
    _require_known_code(code)
    cache_key = f"history:{code}:{range}:{interval}"
    cached = cache.get(cache_key)
    if cached is not None:
        return cached
    df = yfinance_client.fetch_history(code, range, interval)
    records = yfinance_client.history_to_records(df)
    data = {"code": code, "range": range, "interval": interval, "candles": records}
    cache.set(cache_key, data, config.HISTORY_TTL_SECONDS)
    return data


@router.get("/{code}/technical")
def get_technical(code: str, range: str = "6mo"):
    _require_known_code(code)
    cache_key = f"technical:{code}:{range}"
    cached = cache.get(cache_key)
    if cached is not None:
        return cached
    df = yfinance_client.fetch_history(code, range, "1d")
    if df.empty:
        raise HTTPException(status_code=404, detail="no price history available")
    data = indicators.compute(df)
    data["code"] = code
    cache.set(cache_key, data, config.HISTORY_TTL_SECONDS)
    return data


@router.get("/{code}/fundamentals")
def get_fundamentals(code: str):
    _require_known_code(code)
    cache_key = f"fundamentals:{code}"
    cached = cache.get(cache_key)
    if cached is not None:
        return cached
    data = yfinance_client.fetch_fundamentals(code)
    master_entry = master.lookup(code)
    if master_entry is not None:
        data["name"] = master_entry["name"]
    cache.set(cache_key, data, config.FUNDAMENTALS_TTL_SECONDS)
    return data


@router.get("/{code}/signal")
def get_signal(code: str):
    _require_known_code(code)
    cache_key = f"signal:{code}"
    cached = cache.get(cache_key)
    if cached is not None:
        return cached
    df = yfinance_client.fetch_history(code, "6mo", "1d")
    if df.empty:
        raise HTTPException(status_code=404, detail="no price history available")
    tech = indicators.compute(df)
    fund = yfinance_client.fetch_fundamentals(code)
    data = signal.evaluate(tech, fund)
    data["code"] = code
    cache.set(cache_key, data, config.QUOTE_TTL_SECONDS)
    return data
