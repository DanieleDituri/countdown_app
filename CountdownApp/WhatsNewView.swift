import SwiftUI

// Scarica le release notes dalla release GitHub corrispondente alla versione corrente
@MainActor
class WhatsNewLoader: ObservableObject {
    @Published var body = ""
    @Published var isLoading = true

    func load(version: String) {
        Task {
            let tag = "v\(version)"
            guard let url = URL(string: "https://api.github.com/repos/DanieleDituri/countdown_app/releases/tags/\(tag)") else { return }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let notes = json["body"] as? String {
                    body = notes
                }
            } catch {}
            isLoading = false
        }
    }
}

struct WhatsNewView: View {
    let version: String
    var onDismiss: () -> Void

    @StateObject private var loader = WhatsNewLoader()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundStyle(.blue)
                Text("Novità in CountdownApp \(version)")
                    .font(.title2.weight(.bold))
            }
            .padding(.top, 32)
            .padding(.bottom, 20)

            // Corpo
            Group {
                if loader.isLoading {
                    ProgressView()
                        .frame(height: 80)
                } else if loader.body.isEmpty {
                    Text("Nessuna nota disponibile.")
                        .foregroundStyle(.secondary)
                        .frame(height: 80)
                } else {
                    ScrollView {
                        Text(loader.body)
                            .font(.callout)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxHeight: 240)
                }
            }

            Spacer(minLength: 20)

            Button("Continua") { onDismiss() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                .padding(.bottom, 28)
        }
        .frame(width: 420)
        .task { loader.load(version: version) }
    }
}
