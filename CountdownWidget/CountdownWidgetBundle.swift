import WidgetKit
import SwiftUI

// MARK: - Widget Bundle
// Registra tutti i widget esposti dall'extension.

@main
struct CountdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountdownWidget()
    }
}

// MARK: - Widget Declaration

struct CountdownWidget: Widget {
    static let kind = "CountdownWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: Self.kind,
            intent: EventWidgetIntent.self,
            provider: EventTimelineProvider()
        ) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Countdown")
        .description("Mostra il conto alla rovescia verso un evento.")
        // HIG: offri tutte le taglie sensate così l'utente sceglie
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
