import SwiftUI

@main
struct CountdownApp: App {
    @StateObject private var store = EventStore()
    @StateObject private var appUpdater = AppUpdater()
    @AppStorage("hideFromDock") private var hideFromDock = false
    @AppStorage("lastSeenVersion") private var lastSeenVersion = ""
    @State private var showWhatsNew = false

    private var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .task {
                    NSApp.setActivationPolicy(hideFromDock ? .accessory : .regular)
                    if lastSeenVersion != currentVersion {
                        showWhatsNew = true
                        lastSeenVersion = currentVersion
                    }
                }
                .sheet(isPresented: $showWhatsNew) {
                    WhatsNewView(version: currentVersion) {
                        showWhatsNew = false
                    }
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
