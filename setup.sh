#!/usr/bin/env bash
set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}▶${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*"; exit 1; }

echo ""
echo "  AccessGuide Setup"
echo "  ─────────────────"
echo ""

# ── 1. Platform check ───────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  error "This setup script only runs on macOS."
fi
success "Running on macOS"

# ── 2. Dependency checks ─────────────────────────────────────────────────────
info "Checking required tools..."

command -v flutter >/dev/null 2>&1 || error "Flutter SDK not found. Install from https://flutter.dev"
success "Flutter: $(flutter --version --machine 2>/dev/null | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("frameworkVersion","unknown"))' 2>/dev/null || echo 'installed')"

command -v dart >/dev/null 2>&1 || error "Dart SDK not found (should come with Flutter)."
success "Dart: $(dart --version 2>&1 | head -1)"

command -v git >/dev/null 2>&1 || error "Git not found."
success "Git: $(git --version)"

# ── 3. Flutter pub get ────────────────────────────────────────────────────────
info "Installing Flutter dependencies..."
flutter pub get
success "Flutter dependencies installed"

# ── 4. Tutorial server dependencies ──────────────────────────────────────────
info "Installing tutorial server dependencies..."
(cd tools/tutorial_server && dart pub get)
success "Tutorial server dependencies installed"

# ── 5. Generate tutorial content JSON ────────────────────────────────────────
info "Generating tutorial content..."
dart tools/generate_content.dart
success "Tutorial content generated → tools/shared/tutorial_content.json"

# ── 6. VS Code extension ──────────────────────────────────────────────────────
VSCODE_APP="/Applications/Visual Studio Code.app"
if [[ -d "$VSCODE_APP" ]]; then
  info "Installing VS Code extension..."

  # Find the pre-built .vsix
  VSIX=$(ls tools/vscode-extension/*.vsix 2>/dev/null | head -1)
  if [[ -z "$VSIX" ]]; then
    warn "No pre-built .vsix found. Building from source..."
    if command -v npm >/dev/null 2>&1; then
      (cd tools/vscode-extension && npm install && npm run compile && npx vsce package --no-dependencies 2>/dev/null || npx @vscode/vsce package --no-dependencies)
      VSIX=$(ls tools/vscode-extension/*.vsix 2>/dev/null | head -1)
    else
      warn "npm not found — skipping VS Code extension install. Install Node.js and re-run."
    fi
  fi

  if [[ -n "$VSIX" ]]; then
    code --install-extension "$VSIX" --force
    success "VS Code extension installed: $VSIX"
  fi
else
  warn "VS Code not found at $VSCODE_APP — skipping VS Code extension."
fi

# ── 7. Android Studio plugin ──────────────────────────────────────────────────
AS_PLUGIN_ZIP=$(ls tools/android-studio-plugin/build/distributions/*.zip 2>/dev/null | head -1 || true)
AS_PLUGINS_DIR=$(ls -d "$HOME/Library/Application Support/Google/AndroidStudio"*/plugins 2>/dev/null | head -1 || true)

if [[ -d "/Applications/Android Studio.app" ]]; then
  info "Installing Android Studio plugin..."

  if [[ -z "$AS_PLUGIN_ZIP" ]]; then
    warn "No pre-built plugin .zip found in tools/android-studio-plugin/build/distributions/"
    warn "Build it with: cd tools/android-studio-plugin && ./gradlew buildPlugin"
    warn "Then re-run ./setup.sh"
  elif [[ -z "$AS_PLUGINS_DIR" ]]; then
    warn "Android Studio plugins directory not found — you may need to open Android Studio once first."
    warn "Plugin zip is at: $AS_PLUGIN_ZIP"
    warn "Install manually: Preferences → Plugins → ⚙ → Install Plugin from Disk"
  else
    cp "$AS_PLUGIN_ZIP" "$AS_PLUGINS_DIR/"
    success "Android Studio plugin installed to $AS_PLUGINS_DIR"
    warn "Restart Android Studio to activate the plugin."
  fi
else
  warn "Android Studio not found — skipping Android Studio plugin."
fi

# ── 8. Create .tutorial directory ─────────────────────────────────────────────
mkdir -p .tutorial
success ".tutorial/ state directory created"

# ── 9. Physical device check ──────────────────────────────────────────────────
info "Checking for connected physical devices..."

DEVICES_JSON=$(flutter devices --machine 2>/dev/null || echo "[]")
PHYSICAL_COUNT=$(echo "$DEVICES_JSON" | python3 -c "
import sys, json
devices = json.load(sys.stdin)
physical = [d for d in devices if not d.get('isEmulator', True) and d.get('id') != 'flutter-tester']
print(len(physical))
" 2>/dev/null || echo "0")

if [[ "$PHYSICAL_COUNT" -eq 0 ]]; then
  echo ""
  echo -e "${YELLOW}  ┌──────────────────────────────────────────────────────────┐${NC}"
  echo -e "${YELLOW}  │  No physical device detected.                           │${NC}"
  echo -e "${YELLOW}  │                                                          │${NC}"
  echo -e "${YELLOW}  │  Connect a physical iPhone or Android phone via USB,     │${NC}"
  echo -e "${YELLOW}  │  then open your IDE — the tutorial panel will launch     │${NC}"
  echo -e "${YELLOW}  │  flutter run automatically.                              │${NC}"
  echo -e "${YELLOW}  └──────────────────────────────────────────────────────────┘${NC}"
  echo ""
else
  success "$PHYSICAL_COUNT physical device(s) connected"
  flutter devices --machine 2>/dev/null | python3 -c "
import sys, json
devices = json.load(sys.stdin)
for d in devices:
    if not d.get('isEmulator', True) and d.get('id') != 'flutter-tester':
        print(f\"  • {d.get('name', d['id'])} ({d.get('targetPlatform', 'unknown')})\")
  "
fi

# ── 10. Success summary ───────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}  ┌──────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}  │  AccessGuide setup complete!                             │${NC}"
echo -e "${GREEN}  │                                                          │${NC}"
echo -e "${GREEN}  │  Next steps:                                             │${NC}"
echo -e "${GREEN}  │  1. Open this project in VS Code or Android Studio       │${NC}"
echo -e "${GREEN}  │  2. Connect a physical iPhone or Android phone via USB   │${NC}"
echo -e "${GREEN}  │  3. The Tutorial panel will appear automatically         │${NC}"
echo -e "${GREEN}  │                                                          │${NC}"
echo -e "${GREEN}  │  The tutorial server starts automatically when you       │${NC}"
echo -e "${GREEN}  │  open the Tutorial panel in your IDE.                    │${NC}"
echo -e "${GREEN}  └──────────────────────────────────────────────────────────┘${NC}"
echo ""
