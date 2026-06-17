import SwiftUI
import WidgetKit

// Porta l'app in primo piano anche in modalità accessory (nascosta dal Dock).
// Rimane in .regular finché la finestra è aperta; torna .accessory quando
// l'utente la chiude o cambia app — gestito dall'AppDelegate in CountdownApp.swift.
private func bringAppToFront() {
    guard UserDefaults.standard.bool(forKey: "hideFromDock") else {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first(where: { $0.canBecomeMain })?.makeKeyAndOrderFront(nil)
        return
    }
    NSApp.setActivationPolicy(.regular)
    DispatchQueue.main.async {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first(where: { $0.canBecomeMain })?.makeKeyAndOrderFront(nil)
    }
}

// MARK: - Menu Bar Label
// Sempre visibile nella barra: "🎉 42g" oppure "📅" se nessun evento è pinnato.
// HIG: testo breve, leggibile, aggiornato automaticamente.

struct MenuBarLabel: View {
    @EnvironmentObject var store: EventStore
    @State private var now = Date()

    // Timer per aggiornare il label a mezzanotte (i giorni cambiano)
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if let event = store.menuBarEvent {
                let d = event.daysRemaining
                let title = event.name.count > 14 ? String(event.name.prefix(14)) + "…" : event.name
                switch d {
                case 0:        Text("\(event.emoji) \(title) · oggi")
                case 1:        Text("\(event.emoji) \(title) · domani")
                case ..<0:     Text("\(event.emoji) \(title) · \(abs(d))g fa")
                default:       Text("\(event.emoji) \(title) · \(d)g")
                }
            } else {
                // Nessun evento selezionato: icona neutra
                Label("Countdown", systemImage: "calendar.badge.clock")
                    .labelStyle(.iconOnly)
            }
        }
        .onReceive(timer) { now = $0 }
    }
}

// MARK: - Menu Bar Menu
// Dropdown standard macOS: mostra l'evento attivo, poi la lista per cambiarlo,
// poi le azioni di sistema. Niente finestre custom — solo NSMenu nativo.

struct MenuBarMenu: View {
    @EnvironmentObject var store: EventStore

    var body: some View {
        // ── Evento corrente ─────────────────────────────────────────────────
        if let event = store.menuBarEvent {
            // Header non interattivo: riepilogo evento
            Text("\(event.emoji)  \(event.name)")
                .font(.headline)
            Text(event.date.formatted(date: .complete, time: .omitted))
                .foregroundStyle(.secondary)
            Divider()
        } else {
            Text("Nessun evento selezionato")
                .foregroundStyle(.secondary)
            Divider()
        }

        // ── Cambia evento ────────────────────────────────────────────────────
        if !store.events.isEmpty {
            ForEach(store.events) { event in
                let isPinned = store.menuBarEventID == event.id
                Button {
                    store.setMenuBar(isPinned ? nil : event.id)
                } label: {
                    // HIG: checkmark indica lo stato selezionato nel menu
                    Label {
                        HStack {
                            Text("\(event.emoji)  \(event.name)")
                            Spacer()
                            Text(event.countdownLabel)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: isPinned ? "checkmark" : "")
                    }
                }
            }
            Divider()
        }

        // ── Azioni ──────────────────────────────────────────────────────────
        Button("Nuovo Evento") {
            bringAppToFront()
            NotificationCenter.default.post(name: .newEvent, object: nil)
        }

        Button("Apri Countdown") {
            bringAppToFront()
        }

        SettingsLink {
            Text("Impostazioni…")
        }

        Divider()

        Button("Esci") {
            NSApp.terminate(nil)
        }
    }
}
