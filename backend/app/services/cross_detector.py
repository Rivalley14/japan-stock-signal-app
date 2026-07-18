from typing import Optional

import pandas as pd

OCCURRED_WINDOW_DAYS = 3
PENDING_GAP_THRESHOLD = 0.015


def classify(short: pd.Series, long: pd.Series, close: pd.Series) -> Optional[str]:
    df = pd.DataFrame({"short": short, "long": long, "close": close}).dropna()
    if len(df) < OCCURRED_WINDOW_DAYS + 2:
        return None

    diff = df["short"] - df["long"]
    signs = diff > 0
    current_bullish = bool(signs.iloc[-1])

    recent = signs.iloc[-(OCCURRED_WINDOW_DAYS + 1):]
    flipped = recent.ne(recent.shift()).iloc[1:].any()
    if flipped:
        return "golden_cross" if current_bullish else "dead_cross"

    if len(df) < 5:
        return None

    gap_now = abs(diff.iloc[-1])
    gap_prev = abs(diff.iloc[-4])
    price_now = df["close"].iloc[-1]
    if not price_now:
        return None

    gap_pct_now = gap_now / price_now
    narrowing = gap_prev > 0 and gap_now < gap_prev
    if gap_pct_now < PENDING_GAP_THRESHOLD and narrowing:
        return "dead_cross_pending" if current_bullish else "golden_cross_pending"

    return None
