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

echo ""
echo "  ✅ Setup complete!"
echo ""
echo "  To start the tutorial, run these in separate terminals:"
echo ""
echo "    Terminal 1 (Tutorial Guide):"
echo "      cd docs-site && npm start"
echo "      → Opens at http://localhost:3000"
echo ""
echo "    Terminal 2 (Banking App):"
echo "      flutter run"
echo "      → Launches on your connected device/simulator"
echo ""
echo "    Then open the project in your IDE:"
echo "      VS Code:        code ."
echo "      Android Studio:  Open the accessible/ folder"
echo ""
echo "  Happy learning! 🎉"
echo ""
