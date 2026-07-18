from typing import Optional

DISCLAIMER = "この評価は登録済みルールに基づく機械的な目安であり、投資助言ではありません。投資判断はご自身の責任で行ってください。"

LABELS = {
    2: "強い強気",
    1: "やや強気",
    0: "中立",
    -1: "やや弱気",
    -2: "強い弱気",
}


def _bucket(score: int) -> int:
    if score >= 3:
        return 2
    if score >= 1:
        return 1
    if score >= -1:
        return 0
    if score >= -3:
        return -1
    return -2


def _technical_score(tech: dict) -> tuple:
    latest = tech.get("latest", {})
    reasons = []
    score = 0

    sma5, sma25, sma75 = latest.get("sma5"), latest.get("sma25"), latest.get("sma75")
    if sma5 is not None and sma25 is not None and sma75 is not None:
        if sma5 > sma25 > sma75:
            score += 1
            reasons.append("移動平均が短期>中期>長期の順で並ぶ上昇トレンド")
        elif sma5 < sma25 < sma75:
            score -= 1
            reasons.append("移動平均が短期<中期<長期の順で並ぶ下降トレンド")

    rsi = latest.get("rsi14")
    if rsi is not None:
        if rsi < 30:
            score += 1
            reasons.append(f"RSI({rsi})が30を下回り売られすぎ水準")
        elif rsi > 70:
            score -= 1
            reasons.append(f"RSI({rsi})が70を上回り買われすぎ水準")

    macd_hist = latest.get("macd_hist")
    if macd_hist is not None:
        if macd_hist > 0:
            score += 1
            reasons.append("MACDがシグナルを上回り上昇モメンタム")
        elif macd_hist < 0:
            score -= 1
            reasons.append("MACDがシグナルを下回り下降モメンタム")

    return score, reasons


def _fundamental_score(fund: dict) -> tuple:
    reasons = []
    score = 0

    per = fund.get("per")
    if per is not None:
        if per < 10:
            score += 1
            reasons.append(f"PER({per})が10倍未満で割安水準")
        elif per > 25:
            score -= 1
            reasons.append(f"PER({per})が25倍超で割高水準")

    pbr = fund.get("pbr")
    if pbr is not None:
        if pbr < 1:
            score += 1
            reasons.append(f"PBR({pbr})が1倍未満で解散価値割れ")
        elif pbr > 3:
            score -= 1
            reasons.append(f"PBR({pbr})が3倍超で割高水準")

    roe = fund.get("roe")
    if roe is not None:
        if roe > 0.10:
            score += 1
            reasons.append(f"ROE({round(roe * 100, 1)}%)が10%超で資本効率が高い")
        elif roe < 0.03:
            score -= 1
            reasons.append(f"ROE({round(roe * 100, 1)}%)が3%未満で資本効率が低い")

    return score, reasons


def evaluate(tech: dict, fund: dict) -> dict:
    technical_score, technical_reasons = _technical_score(tech)
    fundamental_score, fundamental_reasons = _fundamental_score(fund)
    total_score = technical_score + fundamental_score
    bucket = _bucket(total_score)

    return {
        "label": LABELS[bucket],
        "level": bucket,
        "technical_score": technical_score,
        "fundamental_score": fundamental_score,
        "total_score": total_score,
        "reasons": technical_reasons + fundamental_reasons,
        "disclaimer": DISCLAIMER,
    }
