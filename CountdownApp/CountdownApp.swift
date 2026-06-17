import SwiftUI

@main
struct CountdownApp: App {
    @StateObject private var store = EventStore()
    @StateObject private var appUpdater = AppUpdater()
    @AppStorage("hideFromDock") private var hideFromDock = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .task {
                    NSApp.setActivationPolicy(hideFromDock ? .accessory : .regular)
                }
        }
        .commands {
            AppCommands()
            CommandGroup(after: .appInfo) {
                Button("Controlla aggiornamenti…") {
                    appUpdater.checkForUpdates()
                }
                .disabled(!appUpdater.canCheckForUpdates)
            }
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
