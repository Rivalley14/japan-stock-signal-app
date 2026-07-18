import SwiftUI

struct ScreenerView: View {
    private enum Metric: String, CaseIterable {
        case smaShort = "移動平均 短期 (5日/25日)"
        case smaMedium = "移動平均 中長期 (25日/75日)"
        case macd = "MACD"
        case bollinger = "ボリンジャーバンド"
    }

    private struct SectionSpec {
        let title: String
        let items: [CrossItem]
        let tint: Color
    }

    @State private var metric: Metric = .smaShort
    @State private var response: CrossScreenerResponse?
    @State private var errorMessage: String?

    private var sections: [SectionSpec] {
        guard let response else { return [] }
        switch metric {
        case .smaShort:
            return crossSections(response.shortTerm)
        case .smaMedium:
            return crossSections(response.mediumTerm)
        case .macd:
            return crossSections(response.macd)
        case .bollinger:
            let b = response.bollinger
            return [
                SectionSpec(title: "上限バンドブレイク発生", items: b.upperBreak, tint: .red),
                SectionSpec(title: "上限バンドブレイク発生見込み", items: b.upperBreakPending, tint: .orange),
                SectionSpec(title: "下限バンドブレイク発生", items: b.lowerBreak, tint: .blue),
                SectionSpec(title: "下限バンドブレイク発生見込み", items: b.lowerBreakPending, tint: .teal),
            ]
        }
    }

    private func crossSections(_ bucket: CrossBucket) -> [SectionSpec] {
        [
            SectionSpec(title: "ゴールデンクロス発生", items: bucket.goldenCross, tint: .red),
            SectionSpec(title: "ゴールデンクロス発生見込み", items: bucket.goldenCrossPending, tint: .orange),
            SectionSpec(title: "デッドクロス発生", items: bucket.deadCross, tint: .blue),
            SectionSpec(title: "デッドクロス発生見込み", items: bucket.deadCrossPending, tint: .teal),
        ]
    }

    private var updatedAtText: String? {
        guard let response else { return nil }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: response.updatedAt) else { return nil }
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ja_JP")
        displayFormatter.dateFormat = "M月d日 HH:mm"
        return "最終更新: \(displayFormatter.string(from: date))"
    }

    var body: some View {
        NavigationStack {
            List {
                if let updatedAtText {
                    Text(updatedAtText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .listRowSeparator(.hidden)
                }
                ForEach(sections, id: \.title) { spec in
                    section(spec)
                }
            }
            .overlay {
                if let errorMessage {
                    ContentUnavailableView(errorMessage, systemImage: "wifi.slash")
                } else if response == nil {
                    ProgressView("主要銘柄をスキャン中…")
                }
            }
            .safeAreaInset(edge: .bottom) {
                BannerAdView()
            }
            .navigationTitle("トレンド分析")
            .navigationDestination(for: String.self) { code in
                StockDetailView(code: code)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(Metric.allCases, id: \.self) { m in
                            Button {
                                metric = m
                            } label: {
                                if metric == m {
                                    Label(m.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(m.rawValue)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(metric.rawValue)
                                .lineLimit(1)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2.bold())
                        }
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Capsule())
                    }
                }
            }
            .refreshable {
                await load()
            }
            .task {
                if response == nil {
                    await load()
                }
            }
        }
    }

    private func section(_ spec: SectionSpec) -> some View {
        Section(spec.title) {
            if spec.items.isEmpty {
                Text("該当銘柄なし").font(.caption).foregroundStyle(.secondary)
            } else {
                ForEach(spec.items) { item in
                    NavigationLink(value: item.code) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name).font(.subheadline.bold())
                                Text(item.code).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let gapPercent = item.gapPercent {
                                Text(String(format: "乖離 %.2f%%", gapPercent))
                                    .font(.caption)
                                    .foregroundStyle(spec.tint)
                            }
                        }
                    }
                }
            }
        }
    }

    private func load() async {
        do {
            response = try await APIClient.shared.crossScreener()
            errorMessage = nil
        } catch {
            errorMessage = "データの取得に失敗しました。バックエンドサーバーが起動しているか確認してください。"
        }
    }
}

#Preview {
    ScreenerView()
}
