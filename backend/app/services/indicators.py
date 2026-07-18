import math
from typing import Any, Optional

import pandas as pd
from ta.momentum import RSIIndicator, StochasticOscillator
from ta.trend import EMAIndicator, MACD, SMAIndicator
from ta.volatility import BollingerBands
from ta.volume import OnBalanceVolumeIndicator, VolumeWeightedAveragePrice


def _last(series: pd.Series) -> Optional[Any]:
    if series.empty:
        return None
    value = series.iloc[-1]
    if value is None or (isinstance(value, float) and math.isnan(value)):
        return None
    return round(float(value), 2)


def _series_records(dates: pd.Index, series: pd.Series) -> list:
    records = []
    for date, value in zip(dates, series):
        if value is None or (isinstance(value, float) and math.isnan(value)):
            continue
        records.append({"date": date.strftime("%Y-%m-%d"), "value": round(float(value), 2)})
    return records


def compute(df: pd.DataFrame) -> dict:
    close = df["Close"]
    high = df["High"]
    low = df["Low"]
    volume = df["Volume"]
    dates = df.index

    sma5 = SMAIndicator(close, window=5).sma_indicator()
    sma25 = SMAIndicator(close, window=25).sma_indicator()
    sma75 = SMAIndicator(close, window=75).sma_indicator()
    ema25 = EMAIndicator(close, window=25).ema_indicator()

    macd_ind = MACD(close)
    macd_line = macd_ind.macd()
    macd_signal_line = macd_ind.macd_signal()
    macd_hist = macd_ind.macd_diff()

    rsi14 = RSIIndicator(close, window=14).rsi()

    bb = BollingerBands(close, window=20, window_dev=2)
    bb_high = bb.bollinger_hband()
    bb_low = bb.bollinger_lband()
    bb_mid = bb.bollinger_mavg()

    stoch = StochasticOscillator(high, low, close, window=14, smooth_window=3)
    stoch_k = stoch.stoch()
    stoch_d = stoch.stoch_signal()

    obv = OnBalanceVolumeIndicator(close, volume).on_balance_volume()
    vwap = VolumeWeightedAveragePrice(high, low, close, volume, window=14).volume_weighted_average_price()

    return {
        "latest": {
            "sma5": _last(sma5),
            "sma25": _last(sma25),
            "sma75": _last(sma75),
            "ema25": _last(ema25),
            "macd": _last(macd_line),
            "macd_signal": _last(macd_signal_line),
            "macd_hist": _last(macd_hist),
            "rsi14": _last(rsi14),
            "bb_high": _last(bb_high),
            "bb_mid": _last(bb_mid),
            "bb_low": _last(bb_low),
            "stoch_k": _last(stoch_k),
            "stoch_d": _last(stoch_d),
            "obv": _last(obv),
            "vwap": _last(vwap),
        },
        "series": {
            "sma5": _series_records(dates, sma5),
            "sma25": _series_records(dates, sma25),
            "sma75": _series_records(dates, sma75),
            "bb_high": _series_records(dates, bb_high),
            "bb_mid": _series_records(dates, bb_mid),
            "bb_low": _series_records(dates, bb_low),
            "rsi14": _series_records(dates, rsi14),
            "macd": _series_records(dates, macd_line),
            "macd_signal": _series_records(dates, macd_signal_line),
        },
    }
