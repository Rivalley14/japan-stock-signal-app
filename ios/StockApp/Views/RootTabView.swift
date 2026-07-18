import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            ScreenerView()
                .tabItem { Label("トレンド分析", systemImage: "chart.xyaxis.line") }

            SearchView()
                .tabItem { Label("検索", systemImage: "magnifyingglass") }

            WatchlistView()
                .tabItem { Label("ウォッチリスト", systemImage: "star.fill") }

            HelpView()
                .tabItem { Label("ヘルプ", systemImage: "questionmark.circle") }
        }
    }
}

#Preview {
    RootTabView()
}
