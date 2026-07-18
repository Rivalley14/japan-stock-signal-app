import SwiftUI
import UIKit
import GoogleMobileAds

// AdMobで実際の広告ユニットIDを発行したら、下記を差し替えてください。
// 現在はGoogle公式のテスト広告ユニットID（本番トラフィックにはカウントされません）です。
private let bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"

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
