import SwiftUI

/// "Coach" tab — the supportive heart of the app. Personalized, never-shaming
/// insights up top (heuristic now, Claude-powered later), and the Toolkit of
/// practical "use your phone less" tactics below. This is where someone who's
/// *losing* a duel still finds a reason to stay and improve.
struct CoachView: View {
    @Environment(AppStore.self) private var store
    @State private var showWrapped = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerCard

                    Button {
                        showWrapped = true
                    } label: {
                        wrappedPromoCard
                    }
                    .buttonStyle(.plain)

                    ForEach(store.insights) { insight in
                        InsightCard(insight: insight)
                    }

                    NavigationLink {
                        ToolkitView()
                    } label: {
                        toolkitPromoCard
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Coach")
            .sheet(isPresented: $showWrapped) {
                WeeklyWrappedView()
            }
        }
    }

    private var wrappedPromoCard: some View {
        Card {
            HStack(spacing: 12) {
                Image(systemName: "gift.fill")
                    .font(.title2).foregroundStyle(Color(hex: 0xFF5C8A))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Weekly Wrapped").font(.headline)
                    Text("A shareable recap of your week — post it and challenge your friends.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
        }
    }

    private var headerCard: some View {
        Card {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(Theme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Coach").font(.headline)
                    Text("Small, doable steps — and credit for every win.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }

    private var toolkitPromoCard: some View {
        Card {
            HStack(spacing: 12) {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.title2).foregroundStyle(Theme.good)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Open the Toolkit").font(.headline)
                    Text("Practical ways to cut screen time — pick one to try today.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
        }
    }
}

private struct InsightCard: View {
    let insight: CoachInsight

    var body: some View {
        Card {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: insight.tone.systemImage)
                    .font(.title3)
                    .foregroundStyle(insight.tone.color)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title).font(.subheadline.weight(.semibold))
                    Text(insight.message).font(.subheadline).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    CoachView()
        .environment(previewStore())
}
