import SwiftUI

/// Sheet for starting a new duel: pick how long, then pick a rival — or hit
/// "Surprise me" to get randomly matched.
struct StartDuelView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var period: Duel.Period = .week
    @State private var wager: Int = 0
    @State private var isStarting = false
    @State private var errorMessage: String?

    private let wagerOptions = [0, 10, 25, 50, 100]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How long?").font(.headline)
                    Picker("Period", selection: $period) {
                        ForEach(Duel.Period.allCases) { p in
                            Text(p.title).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(period.tagline + "  ·  +\(period.points) pts to win")
                        .font(.caption).foregroundStyle(.secondary)

                    HStack {
                        Text("Stake").font(.headline)
                        Spacer()
                        Label("\(store.standing.coins)", systemImage: "circle.hexagongrid.fill")
                            .font(.subheadline).foregroundStyle(Theme.warn)
                    }
                    .padding(.top, 4)
                    Picker("Stake", selection: $wager) {
                        ForEach(wagerOptions, id: \.self) { amount in
                            Text(amount == 0 ? "None" : "\(amount)").tag(amount)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(isStarting)
                    Text(wager == 0
                         ? "A friendly duel — just points and pride."
                         : "Winner takes the \(wager * 2)-coin pot. Both of you stake \(wager).")
                        .font(.caption).foregroundStyle(.secondary)

                    Button {
                        start(opponentID: nil)
                    } label: {
                        Label("Surprise me — random match", systemImage: "dice.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .foregroundStyle(.white)
                    }
                    .disabled(isStarting)

                    Text("Or challenge a friend").font(.headline).padding(.top, 4)
                    ForEach(store.friends) { friend in
                        Button {
                            start(opponentID: friend.id)
                        } label: {
                            HStack(spacing: 12) {
                                Avatar(user: friend, size: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(friend.name).font(.subheadline.weight(.medium))
                                    Text("@\(friend.handle)").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "bolt.fill").foregroundStyle(Theme.accent)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemBackground)))
                        }
                        .buttonStyle(.plain)
                        .disabled(isStarting)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("New Duel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Couldn't start duel", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func start(opponentID: UUID?) {
        isStarting = true
        Task {
            do {
                try await store.startDuel(opponentID: opponentID, period: period, wager: wager)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isStarting = false
        }
    }
}

#Preview {
    StartDuelView()
        .environment(previewStore())
}
