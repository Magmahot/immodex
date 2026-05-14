#!/usr/bin/env bash
# Build a Chrome Web Store-ready zip of the extension.
#
# Usage:  ./scripts/build.sh
# Output: dist/immodex-<version>.zip
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v zip >/dev/null 2>&1; then
  echo "✗ 'zip' is not installed. On macOS it ships with the OS; on Linux: apt install zip" >&2
  exit 1
fi

VERSION=$(node -p "require('./manifest.json').version")
if [[ -z "$VERSION" ]]; then
  echo "✗ Could not read version from manifest.json" >&2
  exit 1
fi

node -e "JSON.parse(require('fs').readFileSync('manifest.json','utf8'))" \
  || { echo "✗ manifest.json is not valid JSON" >&2; exit 1; }

while IFS= read -r -d '' f; do
  node --check "$f" >/dev/null || { echo "✗ Syntax error in $f" >&2; exit 1; }
done < <(find src -name "*.js" -print0)

mkdir -p dist
ZIP="dist/immodex-${VERSION}.zip"
rm -f "$ZIP"

zip -rq "$ZIP" \
  manifest.json LICENSE icons src \
  -x "icons/*.svg" \
  -x "**/.DS_Store" \
  -x "**/*.map"

SIZE=$(du -h "$ZIP" | awk '{print $1}')
COUNT=$(unzip -l "$ZIP" | tail -1 | awk '{print $2}')

echo "✓ Built $ZIP ($SIZE, $COUNT files)"
echo "  Upload at: https://chrome.google.com/webstore/devconsole"
