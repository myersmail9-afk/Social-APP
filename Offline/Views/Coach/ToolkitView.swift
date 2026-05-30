import SwiftUI

/// The Toolkit — a browsable list of practical, supportive tactics for using
/// your phone less, tagged by how big a change they ask for.
struct ToolkitView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Pick one. You don't have to do them all — one small change this week is a win.")
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)

                ForEach(store.toolkit) { tip in
                    ToolkitCard(tip: tip)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Toolkit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ToolkitCard: View {
    let tip: ToolkitTip
    @State private var expanded = false

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: tip.icon)
                        .font(.title3).foregroundStyle(Theme.accent)
                        .frame(width: 28)
                    Text(tip.title).font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(tip.difficulty.title)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(tip.difficulty.color.opacity(0.18), in: Capsule())
                        .foregroundStyle(tip.difficulty.color)
                }
                if expanded {
                    Text(tip.detail).font(.subheadline).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.spring(response: 0.3)) { expanded.toggle() } }
    }
}

#Preview {
    NavigationStack {
        ToolkitView()
            .environment(previewStore())
    }
}
