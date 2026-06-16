import SwiftUI

// MARK: - App Commands
// HIG: le app macOS devono esporre azioni chiave nel menu bar dell'applicazione
// con le keyboard shortcut standard di sistema.

struct AppCommands: Commands {
    var body: some Commands {
        // Sostituisce le voci di default del menu File
        CommandGroup(replacing: .newItem) {
            Button("Nuovo Evento") {
                NotificationCenter.default.post(name: .newEvent, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }
}

extension Notification.Name {
    static let newEvent  = Notification.Name("countdown.newEvent")
    static let editEvent = Notification.Name("countdown.editEvent")
}
