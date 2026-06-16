import AppIntents
import WidgetKit

// Quando l'utente preme il bottone nel widget, il sistema mostra automaticamente
// un picker con tutti gli eventi (grazie a @Parameter + requestValueDialog).
// L'evento scelto viene salvato in UserDefaults e la timeline si ricarica.

struct SelectEventIntent: AppIntent {
    static let title: LocalizedStringResource = "Cambia evento"
    static let description = IntentDescription("Scegli quale evento mostrare nel widget.")

    @Parameter(
        title: "Evento",
        requestValueDialog: IntentDialog("Quale evento vuoi mostrare?")
    )
    var event: EventEntity

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: appGroupID) ?? .standard
        defaults.set(event.id.uuidString, forKey: "widgetStartEventID")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
