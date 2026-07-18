import SwiftUI

struct SignalCardView: View {
    let signal: StockSignal

    private var color: Color {
        switch signal.level {
        case 2: return .red
        case 1: return .orange
        case 0: return .gray
        case -1: return .teal
        default: return .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("総合シグナル").font(.headline)
                Spacer()
                Text(signal.label)
                    .font(.headline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.15))
                    .foregroundStyle(color)
                    .clipShape(Capsule())
            }

            ForEach(signal.reasons, id: \.self) { reason in
                Label(reason, systemImage: "circle.fill")
                    .labelStyle(.titleOnly)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(signal.disclaimer)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
