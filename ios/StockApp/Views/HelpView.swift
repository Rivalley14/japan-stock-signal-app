import SwiftUI

struct HelpView: View {
    private struct Term: Identifiable {
        let title: String
        let body: String
        var id: String { title }
    }

    private let usageSteps = [
        ("検索", "銘柄名またはコードで検索し、銘柄をタップすると詳細画面が開きます。"),
        ("銘柄詳細", "価格チャート・テクニカル指標・ファンダメンタル指標・総合シグナルを表示します。右上の星マークをタップするとウォッチリストに追加/削除できます。"),
        ("ウォッチリスト", "登録した銘柄の一覧と現在値・前日比を確認できます。端末内に保存され、アプリを再起動しても保持されます。"),
        ("トレンド分析", "主要銘柄の中から、移動平均クロス・MACD・ボリンジャーバンドの各シグナルが出ている銘柄を一覧表示します。右上のピッカーで指標を切り替えられます。バックグラウンドで定期的に自動更新され、下に引っ張ると手動更新もできます。"),
    ]

    private let technicalTerms = [
        Term(title: "SMA（単純移動平均線）", body: "過去N日間の終値の平均値。5日・25日・75日などの期間で計算し、株価のトレンド方向を把握するために使う。"),
        Term(title: "ゴールデンクロス／デッドクロス", body: "短期の移動平均線が長期の移動平均線を下から上に抜けることを「ゴールデンクロス」（上昇転換のサイン）、上から下に抜けることを「デッドクロス」（下降転換のサイン）と呼ぶ。"),
        Term(title: "RSI（相対力指数）", body: "一定期間の値上がり幅と値下がり幅の比率から算出する0〜100のオシレーター。一般に70以上で買われすぎ、30以下で売られすぎとされる。"),
        Term(title: "MACD", body: "短期と長期の指数移動平均線の差（MACD線）と、その移動平均（シグナル線）を使ったトレンド系指標。MACD線がシグナル線を上抜けすると上昇モメンタム、下抜けすると下降モメンタムのサインとされる。"),
        Term(title: "ボリンジャーバンド", body: "移動平均線を中心に、標準偏差(σ)の幅でバンドを引いた指標。株価が+2σ（上限バンド）を超えると買われすぎ・ブレイクアウト、-2σ（下限バンド）を割り込むと売られすぎ・ブレイクダウンの目安とされる。"),
        Term(title: "ストキャスティクス", body: "一定期間の高値・安値レンジの中で現在値がどの位置にあるかを示すオシレーター。RSIと同様に買われすぎ・売られすぎの判断に使う。"),
        Term(title: "OBV（オンバランスボリューム）", body: "値上がり日の出来高を加算、値下がり日の出来高を減算して積み上げた指標。価格に出来高の勢いが伴っているかを見る。"),
        Term(title: "VWAP（出来高加重平均価格）", body: "出来高で重み付けした平均価格。機関投資家がその日の取引の妥当性を判断する基準としてよく使う。"),
    ]

    private let fundamentalTerms = [
        Term(title: "PER（株価収益率）", body: "株価 ÷ 1株当たり利益（EPS）。株価が利益の何倍まで買われているかを示し、低いほど割安とされる。"),
        Term(title: "PBR（株価純資産倍率）", body: "株価 ÷ 1株当たり純資産。1倍を下回ると理論上の解散価値を下回っている状態とされる。"),
        Term(title: "ROE（自己資本利益率）", body: "自己資本に対してどれだけ利益を上げているかを示す指標。高いほど資本効率が良いとされる。"),
        Term(title: "ROA（総資産利益率）", body: "総資産に対してどれだけ利益を上げているかを示す指標。"),
        Term(title: "EPS（1株当たり利益）", body: "純利益 ÷ 発行済株式数。"),
        Term(title: "配当利回り", body: "株価に対する年間配当金の割合。"),
        Term(title: "時価総額", body: "株価 × 発行済株式数。企業の市場価値の規模を表す。"),
        Term(title: "営業利益率", body: "売上高に対する営業利益の割合。本業の収益力を示す。"),
    ]

    private let signalTerms = [
        Term(title: "総合シグナル", body: "テクニカル指標（移動平均の並び・RSI・MACD）とファンダメンタル指標（PER・PBR・ROE）をルールベースで加点方式で評価し、5段階（強い強気〜強い弱気）で表示したもの。根拠となった指標も一緒に表示される。"),
        Term(title: "発生 / 発生見込み", body: "トレンド分析画面での分類。「発生」は直近3営業日以内にクロス（またはバンドのブレイク）が起きたこと、「発生見込み」はまだ発生していないが両者の乖離が1.5%未満に縮まり、かつ縮小傾向にある状態を指す。"),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("使い方") {
                    ForEach(usageSteps, id: \.0) { step in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.0).font(.subheadline.bold())
                            Text(step.1).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section("用語集: テクニカル指標") {
                    ForEach(technicalTerms) { term in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(term.title).font(.subheadline.bold())
                            Text(term.body).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section("用語集: ファンダメンタル指標") {
                    ForEach(fundamentalTerms) { term in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(term.title).font(.subheadline.bold())
                            Text(term.body).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section("用語集: 総合シグナル・トレンド分析") {
                    ForEach(signalTerms) { term in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(term.title).font(.subheadline.bold())
                            Text(term.body).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section {
                    Text("本アプリの分析結果は登録済みルールに基づく機械的な目安であり、投資助言ではありません。投資判断はご自身の責任で行ってください。")
                        .font(.caption2.bold())
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("ヘルプ")
        }
    }
}

#Preview {
    HelpView()
}
