import AppIntents
import WidgetKit

// MARK: - AppEntity per CountdownEvent
// Permette al sistema di mostrare un picker nella configurazione del widget
// sulla scrivania: l'utente sceglie quale evento mostrare in ciascuna istanza.

struct EventEntity: AppEntity {
    var id: UUID
    var name: String
    var emoji: String
    var colorHex: String
    var date: Date

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Evento")
    static let defaultQuery = EventEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(emoji) \(name)")
    }
}

// MARK: - EntityQuery

struct EventEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [EventEntity] {
        SharedStore.loadEvents()
            .filter { identifiers.contains($0.id) }
            .map(\.asEntity)
    }

    func suggestedEntities() async throws -> [EventEntity] {
        SharedStore.loadEvents().map(\.asEntity)
    }

    func defaultResult() async -> EventEntity? {
        SharedStore.loadEvents().first?.asEntity
    }
}

private extension CountdownEvent {
    var asEntity: EventEntity {
        EventEntity(id: id, name: name, emoji: emoji, colorHex: colorHex, date: date)
    }
}

// MARK: - Widget Configuration Intent

struct EventWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Evento"
    static let description = IntentDescription("Scegli quale evento visualizzare sul widget.")

    @Parameter(title: "Evento")
    var event: EventEntity?
}
