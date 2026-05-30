import SwiftUI

/// Lightweight color/typography helpers so the whole app stays visually
/// consistent. Kept intentionally small — extend as the brand matures.
enum Theme {
    static let accent = Color(hex: 0x6C5CE7)
    static let accentSoft = Color(hex: 0x6C5CE7).opacity(0.15)
    static let good = Color(hex: 0x22C55E)
    static let warn = Color(hex: 0xF59E0B)
    static let over = Color(hex: 0xEF4444)

    static let cardCornerRadius: CGFloat = 20
}

extension Color {
    /// Create a color from a 0xRRGGBB integer.
    init(hex: Int, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

extension Int {
    /// Format a minutes count as a friendly "2h 15m" / "45m" string.
    var asDuration: String {
        let hours = self / 60
        let minutes = self % 60
        if hours > 0 && minutes > 0 { return "\(hours)h \(minutes)m" }
        if hours > 0 { return "\(hours)h" }
        return "\(minutes)m"
    }
}

/// A reusable card container used across the app.
struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
    }
}
