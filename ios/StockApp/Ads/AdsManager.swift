import Foundation
import GoogleMobileAds
import AppTrackingTransparency

enum AdsManager {
    private static var hasInitializedAds = false

    static func initialize() {
        guard !hasInitializedAds else { return }
        hasInitializedAds = true
        MobileAds.shared.start()
    }

    @MainActor
    static func requestTrackingAuthorizationIfNeeded() async {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            initialize()
            return
        }
        // The system prompt can be silently skipped if requested before the
        // window is fully key/foreground (common right after launch), so give
        // the scene a moment to finish becoming active first.
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        _ = await ATTrackingManager.requestTrackingAuthorization()
        initialize()
    }
}
