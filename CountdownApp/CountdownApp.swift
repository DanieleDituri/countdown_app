import SwiftUI

@main
struct CountdownApp: App {
    @StateObject private var store = EventStore()
    @StateObject private var updater = UpdateChecker()
    @AppStorage("hideFromDock") private var hideFromDock = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .task {
                    NSApp.setActivationPolicy(hideFromDock ? .accessory : .regular)
                    updater.check()
                }
                .alert("Aggiornamento disponibile", isPresented: $updater.updateAvailable) {
                    Button("Scarica \(updater.latestVersion)") {
                        if let url = updater.releaseURL { NSWorkspace.shared.open(url) }
                    }
                    Button("Dopo", role: .cancel) {}
                } message: {
                    Text("È disponibile una nuova versione di CountdownApp.")
                }
        }
        .commands {
            AppCommands()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)

        Settings {
            SettingsView()
        }

        MenuBarExtra {
            MenuBarMenu()
                .environmentObject(store)
        } label: {
            MenuBarLabel()
                .environmentObject(store)
        }
        .menuBarExtraStyle(.menu)
    }
}
