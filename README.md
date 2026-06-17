# CountdownApp

A native macOS app to count down the days to your most important events.

## Features

- **Event list** — create and manage events with a name, emoji, color, and date
- **Menu bar** — always-visible countdown in the menu bar (`emoji · name · Xd`)
- **Desktop widgets** — Small (1 event), Medium (2 events), Large (3 events)
- **Settings** — launch at login, hide from Dock
- **Auto-update check** — notified when a new version is available

## Requirements

- macOS 14 Sonoma or later

## Installation

### Homebrew (recommended)

```bash
brew tap daniele-dituri/tap https://github.com/DanieleDituri/homebrew-tap
brew trust daniele-dituri/tap
brew install --cask countdownapp
```

**Update:**
```bash
brew upgrade --cask countdownapp
```

### Manual

Download `CountdownApp.dmg` from the [latest release](https://github.com/DanieleDituri/countdown_app/releases/latest), open it, and drag CountdownApp into your Applications folder.

> **"Cannot open" error on first launch?** macOS blocks apps that aren't notarized by Apple. To open it:
> 1. Try to open the app (you'll get the error)
> 2. Go to **System Settings → Privacy & Security**
> 3. Scroll down and click **"Open Anyway"** next to the CountdownApp message
> 4. Enter your Mac password when prompted

## Adding widgets to the desktop

1. Right-click the macOS desktop → **Edit Widgets**
2. Search for **CountdownApp**
3. Add Small, Medium, or Large
