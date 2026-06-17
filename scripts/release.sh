#!/bin/bash
# Uso: ./scripts/release.sh 0.4
# Crea DMG, aggiorna Homebrew tap e pubblica su GitHub.
# Le note di release vengono generate dai commit git dall'ultimo tag.

set -e

VERSION="${1:?Specifica la versione, es: ./scripts/release.sh 0.4}"
TAG="v$VERSION"

# Genera note di release dai commit dall'ultimo tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -n "$LAST_TAG" ]; then
  NOTES=$(git log "$LAST_TAG"..HEAD --pretty=format:"- %s" --no-merges)
else
  NOTES=$(git log --pretty=format:"- %s" --no-merges)
fi
[ -z "$NOTES" ] && NOTES="- Miglioramenti e correzioni"
echo "▶ Note di release:"
echo "$NOTES"
DERIVED="/Users/daniele.dituri/Library/Developer/Xcode/DerivedData"
APP=$(find "$DERIVED" -name "CountdownApp.app" -path "*/Release/*" -type d | head -1)
DMG="/tmp/CountdownApp.dmg"
STAGING="/tmp/dmg_staging"
TAP_DIR="/tmp/homebrew-tap-release"

echo "▶ App: $APP"
echo "▶ Versione: $VERSION"

# 1. Firma ad-hoc
echo "▶ Firma ad-hoc..."
rm -f "$APP/Contents/embedded.provisionprofile"
rm -f "$APP/Contents/PlugIns/CountdownWidget.appex/Contents/embedded.provisionprofile"
codesign --force --deep --sign - "$APP/Contents/PlugIns/CountdownWidget.appex"
codesign --force --deep --sign - "$APP"

# 2. Crea DMG
echo "▶ Creazione DMG..."
rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "CountdownApp" -srcfolder "$STAGING" -ov -format UDZO "$DMG"

SHA256=$(shasum -a 256 "$DMG" | cut -d' ' -f1)
echo "   SHA256: $SHA256"

# 3. GitHub release
echo "▶ Pubblicazione GitHub release..."
cd /Users/daniele.dituri/Documents/projects/calendar_countdown/CountdownApp
git add -A
git commit -m "Release $TAG" || true
git tag "$TAG"
git push origin main --tags

gh release create "$TAG" "$DMG" \
  --repo DanieleDituri/countdown_app \
  --title "CountdownApp $VERSION" \
  --notes "$NOTES"

# 4. Aggiorna Homebrew tap
echo "▶ Aggiornamento Homebrew tap..."
rm -rf "$TAP_DIR"
git clone https://github.com/DanieleDituri/homebrew-tap.git "$TAP_DIR"

cat > "$TAP_DIR/Casks/countdownapp.rb" << CASK
cask "countdownapp" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/DanieleDituri/countdown_app/releases/download/$TAG/CountdownApp.dmg"
  name "CountdownApp"
  desc "Countdown timer for your events with menu bar and desktop widgets"
  homepage "https://github.com/DanieleDituri/countdown_app"

  app "CountdownApp.app"

  zap trash: [
    "~/Library/Preferences/com.daniele.CountdownApp.plist",
    "~/Library/Application Support/CountdownApp",
  ]
end
CASK

cd "$TAP_DIR"
git add Casks/countdownapp.rb
git commit -m "countdownapp $VERSION"
git push

echo "✅ Release $TAG pubblicata!"
echo ""
echo "Installa con:"
echo "  brew tap daniele-dituri/tap"
echo "  brew install --cask countdownapp"
echo ""
echo "Aggiorna con:"
echo "  brew upgrade --cask countdownapp"
