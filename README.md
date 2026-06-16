# CountdownApp

A native macOS app to count down the days to your most important events.

## Features

- **Event list** — create and manage events with a name, emoji, color, and date
- **Menu bar** — always-visible countdown in the menu bar (`emoji · name · Xd`)
- **Desktop widgets** — Small (1 event), Medium (2 events), Large (3 events); tap the arrow button to switch which event is displayed
- **Dark & Tinted icons** — full support for Light, Dark, and Tinted app icon variants

## Requirements

- macOS 14 Sonoma or later

## Installation

Download `CountdownApp.dmg` from the [latest release](https://github.com/DanieleDituri/countdown_app/releases/latest), open it, and drag CountdownApp into your Applications folder.

## Build from source

1. Clone the repo
2. Open `CountdownApp.xcodeproj` in Xcode 15+
3. In **Signing & Capabilities**, set your own Apple Developer team for both the `CountdownApp` and `CountdownWidget` targets
4. Add the **App Groups** capability (`group.com.daniele.CountdownApp`) to both targets so widgets can read your events
5. Hit ⌘R

## Adding widgets to the desktop

1. Right-click the macOS desktop → **Edit Widgets**
2. Search for **CountdownApp**
3. Add Small, Medium, or Large — each one can display a different event via the arrow button
