import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct EventEntry: TimelineEntry {
    let date: Date
    let allEvents: [CountdownEvent]   // tutti gli eventi disponibili
    let visibleEvents: [CountdownEvent] // quelli da mostrare (partendo dall'evento scelto)
}

// MARK: - Timeline Provider

struct EventTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = EventEntry
    typealias Intent = EventWidgetIntent

    func placeholder(in context: Context) -> EventEntry {
        let s = sample
        return EventEntry(date: Date(), allEvents: [s], visibleEvents: [s])
    }

    func snapshot(for configuration: EventWidgetIntent, in context: Context) async -> EventEntry {
        makeEntry(family: context.family)
    }

    func timeline(for configuration: EventWidgetIntent, in context: Context) async -> Timeline<EventEntry> {
        let entry = makeEntry(family: context.family)
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        return Timeline(entries: [entry], policy: .after(midnight))
    }

    // Costruisce l'entry leggendo l'evento di partenza salvato dal SelectEventIntent
    private func makeEntry(family: WidgetFamily) -> EventEntry {
        let all = SharedStore.loadEvents()
        guard !all.isEmpty else {
            return EventEntry(date: Date(), allEvents: [], visibleEvents: [])
        }
        let maxCount = maxEvents(for: family)
        let startIndex = savedStartIndex(in: all)
        // Prende maxCount eventi a partire dall'indice scelto (wrapping)
        var visible: [CountdownEvent] = []
        for i in 0..<maxCount {
            visible.append(all[(startIndex + i) % all.count])
        }
        return EventEntry(date: Date(), allEvents: all, visibleEvents: visible)
    }

    private func savedStartIndex(in events: [CountdownEvent]) -> Int {
        let defaults = UserDefaults(suiteName: appGroupID) ?? .standard
        guard let idStr = defaults.string(forKey: "widgetStartEventID"),
              let id = UUID(uuidString: idStr),
              let idx = events.firstIndex(where: { $0.id == id })
        else { return 0 }
        return idx
    }

    private func maxEvents(for family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall:  return 1
        case .systemMedium: return 2
        case .systemLarge:  return 3
        default:            return 1
        }
    }

    private var sample: CountdownEvent {
        CountdownEvent(
            name: "Apri l'app",
            date: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            emoji: "📅",
            colorHex: "#007AFF"
        )
    }
}

// MARK: - Root Widget View

struct CountdownWidgetView: View {
    let entry: EventEntry
    @Environment(\.widgetFamily) var family

    private var maxCount: Int {
        switch family {
        case .systemSmall:  return 1
        case .systemMedium: return 2
        case .systemLarge:  return 3
        default:            return 1
        }
    }

    var body: some View {
        EventListWidget(
            events: entry.visibleEvents,
            maxCount: maxCount,
            hasMore: entry.allEvents.count > maxCount
        )
        .containerBackground(for: .widget) {
            Color(NSColor.windowBackgroundColor)
        }
    }
}

// MARK: - EventListWidget

struct EventListWidget: View {
    let events: [CountdownEvent]
    let maxCount: Int
    let hasMore: Bool

    var body: some View {
        if events.isEmpty {
            EmptyWidgetView()
        } else if maxCount == 1 {
            SingleEventView(event: events[0], hasMore: hasMore)
        } else {
            MultiEventView(events: events, hasMore: hasMore)
        }
    }
}

// MARK: - Single Event (Small)

struct SingleEventView: View {
    let event: CountdownEvent
    let hasMore: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                Text(event.emoji)
                    .font(.system(size: 32))

                let d = event.daysRemaining
                if d == 0 {
                    Text("Oggi")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(event.accentColor)
                } else {
                    Text("\(abs(d))")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(event.accentColor)
                        .contentTransition(.numericText())
                    Text(d > 0 ? "giorni" : "fa")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.8)
                }

                Text(event.name)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottone cambia evento — in alto a destra
            if hasMore {
                Button(intent: SelectEventIntent()) {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .padding(8)
                .accessibilityLabel("Cambia evento")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.name): \(event.countdownLabel)")
    }
}

// MARK: - Multi Event (Medium=2, Large=3)

struct MultiEventView: View {
    let events: [CountdownEvent]
    let hasMore: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header con bottone cambia
            HStack {
                Text("Countdown")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Spacer()
                if hasMore {
                    Button(intent: SelectEventIntent()) {
                        Image(systemName: "arrow.left.arrow.right.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cambia evento")
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Righe eventi
            ForEach(Array(events.enumerated()), id: \.element.id) { idx, event in
                EventRowView(event: event)
                if idx < events.count - 1 {
                    Divider().padding(.leading, 48)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct EventRowView: View {
    let event: CountdownEvent

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(event.accentColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Text(event.emoji).font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(event.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            let d = event.daysRemaining
            VStack(alignment: .trailing, spacing: 0) {
                if d == 0 {
                    Text("oggi")
                        .font(.system(.callout, design: .rounded).weight(.bold))
                        .foregroundStyle(event.accentColor)
                } else {
                    Text("\(abs(d))")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(event.accentColor)
                        .contentTransition(.numericText())
                    Text(d > 0 ? "giorni" : "fa")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 46, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.name): \(event.countdownLabel)")
    }
}

// MARK: - Empty State

struct EmptyWidgetView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 26))
                .foregroundStyle(.secondary)
            Text("Apri l'app\ne aggiungi eventi")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
