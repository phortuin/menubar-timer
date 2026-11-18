#!/bin/sh
# Builds the Release app, zips it and publishes it as a GitHub release tagged
# v<MARKETING_VERSION from project.yml>, on the current commit. That commit
# must be committed and pushed. The app is signed to run locally only, so a
# downloaded copy needs Open Anyway once (see the readme).
set -e
cd "$(dirname "$0")/.."
git diff --quiet HEAD || { echo "Uncommitted changes: commit first." >&2; exit 1; }
version=$(sed -nE 's/^ *MARKETING_VERSION: "(.*)"/\1/p' project.yml)
xcodegen
xcodebuild build -scheme MenubarTimer -configuration Release -destination 'platform=macOS' -derivedDataPath build -quiet
rm -f build/MenubarTimer.app.zip
ditto -c -k --keepParent build/Build/Products/Release/MenubarTimer.app build/MenubarTimer.app.zip
gh release create "v$version" build/MenubarTimer.app.zip --target "$(git rev-parse HEAD)" --title "v$version" --generate-notes
