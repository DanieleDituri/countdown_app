import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @State private var launchAtLogin = (SMAppService.mainApp.status == .enabled)
    @AppStorage("hideFromDock") private var hideFromDock = false

    var body: some View {
        Form {
            Section("Informazioni") {
                LabeledContent("Versione") {
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Generali") {
                Toggle("Apri al login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            launchAtLogin = !newValue
                        }
                    }

                Toggle("Nascondi dal Dock", isOn: $hideFromDock)
                    .onChange(of: hideFromDock) { _, newValue in
                        NSApp.setActivationPolicy(newValue ? .accessory : .regular)
                    }
            }
        }
        .formStyle(.grouped)
        .frame(width: 340, height: 200)
        .onAppear {
            launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }
    }
}
