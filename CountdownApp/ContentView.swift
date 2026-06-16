import SwiftUI

// MARK: - Root Content View
// Senza HomeView: l'app gestisce gli eventi, i widget vanno sulla scrivania.

struct ContentView: View {
    @EnvironmentObject var store: EventStore
    @State private var selection: CountdownEvent.ID?
    @State private var showNewEvent = false
    @State private var editingEvent: CountdownEvent?

    var body: some View {
        EventListView(selection: $selection, editingEvent: $editingEvent)
            .frame(minWidth: 320, minHeight: 420)
            .onReceive(NotificationCenter.default.publisher(for: .newEvent)) { _ in
                showNewEvent = true
            }
            .sheet(isPresented: $showNewEvent) {
                EventFormView(event: nil).environmentObject(store)
            }
            .sheet(item: $editingEvent) { event in
                EventFormView(event: event).environmentObject(store)
            }
    }
}

// MARK: - Event List (finestra principale compatta)
// HIG: finestra single-panel per app semplici senza navigazione gerarchica.

struct EventListView: View {
    @EnvironmentObject var store: EventStore
    @Binding var selection: CountdownEvent.ID?
    @Binding var editingEvent: CountdownEvent?
    @State private var showNewEvent = false

    var body: some View {
        List(selection: $selection) {
            if store.events.isEmpty {
                EmptyEventList()
            } else {
                Section("I miei eventi") {
                    ForEach(store.events) { event in
                        EventRow(event: event, editingEvent: $editingEvent)
                            .contextMenu {
                                EventContextMenu(event: event, editingEvent: $editingEvent)
                            }
                            .tag(event.id)
                    }
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Countdown")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showNewEvent = true
                } label: {
                    Label("Nuovo Evento", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
                .help("Nuovo evento (⌘N)")
            }
            ToolbarItem(placement: .automatic) {
                SettingsLink {
                    Label("Impostazioni", systemImage: "gear")
                }
                .help("Impostazioni (⌘,)")
            }
        }
        .sheet(isPresented: $showNewEvent) {
            EventFormView(event: nil).environmentObject(store)
        }
        .onDeleteCommand {
            if let id = selection {
                store.delete(id)
                selection = nil
            }
        }
    }
}

// MARK: - Empty State

struct EmptyEventList: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("Nessun evento")
                .font(.headline)
            Text("Premi + per aggiungere\nun conto alla rovescia.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Event Row

struct EventRow: View {
    @EnvironmentObject var store: EventStore
    let event: CountdownEvent
    @Binding var editingEvent: CountdownEvent?

    var isMenuBar: Bool { store.menuBarEventID == event.id }

    var body: some View {
        Label {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.name)
                        .font(.body)
                    HStack(spacing: 4) {
                        Text(event.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text(event.countdownLabel)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(event.accentColor)
                    }
                }
                Spacer()
                if isMenuBar {
                    Image(systemName: "menubar.rectangle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("In menu bar")
                }
            }
        } icon: {
            ZStack {
                Circle()
                    .fill(event.accentColor.opacity(0.15))
                    .frame(width: 30, height: 30)
                Text(event.emoji)
                    .font(.system(size: 16))
            }
        }
        .accessibilityLabel("\(event.name), \(event.countdownLabel)")
    }
}

// MARK: - Context Menu
// HIG: context menu = tutte le azioni disponibili per l'elemento.

struct EventContextMenu: View {
    @EnvironmentObject var store: EventStore
    let event: CountdownEvent
    @Binding var editingEvent: CountdownEvent?

    var isMenuBar: Bool { store.menuBarEventID == event.id }

    var body: some View {
        Button {
            editingEvent = event
        } label: {
            Label("Modifica evento…", systemImage: "pencil")
        }

        Divider()

        Button {
            store.setMenuBar(isMenuBar ? nil : event.id)
        } label: {
            Label(
                isMenuBar ? "Rimuovi dalla Menu Bar" : "Mostra in Menu Bar",
                systemImage: "menubar.rectangle"
            )
        }

        Divider()

        Button(role: .destructive) {
            store.delete(event.id)
        } label: {
            Label("Elimina evento", systemImage: "trash")
        }
    }
}
