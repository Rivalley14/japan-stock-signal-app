import math
from typing import Any, Optional

import pandas as pd
import yfinance as yf


def _to_yahoo_symbol(code: str) -> str:
    return f"{code}.T"


def _clean(value: Any) -> Optional[Any]:
    if value is None:
        return None
    if isinstance(value, float) and math.isnan(value):
        return None
    return value


def fetch_quote(code: str) -> dict:
    ticker = yf.Ticker(_to_yahoo_symbol(code))
    fi = ticker.fast_info
    last_price = _clean(fi.get("lastPrice"))
    previous_close = _clean(fi.get("previousClose"))
    change = None
    change_percent = None
    if last_price is not None and previous_close:
        change = round(last_price - previous_close, 2)
        change_percent = round((last_price - previous_close) / previous_close * 100, 2)
    return {
        "code": code,
        "price": last_price,
        "previous_close": previous_close,
        "change": change,
        "change_percent": change_percent,
        "day_high": _clean(fi.get("dayHigh")),
        "day_low": _clean(fi.get("dayLow")),
        "volume": _clean(fi.get("lastVolume")),
        "currency": _clean(fi.get("currency")),
    }


def fetch_history(code: str, range_: str, interval: str) -> pd.DataFrame:
    ticker = yf.Ticker(_to_yahoo_symbol(code))
    df = ticker.history(period=range_, interval=interval, auto_adjust=False)
    return df


def history_to_records(df: pd.DataFrame) -> list:
    records = []
    for index, row in df.iterrows():
        records.append(
            {
                "date": index.strftime("%Y-%m-%d") if hasattr(index, "strftime") else str(index),
                "open": _clean(round(row["Open"], 2)) if pd.notna(row["Open"]) else None,
                "high": _clean(round(row["High"], 2)) if pd.notna(row["High"]) else None,
                "low": _clean(round(row["Low"], 2)) if pd.notna(row["Low"]) else None,
                "close": _clean(round(row["Close"], 2)) if pd.notna(row["Close"]) else None,
                "volume": _clean(int(row["Volume"])) if pd.notna(row["Volume"]) else None,
            }
        )
    return records


def _round(value: Optional[Any], digits: int = 2) -> Optional[Any]:
    value = _clean(value)
    return round(value, digits) if isinstance(value, (int, float)) else value


def fetch_fundamentals(code: str) -> dict:
    ticker = yf.Ticker(_to_yahoo_symbol(code))
    info = ticker.info
    return {
        "code": code,
        "name": _clean(info.get("longName")) or _clean(info.get("shortName")),
        "per": _round(info.get("trailingPE")),
        "forward_per": _round(info.get("forwardPE")),
        "pbr": _round(info.get("priceToBook")),
        "roe": _round(info.get("returnOnEquity"), 4),
        "roa": _round(info.get("returnOnAssets"), 4),
        "eps": _round(info.get("trailingEps")),
        "dividend_yield_percent": _round(info.get("dividendYield")),
        "market_cap": _clean(info.get("marketCap")),
        "operating_margin": _round(info.get("operatingMargins"), 4),
        "sector": _clean(info.get("sector")),
        "industry": _clean(info.get("industry")),
    }
