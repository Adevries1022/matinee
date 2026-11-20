#!/usr/bin/env bash
# Stream the Roku's BrightScript debug log (prints, errors, crashes).
# Ctrl+C to stop. Needs ROKU_IP in .env.
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
exec nc "$ROKU_IP" 8085
