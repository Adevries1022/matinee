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
if ! response=$(curl -sS --fail --connect-timeout 10 --user "rokudev:${ROKU_DEV_PASSWORD}" --digest \
    -F "mysubmit=Install" -F "archive=@dist/matinee.zip" \
    "http://${ROKU_IP}/plugin_install"); then
  echo "Install failed: could not upload to the Roku at $ROKU_IP (is it on, and is Developer Mode enabled?)." >&2
  exit 1
fi
# The Roku's install page reports its result in red text.
result=$(printf '%s' "$response" | grep -o '<font color="red">[^<]*' | sed 's/<font color="red">//' || true)
[ -n "$result" ] && echo "$result"
if printf '%s' "$response" | grep -qE 'Install Success|Identical to previous version'; then
  echo "Done. Matinee should now be open on the TV."
else
  echo "Install failed: the Roku did not report success." >&2
  exit 1
fi
