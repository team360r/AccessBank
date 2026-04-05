#!/bin/bash
set -e

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║   AccessBank Tutorial Setup          ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# Check prerequisites
command -v flutter >/dev/null 2>&1 || { echo "❌ Flutter not found. Install from https://docs.flutter.dev/get-started/install"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "❌ Node.js not found. Install from https://nodejs.org"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌ npm not found. Install Node.js from https://nodejs.org"; exit 1; }

echo "✓ Flutter $(flutter --version | head -1 | awk '{print $2}')"
echo "✓ Node.js $(node --version)"
echo "✓ npm $(npm --version)"
echo ""

# 1. Flutter dependencies
echo "→ Installing Flutter dependencies..."
flutter pub get --no-example

# 2. Tutorial docs site
echo "→ Installing tutorial site dependencies..."
cd docs-site && npm install && cd ..

# 3. Git hooks
echo "→ Configuring git hooks..."
git config core.hooksPath .githooks

# 4. iOS signing (only needed for physical device, skip on Android/simulator-only)
configure_ios_signing() {
  local pbxproj="ios/Runner.xcodeproj/project.pbxproj"

  # Try to auto-detect team ID from Xcode credentials
  local detected_team=""
  if command -v security >/dev/null 2>&1; then
    detected_team=$(security find-identity -v -p codesigning 2>/dev/null \
      | grep -oE '\([A-Z0-9]{10}\)' | head -1 | tr -d '()')
  fi

  echo "  Your Apple Developer Team ID is the 10-character code from:"
  echo "  Xcode → Settings → Accounts → (your Apple ID) → Team ID"
  echo "  Or find it at: https://developer.apple.com/account → Membership"
  echo ""

  local prompt="  Enter your Apple Developer Team ID"
  if [ -n "$detected_team" ]; then
    prompt="$prompt [$detected_team]"
  fi
  printf "%s: " "$prompt"
  read -r team_id

  # Use detected value if student just pressed Enter
  if [ -z "$team_id" ] && [ -n "$detected_team" ]; then
    team_id="$detected_team"
  fi

  if [ -z "$team_id" ]; then
    echo "  ⚠️  Skipped — you can run ./setup.sh again to configure signing later."
    return
  fi

  # Validate format (10 uppercase alphanumeric chars)
  if ! echo "$team_id" | grep -qE '^[A-Z0-9]{10}$'; then
    echo "  ⚠️  '$team_id' doesn't look like a Team ID (expected 10 uppercase letters/numbers)."
    echo "  ⚠️  Skipping — run ./setup.sh again once you have the correct ID."
    return
  fi

  # Patch Team ID in Xcode project
  sed -i.bak "s/DEVELOPMENT_TEAM = [A-Z0-9]*;/DEVELOPMENT_TEAM = $team_id;/g" "$pbxproj"
  rm -f "${pbxproj}.bak"

  echo "  ✓ Team ID set to $team_id"
  echo "  ✓ Bundle ID: com.accessbank.accessible (Xcode will auto-create a profile)"
}

# Only prompt for iOS signing on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "→ Configuring iOS signing for physical device..."
  echo "  (Press Enter to skip if you're using a simulator or Android only)"
  echo ""
  configure_ios_signing
  echo ""
fi

echo ""
echo "  ✅ Setup complete!"
echo ""
echo "  To start the tutorial:"
echo ""
echo "      ./start.sh"
echo ""
echo "    This opens the tutorial guide in your browser and launches"
echo "    the app on your connected device or simulator."
echo ""
echo "    Then open the project in your IDE:"
echo "      VS Code:        code ."
echo "      Android Studio:  Open the accessible/ folder"
echo ""
echo "  Happy learning! 🎉"
echo ""
