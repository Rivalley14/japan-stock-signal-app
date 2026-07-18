import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var results: [StockSummary] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List(results) { stock in
                NavigationLink(value: stock.code) {
                    VStack(alignment: .leading) {
                        Text(stock.name).font(.headline)
                        Text("\(stock.code) ・ \(stock.sector)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .overlay {
                if let errorMessage {
                    ContentUnavailableView(errorMessage, systemImage: "wifi.slash")
                } else if results.isEmpty && !query.isEmpty {
                    ContentUnavailableView.search
                }
            }
            .safeAreaInset(edge: .bottom) {
                BannerAdView()
            }
            .navigationTitle("銘柄検索")
            .navigationDestination(for: String.self) { code in
                StockDetailView(code: code)
            }
            .searchable(text: $query, prompt: "銘柄名またはコードで検索")
            .task(id: query) {
                await search()
            }
        }
    }

    private func search() async {
        guard !query.isEmpty else {
            results = []
            errorMessage = nil
            return
        }
        do {
            results = try await APIClient.shared.search(query: query)
            errorMessage = nil
        } catch {
            errorMessage = "検索に失敗しました。バックエンドサーバーが起動しているか確認してください。"
        }
    }
}

#Preview {
    SearchView()
}
