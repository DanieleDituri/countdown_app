import SwiftUI

@MainActor
class AppUpdater: ObservableObject {
    @Published var updateAvailable = false
    @Published var latestVersion = ""
    @Published var releaseURL: URL?

    private let repo = "DanieleDituri/countdown_app"

    func checkForUpdates() {
        guard let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest") else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tag = json["tag_name"] as? String,
                      let htmlURL = json["html_url"] as? String else { return }
                let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
                let remote = tag.trimmingCharacters(in: CharacterSet(charactersIn: "v"))
                guard remote != current else { return }
                if remote.compare(current, options: .numeric) == .orderedDescending {
                    latestVersion = remote
                    releaseURL = URL(string: htmlURL)
                    updateAvailable = true
                }
            } catch {}
        }
    }

    var canCheckForUpdates: Bool { true }
}
