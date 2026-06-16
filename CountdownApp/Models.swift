import Foundation
import SwiftUI
import WidgetKit

// EventStore è il ViewModel dell'app principale.
// Usa SharedStore per la persistenza condivisa con il widget extension.

class EventStore: ObservableObject {
    @Published var events: [CountdownEvent] = []
    @Published var widgetEventIDs: [UUID] = []
    @Published var menuBarEventID: UUID?

    init() { load() }

    // MARK: - Mutations

    func add(_ event: CountdownEvent) {
        events.append(event)
        save()
    }

    func update(_ event: CountdownEvent) {
        guard let idx = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[idx] = event
        save()
    }

    func delete(_ id: UUID) {
        events.removeAll { $0.id == id }
        widgetEventIDs.removeAll { $0 == id }
        if menuBarEventID == id { menuBarEventID = nil }
        save()
    }

    func toggleWidget(_ id: UUID) {
        if widgetEventIDs.contains(id) {
            widgetEventIDs.removeAll { $0 == id }
        } else {
            widgetEventIDs.append(id)
        }
        save()
    }

    func setMenuBar(_ id: UUID?) {
        menuBarEventID = id
        save()
    }

    // MARK: - Derived

    var menuBarEvent: CountdownEvent? {
        guard let id = menuBarEventID else { return nil }
        return events.first { $0.id == id }
    }

    // MARK: - Persistence

    private func save() {
        SharedStore.save(events: events)
        SharedStore.save(widgetIDs: widgetEventIDs)
        SharedStore.save(menuBarID: menuBarEventID)
        // Notifica il widget di ricaricare la timeline
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func load() {
        events        = SharedStore.loadEvents()
        widgetEventIDs = SharedStore.loadWidgetIDs()
        menuBarEventID = SharedStore.loadMenuBarID()
    }
}
