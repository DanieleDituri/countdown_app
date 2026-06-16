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

> **"Cannot open" error on first launch?** macOS blocks apps that aren't notarized by Apple. To open it:
> 1. Try to open the app (you'll get the error)
> 2. Go to **System Settings → Privacy & Security**
> 3. Scroll down and click **"Open Anyway"** next to the CountdownApp message
> 4. Enter your Mac password when prompted
>
> Alternatively, run this in Terminal:
> ```bash
> xattr -d com.apple.quarantine /Applications/CountdownApp.app
> ```
> You only need to do this once.

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
