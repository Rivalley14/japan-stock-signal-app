import SwiftUI
import SwiftData

struct WatchlistView: View {
    @Query(sort: \WatchlistItem.addedAt, order: .reverse) private var items: [WatchlistItem]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink(value: item.code) {
                        WatchlistRow(item: item)
                    }
                }
                .onDelete(perform: delete)
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("ウォッチリストは空です", systemImage: "star", description: Text("検索タブから銘柄を追加してください"))
                }
            }
            .safeAreaInset(edge: .bottom) {
                BannerAdView()
            }
            .navigationTitle("ウォッチリスト")
            .navigationDestination(for: String.self) { code in
                StockDetailView(code: code)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

private struct WatchlistRow: View {
    let item: WatchlistItem
    @State private var quote: Quote?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name).font(.headline)
                Text(item.code).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if let quote, let price = quote.price {
                VStack(alignment: .trailing) {
                    Text(String(format: "¥%.1f", price))
                    if let changePercent = quote.changePercent {
                        Text(String(format: "%+.2f%%", changePercent))
                            .font(.caption)
                            .foregroundStyle(changePercent >= 0 ? .red : .blue)
                    }
                }
            }
        }
        .task {
            quote = try? await APIClient.shared.quote(code: item.code)
        }
    }
}

#Preview {
    WatchlistView()
}
