#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  Starting AccessBank Tutorial..."
echo ""

# 1. Launch docs-site in a new Terminal window
echo "  → Opening tutorial guide at http://localhost:3000"
osascript -e "tell application \"Terminal\" to do script \"cd '$SCRIPT_DIR/docs-site' && npm start\""

# 2. Open browser once the server is ready
(sleep 4 && open http://localhost:3000) &

# 3. Start Flutter app in this terminal
echo "  → Launching app on device/simulator"
echo "  (Press 'q' to quit, 'r' to hot reload, 'R' for full restart)"
echo ""
cd "$SCRIPT_DIR" && flutter run
