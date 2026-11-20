#!/usr/bin/env bash
# Compile the BrighterScript source, build the Roku package and sideload it onto the TV.
# Needs Node.js, and ROKU_IP and ROKU_DEV_PASSWORD in .env (see .env.example).
# Pass --build-only to compile and package without installing.
set -euo pipefail
cd "$(dirname "$0")/.."

[ -d node_modules ] || npm ci --no-audit --no-fund

# Type-check, lint and transpile into build/. Errors stop the deploy.
rm -rf build
npx bsc

mkdir -p dist
rm -f dist/matinee.zip
(cd build && zip -r -X -q ../dist/matinee.zip .)
echo "Built dist/matinee.zip"
[ "${1:-}" = "--build-only" ] && exit 0

set -a; source .env; set +a
echo "Installing dist/matinee.zip on $ROKU_IP ..."
curl -sS --fail --user "rokudev:${ROKU_DEV_PASSWORD}" --digest \
  -F "mysubmit=Install" -F "archive=@dist/matinee.zip" \
  "http://${ROKU_IP}/plugin_install" | grep -o '<font color="red">[^<]*' | sed 's/<font color="red">//' || true
echo "Done. Matinee should now be open on the TV."
