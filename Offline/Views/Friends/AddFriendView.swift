import SwiftUI

/// Add a friend by handle. Try @avasingh or @ethanb against the mock backend.
struct AddFriendView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var handle = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var addedName: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Add a friend by their handle to compare screen time and cheer each other on.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    Text("@").foregroundStyle(.secondary)
                    TextField("handle", text: $handle)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.go)
                        .onSubmit(submit)
                }
                .padding()
                .background(Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(Theme.over)
                }
                if let addedName {
                    Label("Added \(addedName)!", systemImage: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(Theme.good)
                }

                Button(action: submit) {
                    HStack {
                        if isSubmitting { ProgressView().tint(.white) }
                        Text("Add friend")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSubmit ? Theme.accent : Color(.systemGray4),
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundStyle(.white)
                }
                .disabled(!canSubmit || isSubmitting)

                Text("Try **avasingh** or **ethanb** to see it work.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Spacer()
            }
            .padding()
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var canSubmit: Bool {
        !handle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submit() {
        guard canSubmit, !isSubmitting else { return }
        errorMessage = nil
        addedName = nil
        isSubmitting = true
        Task {
            do {
                let friend = try await store.addFriend(handle: handle)
                addedName = friend.name
                handle = ""
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}

#Preview {
    AddFriendView()
        .environment(previewStore())
}
