import SwiftUI
import Charts

struct PriceChartView: View {
    let candles: [Candle]
    let series: TechnicalSeries
    @State private var showSMA = true
    @State private var showBollinger = false

    private static let seriesColors: KeyValuePairs<String, Color> = [
        "終値": .primary,
        "SMA25": .orange,
        "SMA75": .purple,
        "BB+2σ": .gray,
        "BB-2σ": .gray,
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Toggle("移動平均", isOn: $showSMA).toggleStyle(.button).font(.caption)
                Toggle("ボリンジャーバンド", isOn: $showBollinger).toggleStyle(.button).font(.caption)
            }

            Chart {
                ForEach(candles) { candle in
                    if let close = candle.close {
                        LineMark(
                            x: .value("日付", candle.date),
                            y: .value("価格", close)
                        )
                        .foregroundStyle(by: .value("系列", "終値"))
                        .interpolationMethod(.catmullRom)
                    }
                }

                if showSMA {
                    ForEach(series.sma25) { point in
                        LineMark(x: .value("日付", point.date), y: .value("価格", point.value))
                            .foregroundStyle(by: .value("系列", "SMA25"))
                    }
                    ForEach(series.sma75) { point in
                        LineMark(x: .value("日付", point.date), y: .value("価格", point.value))
                            .foregroundStyle(by: .value("系列", "SMA75"))
                    }
                }

                if showBollinger {
                    ForEach(series.bbHigh) { point in
                        LineMark(x: .value("日付", point.date), y: .value("価格", point.value))
                            .foregroundStyle(by: .value("系列", "BB+2σ"))
                            .lineStyle(StrokeStyle(dash: [4]))
                    }
                    ForEach(series.bbLow) { point in
                        LineMark(x: .value("日付", point.date), y: .value("価格", point.value))
                            .foregroundStyle(by: .value("系列", "BB-2σ"))
                            .lineStyle(StrokeStyle(dash: [4]))
                    }
                }
            }
            .chartForegroundStyleScale(Self.seriesColors)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
            .frame(height: 220)
        }
    }
}

struct IndicatorSubchartsView: View {
    let series: TechnicalSeries

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                Text("RSI (14)").font(.caption).foregroundStyle(.secondary)
                Chart {
                    ForEach(series.rsi14) { point in
                        LineMark(x: .value("日付", point.date), y: .value("RSI", point.value))
                    }
                    RuleMark(y: .value("買われすぎ", 70))
                        .foregroundStyle(.red.opacity(0.5))
                        .lineStyle(StrokeStyle(dash: [4]))
                    RuleMark(y: .value("売られすぎ", 30))
                        .foregroundStyle(.blue.opacity(0.5))
                        .lineStyle(StrokeStyle(dash: [4]))
                }
                .chartYScale(domain: 0...100)
                .chartXAxis(.hidden)
                .frame(height: 100)
            }

            VStack(alignment: .leading) {
                Text("MACD").font(.caption).foregroundStyle(.secondary)
                Chart {
                    ForEach(series.macd) { point in
                        LineMark(x: .value("日付", point.date), y: .value("値", point.value))
                            .foregroundStyle(by: .value("系列", "MACD"))
                    }
                    ForEach(series.macdSignal) { point in
                        LineMark(x: .value("日付", point.date), y: .value("値", point.value))
                            .foregroundStyle(by: .value("系列", "Signal"))
                    }
                }
                .chartForegroundStyleScale([
                    "MACD": Color.blue,
                    "Signal": Color.orange,
                ] as KeyValuePairs<String, Color>)
                .chartXAxis(.hidden)
                .frame(height: 100)
            }
        }
    }
}
