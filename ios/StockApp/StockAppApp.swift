import SwiftUI
import SwiftData

@main
struct StockAppApp: App {
    init() {
        AdsManager.initialize()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .task {
                    AdsManager.requestTrackingAuthorizationIfNeeded()
                }
        }
        .modelContainer(for: WatchlistItem.self)
    }
}
