#!/bin/bash
# Ships a new version to App Store Connect in one go:
#   1. checks the listing and the API key (dry run of marketing/upload_listing.swift)
#   2. bumps MARKETING_VERSION and the build number, runs `make lint test`
#   3. archives, uploads the build, then commits, tags and pushes the bump
#   4. creates the version, sends the listing and screenshots and attaches the build
#      (and submits for App Review with --submit)
#
#   scripts/release.sh 1.6               everything except submitting for review
#   scripts/release.sh 1.6 --submit      also submits the version for App Review
#   scripts/release.sh --check           archives and exports locally only; changes and uploads nothing
#
# Update What's New in marketing/AppStoreListing.md before releasing.
set -euo pipefail
cd "$(dirname "$0")/.."

# Credentials stay out of this public repo: ASC_KEY_ID (and ASC_ISSUER_ID, used by upload_listing.swift)
# come from the environment or ~/.config/appstoreconnect.env.
CONFIG="$HOME/.config/appstoreconnect.env"
if [[ -z "${ASC_KEY_ID:-}" && -f "$CONFIG" ]]; then
  ASC_KEY_ID="$(awk -F= '$1 == "ASC_KEY_ID" { print $2; exit }' "$CONFIG")"
fi
[[ -n "${ASC_KEY_ID:-}" ]] || { echo "Set ASC_KEY_ID and ASC_ISSUER_ID in the environment or in $CONFIG."; exit 1; }
KEY_PATH="${ASC_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8}"
PROJECT="Chakame.xcodeproj"
SCHEME="Chakame"
PBXPROJ="$PROJECT/project.pbxproj"
OUT="build/release"

VERSION=""
CHECK_ONLY=false
SUBMIT_FLAG=""
for arg in "$@"; do
  case "$arg" in
    --check) CHECK_ONLY=true ;;
    --submit) SUBMIT_FLAG="--submit" ;;
    [0-9]*.[0-9]*) VERSION="$arg" ;;
    *) echo "Usage: scripts/release.sh <x.y[.z]> [--submit] | --check"; exit 2 ;;
  esac
done

step() { printf '\n==> %s\n' "$1"; }

setting() {
  xcodebuild -project "$PROJECT" -target "$SCHEME" -configuration Release -showBuildSettings 2>/dev/null \
    | awk -v key="$1" '$1 == key { print $3; exit }'
}

archive_and_export() {  # $1: upload | export
  rm -rf "$OUT"
  mkdir -p "$OUT"
  cat > "$OUT/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>$1</string>
  <key>teamID</key><string>$TEAM_ID</string>
  <key>signingStyle</key><string>automatic</string>
  <key>manageAppVersionAndBuildNumber</key><false/>
  <key>uploadSymbols</key><true/>
</dict>
</plist>
PLIST
  # Signing and upload use the Apple ID signed in to Xcode: cloud signing needs an Admin, which the API key is not.
  local auth=(-allowProvisioningUpdates)

  step "Archiving"
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Release \
    -destination 'generic/platform=iOS' -archivePath "$OUT/$SCHEME.xcarchive" "${auth[@]}" -quiet archive

  step "Exporting ($1)"
  xcodebuild -exportArchive -archivePath "$OUT/$SCHEME.xcarchive" -exportPath "$OUT/export" \
    -exportOptionsPlist "$OUT/ExportOptions.plist" "${auth[@]}"
}

[[ -f "$KEY_PATH" ]] || { echo "No App Store Connect API key at $KEY_PATH"; exit 1; }
TEAM_ID="$(setting DEVELOPMENT_TEAM)"
[[ -n "$TEAM_ID" ]] || { echo "Could not read DEVELOPMENT_TEAM from $PROJECT."; exit 1; }

if $CHECK_ONLY; then
  archive_and_export export
  echo; echo "Signing works. The .ipa is in $OUT/export (nothing was uploaded)."
  exit 0
fi

[[ -n "$VERSION" ]] || { echo "Usage: scripts/release.sh <x.y[.z]> [--submit] | --check"; exit 2; }
[[ "$VERSION" =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] || { echo "Version must look like 1.6 or 1.6.0, got $VERSION."; exit 2; }
[[ "$(git branch --show-current)" == "main" ]] || { echo "Release from main."; exit 1; }
[[ -z "$(git status --porcelain)" ]] || { echo "Commit or stash your changes first (the release commits only the version bump)."; exit 1; }

OLD_VERSION="$(setting MARKETING_VERSION)"
OLD_BUILD="$(setting CURRENT_PROJECT_VERSION)"
NEW_BUILD=$((OLD_BUILD + 1))
[[ -n "$OLD_VERSION" && -n "$OLD_BUILD" ]] || { echo "Could not read MARKETING_VERSION / CURRENT_PROJECT_VERSION."; exit 1; }
# Compare without trailing ".0"s, so 1.5 and 1.5.0 count as the same version.
normalized() { local v="$1"; while [[ "$v" == *.*.* && "$v" == *.0 ]]; do v="${v%.0}"; done; echo "$v"; }
[[ "$(normalized "$VERSION")" != "$(normalized "$OLD_VERSION")" ]] \
  || { echo "The project is already at $OLD_VERSION; pass the new version."; exit 1; }
[[ "$(printf '%s\n%s\n' "$OLD_VERSION" "$VERSION" | sort -V | tail -n 1)" == "$VERSION" ]] \
  || { echo "$VERSION is lower than the current $OLD_VERSION."; exit 1; }

mkdir -p build
step "Checking listing and App Store Connect access (dry run)"
swift marketing/upload_listing.swift --version "$VERSION" --create > "$OUT.listing-check.txt" 2>&1 \
  || { cat "$OUT.listing-check.txt"; exit 1; }
tail -n 1 "$OUT.listing-check.txt"

step "Bumping $OLD_VERSION ($OLD_BUILD) → $VERSION ($NEW_BUILD)"
# If anything below fails, put the project file back so a rerun starts clean.
trap 'git checkout -- "$PBXPROJ"; echo "Release stopped; version bump reverted."' ERR
sed -i '' -e "s/MARKETING_VERSION = ${OLD_VERSION//./\\.};/MARKETING_VERSION = $VERSION;/" \
          -e "s/CURRENT_PROJECT_VERSION = $OLD_BUILD;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/" "$PBXPROJ"
[[ "$(setting MARKETING_VERSION)" == "$VERSION" && "$(setting CURRENT_PROJECT_VERSION)" == "$NEW_BUILD" ]] \
  || { echo "The version bump did not apply to $PBXPROJ."; false; }

step "Running lint and unit tests"
make lint test DEST="$(scripts/sim-destination.sh)"

archive_and_export upload
trap - ERR

step "Committing and pushing the version bump"
git add "$PBXPROJ"
git commit -q -m "Release $VERSION ($NEW_BUILD)"
git tag "v$VERSION"
git push -q origin main "v$VERSION"

step "Creating the version, sending the listing and attaching the build"
swift marketing/upload_listing.swift --version "$VERSION" --create --build "$NEW_BUILD" --screenshots --apply $SUBMIT_FLAG

echo
if [[ -n "$SUBMIT_FLAG" ]]; then
  echo "Released $VERSION ($NEW_BUILD) and submitted it for App Review."
else
  echo "Released $VERSION ($NEW_BUILD). Check the version page, then press Add for Review."
fi
