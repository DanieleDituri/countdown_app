import SwiftUI

// MARK: - Event Form
// HIG: i form su macOS usano .formStyle(.grouped) con Section e LabeledContent.
// Il foglio (sheet) è la presentazione corretta per la creazione di nuovi record.
// Il pulsante "Aggiungi" è il default action (⌘Return), "Annulla" è .cancelAction (Esc).

struct EventFormView: View {
    @EnvironmentObject var store: EventStore
    @Environment(\.dismiss) private var dismiss

    let existingEvent: CountdownEvent?

    @State private var name: String
    @State private var date: Date
    @State private var emoji: String
    @State private var colorHex: String

    init(event: CountdownEvent?) {
        existingEvent = event
        _name     = State(initialValue: event?.name     ?? "")
        _date     = State(initialValue: event?.date     ?? Calendar.current.date(byAdding: .month, value: 1, to: Date())!)
        _emoji    = State(initialValue: event?.emoji    ?? "📅")
        _colorHex = State(initialValue: event?.colorHex ?? "#007AFF")
    }

    private var isEditing: Bool { existingEvent != nil }
    private var isValid: Bool   { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            // HIG: l'header del foglio identifica chiaramente l'azione
            Text(isEditing ? "Modifica Evento" : "Nuovo Evento")
                .font(.headline)
                .padding(.top, 20)
                .padding(.bottom, 16)

            Form {
                // MARK: Informazioni base
                Section {
                    TextField("Nome", text: $name)
                    DatePicker("Data", selection: $date, displayedComponents: .date)
                }

                // MARK: Emoji
                // HIG: usa una griglia compatta; evidenzia la selezione con l'accent color
                Section("Icona") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(36)), count: 9),
                        spacing: 4
                    ) {
                        ForEach(emojiPalette, id: \.self) { e in
                            Button {
                                emoji = e
                            } label: {
                                Text(e)
                                    .font(.title3)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(emoji == e
                                                  ? Color.accentColor.opacity(0.18)
                                                  : Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(e)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // MARK: Colore
                // HIG: i swatch colore devono essere abbastanza grandi da toccare
                // e indicare chiaramente quale è selezionato.
                Section("Colore") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(28)), count: 10),
                        spacing: 6
                    ) {
                        ForEach(paletteColors, id: \.hex) { item in
                            Button {
                                colorHex = item.hex
                            } label: {
                                Circle()
                                    .fill(Color.fromHex(item.hex) ?? .accentColor)
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        // HIG: indicatore di selezione ben visibile in light e dark mode
                                        Circle()
                                            .strokeBorder(Color.primary, lineWidth: colorHex == item.hex ? 2 : 0)
                                            .padding(-3)
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(item.name)
                            .accessibilityAddTraits(colorHex == item.hex ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 4)
                }

                // MARK: Anteprima
                Section("Anteprima") {
                    HStack {
                        Spacer()
                        MiniCountdownPreview(
                            emoji: emoji,
                            name: name.isEmpty ? "Nome evento" : name,
                            date: date,
                            colorHex: colorHex
                        )
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .formStyle(.grouped)

            // MARK: Azioni
            // HIG: i bottoni sono allineati a destra; il default action è prominente.
            HStack {
                Button("Annulla") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(isEditing ? "Salva" : "Aggiungi") {
                    commit()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 8)
        }
        .frame(width: 460, height: 560)
    }

    private func commit() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if isEditing, var updated = existingEvent {
            updated.name     = trimmed
            updated.date     = date
            updated.emoji    = emoji
            updated.colorHex = colorHex
            store.update(updated)
        } else {
            store.add(CountdownEvent(name: trimmed, date: date, emoji: emoji, colorHex: colorHex))
        }
        dismiss()
    }
}

// MARK: - Mini Preview
// Mostra l'aspetto della card mentre si configura l'evento.

struct MiniCountdownPreview: View {
    let emoji: String
    let name: String
    let date: Date
    let colorHex: String

    private var daysRemaining: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let target = cal.startOfDay(for: date)
        return cal.dateComponents([.day], from: today, to: target).day ?? 0
    }

    private var accent: Color { Color.fromHex(colorHex) ?? .accentColor }

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji).font(.system(size: 28))
            let d = daysRemaining
            Group {
                if d == 0 {
                    Text("Oggi")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                } else {
                    Text("\(abs(d))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }
            }
            .foregroundStyle(accent)
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(accent.opacity(0.3), lineWidth: 1)
        )
    }
}
