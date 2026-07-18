import json
from datetime import datetime, timezone
from pathlib import Path

from ta.trend import MACD, SMAIndicator
from ta.volatility import BollingerBands

from app import cache
from app.services import cross_detector, master, yfinance_client

UNIVERSE_PATH = Path(__file__).parent.parent / "data" / "primary_universe.json"
CACHE_KEY = "screener:crosses"
CACHE_TTL_SECONDS = 30 * 24 * 60 * 60

_universe = json.loads(UNIVERSE_PATH.read_text(encoding="utf-8"))

SMA_TIMEFRAMES = {
    "short_term": (5, 25),
    "medium_term": (25, 75),
}

CROSS_BUCKETS = ["golden_cross", "golden_cross_pending", "dead_cross", "dead_cross_pending"]
BOLLINGER_BUCKETS = ["upper_break", "upper_break_pending", "lower_break", "lower_break_pending"]

CATEGORY_BUCKETS = {
    **{tf: CROSS_BUCKETS for tf in SMA_TIMEFRAMES},
    "macd": CROSS_BUCKETS,
    "bollinger": BOLLINGER_BUCKETS,
}


def _empty_result() -> dict:
    return {category: {b: [] for b in buckets} for category, buckets in CATEGORY_BUCKETS.items()}


def _append(result: dict, category: str, bucket: str, code: str, name: str, value_a, value_b, price) -> None:
    gap_percent = round(abs(value_a - value_b) / price * 100, 2) if price else None
    result[category][bucket].append({
        "code": code,
        "name": name,
        "short_ma": round(float(value_a), 2),
        "long_ma": round(float(value_b), 2),
        "gap_percent": gap_percent,
    })


def refresh_cross_screening() -> dict:
    result = _empty_result()

    for code in _universe:
        stock = master.lookup(code)
        if stock is None:
            continue
        try:
            df = yfinance_client.fetch_history(code, "6mo", "1d")
        except Exception:
            continue
        if df.empty:
            continue

        close = df["Close"]
        price = close.iloc[-1]

        smas = {
            window: SMAIndicator(close, window=window).sma_indicator()
            for window in {5, 25, 75}
        }
        for timeframe, (short_window, long_window) in SMA_TIMEFRAMES.items():
            bucket = cross_detector.classify(smas[short_window], smas[long_window], close)
            if bucket is None:
                continue
            _append(
                result, timeframe, bucket, code, stock["name"],
                smas[short_window].dropna().iloc[-1], smas[long_window].dropna().iloc[-1], price,
            )

        macd_ind = MACD(close)
        macd_line = macd_ind.macd()
        macd_signal = macd_ind.macd_signal()
        bucket = cross_detector.classify(macd_line, macd_signal, close)
        if bucket is not None:
            _append(
                result, "macd", bucket, code, stock["name"],
                macd_line.dropna().iloc[-1], macd_signal.dropna().iloc[-1], price,
            )

        bb = BollingerBands(close, window=20, window_dev=2)
        bb_high = bb.bollinger_hband()
        bb_low = bb.bollinger_lband()

        upper_bucket = cross_detector.classify(close, bb_high, close)
        if upper_bucket in ("golden_cross", "golden_cross_pending"):
            mapped = "upper_break" if upper_bucket == "golden_cross" else "upper_break_pending"
            _append(result, "bollinger", mapped, code, stock["name"], price, bb_high.dropna().iloc[-1], price)

        lower_bucket = cross_detector.classify(close, bb_low, close)
        if lower_bucket in ("dead_cross", "dead_cross_pending"):
            mapped = "lower_break" if lower_bucket == "dead_cross" else "lower_break_pending"
            _append(result, "bollinger", mapped, code, stock["name"], price, bb_low.dropna().iloc[-1], price)

    payload = {
        "updated_at": datetime.now(timezone.utc).isoformat(),
        **result,
    }
    cache.set(CACHE_KEY, payload, CACHE_TTL_SECONDS)
    return payload


def get_cross_screening() -> dict:
    cached = cache.get(CACHE_KEY)
    if cached is not None:
        return cached
    return refresh_cross_screening()
