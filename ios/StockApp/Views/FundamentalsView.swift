import SwiftUI

struct FundamentalsView: View {
    let fundamentals: Fundamentals

    private var rows: [(String, String)] {
        var rows: [(String, String)] = []
        if let per = fundamentals.per { rows.append(("PER", String(format: "%.2f倍", per))) }
        if let pbr = fundamentals.pbr { rows.append(("PBR", String(format: "%.2f倍", pbr))) }
        if let roe = fundamentals.roe { rows.append(("ROE", String(format: "%.1f%%", roe * 100))) }
        if let roa = fundamentals.roa { rows.append(("ROA", String(format: "%.1f%%", roa * 100))) }
        if let eps = fundamentals.eps { rows.append(("EPS", String(format: "%.2f円", eps))) }
        if let dividend = fundamentals.dividendYieldPercent { rows.append(("配当利回り", String(format: "%.2f%%", dividend))) }
        if let margin = fundamentals.operatingMargin { rows.append(("営業利益率", String(format: "%.1f%%", margin * 100))) }
        if let marketCap = fundamentals.marketCap { rows.append(("時価総額", formatMarketCap(marketCap))) }
        return rows
    }

    private func formatMarketCap(_ value: Double) -> String {
        let trillion = value / 1_000_000_000_000
        return String(format: "%.1f兆円", trillion)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ファンダメンタル指標").font(.headline)
            if let sector = fundamentals.sector, let industry = fundamentals.industry {
                Text("\(sector) / \(industry)").font(.caption).foregroundStyle(.secondary)
            }
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                ForEach(Array(stride(from: 0, to: rows.count, by: 2)), id: \.self) { i in
                    GridRow {
                        fundRow(rows[i])
                        if i + 1 < rows.count {
                            fundRow(rows[i + 1])
                        }
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func fundRow(_ pair: (String, String)) -> some View {
        VStack(alignment: .leading) {
            Text(pair.0).font(.caption2).foregroundStyle(.secondary)
            Text(pair.1).font(.subheadline.bold())
        }
    }
}
