import SwiftUI

@main
struct CountdownApp: App {
    @StateObject private var store = EventStore()
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
