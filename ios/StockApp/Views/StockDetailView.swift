import SwiftUI
import SwiftData

struct StockDetailView: View {
    let code: String

    @Environment(\.modelContext) private var modelContext
    @Query private var watchlist: [WatchlistItem]

    @State private var range = "6mo"
    @State private var quote: Quote?
    @State private var history: HistoryResponse?
    @State private var technical: TechnicalResponse?
    @State private var fundamentals: Fundamentals?
    @State private var signal: StockSignal?
    @State private var errorMessage: String?

    private let ranges = ["1mo", "3mo", "6mo", "1y"]

    init(code: String) {
        self.code = code
        let predicate = #Predicate<WatchlistItem> { $0.code == code }
        _watchlist = Query(filter: predicate)
    }

    private var isWatched: Bool { !watchlist.isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let quote {
                    quoteHeader(quote)
                }

                Picker("期間", selection: $range) {
                    ForEach(ranges, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)

                if let history, let technical {
                    PriceChartView(candles: history.candles, series: technical.series)
                    IndicatorSubchartsView(series: technical.series)
                }

                if let signal {
                    SignalCardView(signal: signal)
                }

                if let fundamentals {
                    FundamentalsView(fundamentals: fundamentals)
                }

                if let errorMessage {
                    ContentUnavailableView(errorMessage, systemImage: "wifi.slash")
                }
            }
            .padding()
        }
        .navigationTitle(fundamentals?.name ?? code)
        .toolbar {
            Button {
                toggleWatchlist()
            } label: {
                Image(systemName: isWatched ? "star.fill" : "star")
            }
        }
        .task(id: range) {
            await loadAll()
        }
    }

    private func quoteHeader(_ quote: Quote) -> some View {
        HStack(alignment: .firstTextBaseline) {
            if let price = quote.price {
                Text(String(format: "¥%.1f", price)).font(.largeTitle.bold())
            }
            if let change = quote.change, let changePercent = quote.changePercent {
                Text(String(format: "%+.1f (%+.2f%%)", change, changePercent))
                    .foregroundStyle(change >= 0 ? .red : .blue)
            }
        }
    }

    private func toggleWatchlist() {
        if let existing = watchlist.first {
            modelContext.delete(existing)
        } else {
            let name = fundamentals?.name ?? code
            modelContext.insert(WatchlistItem(code: code, name: name))
        }
    }

    private func loadAll() async {
        errorMessage = nil
        async let quoteTask = APIClient.shared.quote(code: code)
        async let historyTask = APIClient.shared.history(code: code, range: range)
        async let technicalTask = APIClient.shared.technical(code: code, range: range)
        async let fundamentalsTask = APIClient.shared.fundamentals(code: code)
        async let signalTask = APIClient.shared.signal(code: code)

        do {
            let (q, h, t, f, s) = try await (quoteTask, historyTask, technicalTask, fundamentalsTask, signalTask)
            quote = q
            history = h
            technical = t
            fundamentals = f
            signal = s
        } catch {
            errorMessage = "データの取得に失敗しました。バックエンドサーバーが起動しているか確認してください。"
        }
    }
}
