import Foundation

struct StockSummary: Codable, Identifiable, Hashable {
    let code: String
    let name: String
    let nameEn: String
    let sector: String

    var id: String { code }
}

struct SearchResponse: Codable {
    let results: [StockSummary]
}

struct Quote: Codable {
    let code: String
    let price: Double?
    let previousClose: Double?
    let change: Double?
    let changePercent: Double?
    let dayHigh: Double?
    let dayLow: Double?
    let volume: Int?
    let currency: String?
}

struct Candle: Codable, Identifiable {
    let date: String
    let open: Double?
    let high: Double?
    let low: Double?
    let close: Double?
    let volume: Int?

    var id: String { date }
}

struct HistoryResponse: Codable {
    let code: String
    let range: String
    let interval: String
    let candles: [Candle]
}

struct SeriesPoint: Codable, Identifiable {
    let date: String
    let value: Double

    var id: String { date }
}

struct TechnicalLatest: Codable {
    let sma5: Double?
    let sma25: Double?
    let sma75: Double?
    let ema25: Double?
    let macd: Double?
    let macdSignal: Double?
    let macdHist: Double?
    let rsi14: Double?
    let bbHigh: Double?
    let bbMid: Double?
    let bbLow: Double?
    let stochK: Double?
    let stochD: Double?
    let obv: Double?
    let vwap: Double?
}

struct TechnicalSeries: Codable {
    let sma5: [SeriesPoint]
    let sma25: [SeriesPoint]
    let sma75: [SeriesPoint]
    let bbHigh: [SeriesPoint]
    let bbMid: [SeriesPoint]
    let bbLow: [SeriesPoint]
    let rsi14: [SeriesPoint]
    let macd: [SeriesPoint]
    let macdSignal: [SeriesPoint]
}

struct TechnicalResponse: Codable {
    let code: String
    let latest: TechnicalLatest
    let series: TechnicalSeries
}

struct Fundamentals: Codable {
    let code: String
    let name: String?
    let per: Double?
    let forwardPer: Double?
    let pbr: Double?
    let roe: Double?
    let roa: Double?
    let eps: Double?
    let dividendYieldPercent: Double?
    let marketCap: Double?
    let operatingMargin: Double?
    let sector: String?
    let industry: String?
}

struct StockSignal: Codable {
    let code: String
    let label: String
    let level: Int
    let technicalScore: Int
    let fundamentalScore: Int
    let totalScore: Int
    let reasons: [String]
    let disclaimer: String
}

struct CrossItem: Codable, Identifiable, Hashable {
    let code: String
    let name: String
    let shortMa: Double
    let longMa: Double
    let gapPercent: Double?

    var id: String { code }
}

struct CrossBucket: Codable {
    let goldenCross: [CrossItem]
    let goldenCrossPending: [CrossItem]
    let deadCross: [CrossItem]
    let deadCrossPending: [CrossItem]
}

struct BollingerBucket: Codable {
    let upperBreak: [CrossItem]
    let upperBreakPending: [CrossItem]
    let lowerBreak: [CrossItem]
    let lowerBreakPending: [CrossItem]
}

struct CrossScreenerResponse: Codable {
    let updatedAt: String
    let shortTerm: CrossBucket
    let mediumTerm: CrossBucket
    let macd: CrossBucket
    let bollinger: BollingerBucket
}
