#!/bin/bash
# Uso: ./scripts/release.sh 0.3
# Crea DMG, lo firma con Sparkle, aggiorna appcast.xml e pubblica su GitHub.

set -e

VERSION="${1:?Specifica la versione, es: ./scripts/release.sh 0.3}"
TAG="v$VERSION"
BUNDLE_VERSION="${2:-$(date +%s)}"  # usa il secondo argomento o timestamp
SPARKLE_BIN="/opt/homebrew/Caskroom/sparkle/2.9.3/bin"
DERIVED="/Users/daniele.dituri/Library/Developer/Xcode/DerivedData"
APP=$(find "$DERIVED" -name "CountdownApp.app" -path "*/Release/*" -type d | head -1)
DMG="/tmp/CountdownApp.dmg"
STAGING="/tmp/dmg_staging"
PRIV_KEY_FILE="$HOME/.sparkle_private_key"

echo "▶ App: $APP"
echo "▶ Versione: $VERSION (bundle $BUNDLE_VERSION)"

# 1. Firma ad-hoc (rimuove provisioning profile)
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

DMG_SIZE=$(stat -f%z "$DMG")

# 3. Firma con Sparkle (EdDSA)
echo "▶ Firma EdDSA con Sparkle..."
if [ ! -f "$PRIV_KEY_FILE" ]; then
  echo "Chiave privata non trovata in $PRIV_KEY_FILE"
  echo "Crea il file con il contenuto della PRIVATE KEY generata in precedenza:"
  echo "  zUdDk/S0NAdUQbRAevrR2jLfU/YNpEFq1NXoJYstJkY="
  exit 1
fi
PRIV_KEY=$(cat "$PRIV_KEY_FILE")
SIGNATURE=$("$SPARKLE_BIN/sign_update" --ed-key "$PRIV_KEY" "$DMG" 2>/dev/null | grep -o 'sparkle:edSignature="[^"]*"' | cut -d'"' -f2)
echo "   Firma: $SIGNATURE"

# 4. Aggiorna appcast.xml
echo "▶ Aggiornamento appcast.xml..."
DATE=$(date -u "+%a, %d %b %Y %H:%M:%S +0000")
ITEM="
    <item>
      <title>CountdownApp $VERSION</title>
      <sparkle:version>$BUNDLE_VERSION</sparkle:version>
      <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
      <pubDate>$DATE</pubDate>
      <enclosure
        url=\"https://github.com/DanieleDituri/countdown_app/releases/download/$TAG/CountdownApp.dmg\"
        sparkle:edSignature=\"$SIGNATURE\"
        length=\"$DMG_SIZE\"
        type=\"application/octet-stream\"/>
      <sparkle:releaseNotesLink>https://github.com/DanieleDituri/countdown_app/releases/tag/$TAG</sparkle:releaseNotesLink>
    </item>"

python3 -c "
import sys
content = open('appcast.xml').read()
new_item = '''$ITEM'''
content = content.replace('  </channel>', new_item + '\n\n  </channel>')
open('appcast.xml', 'w').write(content)
print('appcast.xml aggiornato')
"

# 5. Commit, tag, push
echo "▶ Commit e push..."
git add appcast.xml CountdownApp/Info.plist
git commit -m "Release $TAG"
git tag "$TAG"
git push origin main --tags

# 6. GitHub release
echo "▶ Pubblicazione GitHub release..."
gh release create "$TAG" "$DMG" \
  --repo DanieleDituri/countdown_app \
  --title "CountdownApp $VERSION" \
  --notes "Vedi [release notes](https://github.com/DanieleDituri/countdown_app/releases/tag/$TAG)."

echo "✅ Release $TAG pubblicata!"
