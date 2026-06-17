import SwiftUI

@MainActor
class UpdateChecker: ObservableObject {
    @Published var updateAvailable = false
    @Published var latestVersion = ""
    @Published var releaseURL: URL?

    private let repo = "DanieleDituri/countdown_app"

    func check() {
        guard let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest") else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tag = json["tag_name"] as? String,
                      let htmlURL = json["html_url"] as? String else { return }

                let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
                if tag.trimmingCharacters(in: .init(charactersIn: "v")) > current {
                    latestVersion = tag
                    releaseURL = URL(string: htmlURL)
                    updateAvailable = true
                }
            } catch {}
        }
    }
}
