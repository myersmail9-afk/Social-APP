import SwiftUI

/// A list of categories with proportional bars — the "what is my time going to"
/// view that the user asked for.
struct CategoryBreakdown: View {
    let breakdown: [CategoryUsage]

    private var total: Int { max(breakdown.reduce(0) { $0 + $1.minutes }, 1) }

    var body: some View {
        VStack(spacing: 14) {
            ForEach(breakdown.sorted { $0.minutes > $1.minutes }) { item in
                CategoryRow(item: item, total: total)
            }
        }
    }
}

private struct CategoryRow: View {
    let item: CategoryUsage
    let total: Int

    private var fraction: Double { Double(item.minutes) / Double(total) }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: item.category.systemImage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(item.category.color)
                    .frame(width: 22)
                Text(item.category.title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(item.minutes.asDuration)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.tertiarySystemFill))
                    Capsule()
                        .fill(item.category.color)
                        .frame(width: max(6, geo.size.width * fraction))
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    CategoryBreakdown(breakdown: [
        CategoryUsage(category: .social, minutes: 52),
        CategoryUsage(category: .entertainment, minutes: 41),
        CategoryUsage(category: .productivity, minutes: 38),
        CategoryUsage(category: .music, minutes: 25)
    ])
    .padding()
}
