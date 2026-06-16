import SwiftUI

extension Color {
    static func fromHex(_ hex: String) -> Color? {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6, let value = UInt64(h, radix: 16) else { return nil }
        return Color(
            red:   Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8)  & 0xFF) / 255,
            blue:  Double(value         & 0xFF) / 255
        )
    }
}

// Palette di colori conformi a macOS Human Interface Guidelines
// Usa sempre i system colors come base; queste sono solo le tinte evento.
let paletteColors: [(name: String, hex: String)] = [
    ("Blu",       "#007AFF"),
    ("Verde",     "#34C759"),
    ("Rosso",     "#FF3B30"),
    ("Arancione", "#FF9500"),
    ("Viola",     "#AF52DE"),
    ("Rosa",      "#FF2D55"),
    ("Giallo",    "#FFCC00"),
    ("Indaco",    "#5856D6"),
    ("Ciano",     "#32ADE6"),
    ("Menta",     "#00C7BE"),
]

let emojiPalette = [
    "🎉", "🎂", "✈️", "🏖️", "🎓", "💍",
    "🎄", "🏃", "🎯", "🚀", "❤️", "🌟",
    "🎸", "🏆", "📅", "🎬", "🍕", "⚽️",
]
