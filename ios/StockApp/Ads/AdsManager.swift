import Foundation
import GoogleMobileAds
import AppTrackingTransparency

enum AdsManager {
    static func initialize() {
        MobileAds.shared.start()
    }

    static func requestTrackingAuthorizationIfNeeded() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
}
