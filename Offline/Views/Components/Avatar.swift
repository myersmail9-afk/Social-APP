import SwiftUI

/// A simple symbol-based avatar with a colored background.
struct Avatar: View {
    let symbol: String
    let colorHex: Int
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [Color(hex: colorHex), Color(hex: colorHex).opacity(0.7)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                in: Circle()
            )
    }
}

extension Avatar {
    init(user: User, size: CGFloat = 44) {
        self.init(symbol: user.avatarSymbol, colorHex: user.avatarColorHex, size: size)
    }
}

#Preview {
    HStack {
        Avatar(symbol: "leaf.fill", colorHex: 0x22C55E)
        Avatar(symbol: "bolt.fill", colorHex: 0xF59E0B, size: 64)
    }
    .padding()
}
