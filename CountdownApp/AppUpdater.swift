import Sparkle
import SwiftUI

// Wrapper per usare SPUStandardUpdaterController con SwiftUI
final class AppUpdater: ObservableObject {
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }

    var canCheckForUpdates: Bool {
        updaterController.updater.canCheckForUpdates
    }
}
