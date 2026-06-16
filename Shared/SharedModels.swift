import Foundation
import SwiftUI

// MARK: - Shared App Group
// Entrambi i target (app + widget) leggono/scrivono sullo stesso UserDefaults
// tramite App Groups. Il group identifier deve corrispondere a quello
// configurato in Xcode → Signing & Capabilities → App Groups.

let appGroupID = "group.com.daniele.CountdownApp"

// MARK: - CountdownEvent

struct CountdownEvent: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var date: Date
    var emoji: String
    var colorHex: String

    // MARK: Computed

    var daysRemaining: Int {
        let cal = Calendar.current
        let today  = cal.startOfDay(for: Date())
        let target = cal.startOfDay(for: date)
        return cal.dateComponents([.day], from: today, to: target).day ?? 0
    }

    var countdownLabel: String {
        let d = daysRemaining
        switch d {
        case 1:        return "Domani"
        case 0:        return "Oggi"
        case ..<0:     return "\(abs(d)) giorni fa"
        default:       return "\(d) giorni"
        }
    }

    var menuBarTitle: String {
        let d = daysRemaining
        if d > 0  { return "\(emoji) \(name) · \(d)g" }
        if d == 0 { return "\(emoji) \(name) · oggi" }
        return "\(emoji) \(name) · \(abs(d))g fa"
    }

    var accentColor: Color {
        Color.fromHex(colorHex) ?? Color.accentColor
    }
}

// MARK: - Shared Persistence

struct SharedStore {
    // Prova App Groups, altrimenti UserDefaults.standard come fallback
    private static var groupDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    private static let eventsKey  = "countdown_events"
    private static let widgetKey  = "countdown_widget_ids"
    private static let menuBarKey = "countdown_menubar_id"

    static func loadEvents() -> [CountdownEvent] {
        // Legge da App Group se disponibile, altrimenti da standard
        let source = groupDefaults ?? .standard
        guard let data = source.data(forKey: eventsKey),
              let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: data)
        else { return [] }
        return decoded
    }

    static func save(events: [CountdownEvent]) {
        guard let data = try? JSONEncoder().encode(events) else { return }
        // Scrive su entrambi: App Group (per il widget) + standard (fallback)
        groupDefaults?.set(data, forKey: eventsKey)
        UserDefaults.standard.set(data, forKey: eventsKey)
    }

    static func loadWidgetIDs() -> [UUID] {
        let source = groupDefaults ?? .standard
        let strs = source.stringArray(forKey: widgetKey) ?? []
        return strs.compactMap(UUID.init(uuidString:))
    }

    static func save(widgetIDs: [UUID]) {
        let val = widgetIDs.map(\.uuidString)
        groupDefaults?.set(val, forKey: widgetKey)
        UserDefaults.standard.set(val, forKey: widgetKey)
    }

    static func loadMenuBarID() -> UUID? {
        let source = groupDefaults ?? .standard
        guard let str = source.string(forKey: menuBarKey) else { return nil }
        return UUID(uuidString: str)
    }

    static func save(menuBarID: UUID?) {
        groupDefaults?.set(menuBarID?.uuidString, forKey: menuBarKey)
        UserDefaults.standard.set(menuBarID?.uuidString, forKey: menuBarKey)
    }
}
