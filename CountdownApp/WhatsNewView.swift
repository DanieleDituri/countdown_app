import SwiftUI

struct WhatsNewItem {
    let icon: String
    let color: Color
    let title: String
    let description: String
}

private let releaseNotes: [String: [WhatsNewItem]] = [
    "0.2": [
        WhatsNewItem(icon: "plus.circle.fill", color: .blue,
                     title: "Nuovo Evento dalla Menu Bar",
                     description: "Aggiungi eventi direttamente dal menu nella barra di sistema."),
        WhatsNewItem(icon: "gear", color: .gray,
                     title: "Impostazioni",
                     description: "Apri al login e nascondi l'app dal Dock tenendola attiva nella menu bar."),
        WhatsNewItem(icon: "arrow.down.circle.fill", color: .green,
                     title: "Aggiornamenti automatici",
                     description: "Dalla prossima versione l'app si aggiornerà senza scaricare il DMG manualmente."),
    ]
]

struct WhatsNewView: View {
    let version: String
    var onDismiss: () -> Void

    private var items: [WhatsNewItem] { releaseNotes[version] ?? [] }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundStyle(.blue)
                Text("Novità in CountdownApp \(version)")
                    .font(.title2.weight(.bold))
            }
            .padding(.top, 32)
            .padding(.bottom, 24)

            // Items
            VStack(alignment: .leading, spacing: 20) {
                ForEach(items, id: \.title) { item in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: item.icon)
                            .font(.title2)
                            .foregroundStyle(item.color)
                            .frame(width: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.body.weight(.semibold))
                            Text(item.description)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer(minLength: 24)

            Button("Continua") { onDismiss() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                .padding(.bottom, 28)
        }
        .frame(width: 420)
        .fixedSize(horizontal: false, vertical: true)
    }
}
