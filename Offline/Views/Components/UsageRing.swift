import SwiftUI

/// A circular progress ring showing today's usage against the daily goal.
/// Green when under goal, amber as it approaches, red when over.
struct UsageRing: View {
    let usedMinutes: Int
    let goalMinutes: Int
    var lineWidth: CGFloat = 16

    private var fraction: Double {
        guard goalMinutes > 0 else { return 0 }
        return min(Double(usedMinutes) / Double(goalMinutes), 1.0)
    }

    private var tint: Color {
        let ratio = Double(usedMinutes) / Double(max(goalMinutes, 1))
        if ratio <= 0.75 { return Theme.good }
        if ratio <= 1.0 { return Theme.warn }
        return Theme.over
    }

    private var isOver: Bool { usedMinutes > goalMinutes }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.tertiarySystemFill), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: fraction)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: fraction)

            VStack(spacing: 2) {
                Text(usedMinutes.asDuration)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text(isOver ? "over goal" : "of \(goalMinutes.asDuration) goal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        UsageRing(usedMinutes: 95, goalMinutes: 180)
        UsageRing(usedMinutes: 210, goalMinutes: 180)
    }
    .frame(height: 160)
    .padding()
}
