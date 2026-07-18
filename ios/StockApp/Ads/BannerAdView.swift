import SwiftUI
import UIKit
import GoogleMobileAds

// 日本株シグナル（経験者用）アプリ用のバナー広告ユニットID（AdMob発行）
private let bannerAdUnitID = "ca-app-pub-5270276427916354/2647709591"

struct BannerAdView: View {
    private let adSize = largeAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width)

    var body: some View {
        BannerAdContainer(adSize: adSize)
            .frame(width: adSize.size.width, height: adSize.size.height)
    }
}

private struct BannerAdContainer: UIViewRepresentable {
    let adSize: AdSize

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = bannerAdUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
