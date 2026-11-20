#!/usr/bin/env bash
# Build the Roku package and sideload it onto the TV.
# Needs ROKU_IP and ROKU_DEV_PASSWORD in .env (see .env.example).
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
mkdir -p dist
rm -f dist/matinee.zip
zip -r -X -q dist/matinee.zip manifest source components images
echo "Installing dist/matinee.zip on $ROKU_IP ..."
curl -sS --fail --user "rokudev:${ROKU_DEV_PASSWORD}" --digest \
  -F "mysubmit=Install" -F "archive=@dist/matinee.zip" \
  "http://${ROKU_IP}/plugin_install" | grep -o '<font color="red">[^<]*' | sed 's/<font color="red">//' || true
echo "Done. Matinee should now be open on the TV."
