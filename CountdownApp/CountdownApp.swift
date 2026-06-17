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
                    appUpdater.checkForUpdates()
                    if lastSeenVersion != currentVersion {
                        showWhatsNew = true
                        lastSeenVersion = currentVersion
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
                    if hideFromDock {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
                .sheet(isPresented: $showWhatsNew) {
                    WhatsNewView(version: currentVersion) {
                        showWhatsNew = false
                    }
                }
                .alert("Aggiornamento disponibile", isPresented: $appUpdater.updateAvailable) {
                    Button("Scarica \(appUpdater.latestVersion)") {
                        if let url = appUpdater.releaseURL { NSWorkspace.shared.open(url) }
                    }
                    Button("Dopo", role: .cancel) {}
                } message: {
                    Text("È disponibile una nuova versione di CountdownApp.")
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
