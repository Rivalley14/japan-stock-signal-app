import SwiftUI
import SwiftData

@main
struct StockAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .task {
                    await AdsManager.requestTrackingAuthorizationIfNeeded()
                }
        }
        .modelContainer(for: WatchlistItem.self)
    }
}
