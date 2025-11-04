#!/usr/bin/env bash
# PUBLIC_INTERFACE
# roku_deploy.sh - Sideload a packaged Roku app ZIP to a Roku Developer device.
#
# This script uses the Roku Developer web endpoint to:
#   - Delete any previously sideloaded app
#   - Upload the provided ZIP
#   - Install the app
#
# Environment variables (REQUIRED):
#   - ROKU_DEV_TARGET   : Device IP or host (e.g., 192.168.1.23)
#   - ROKU_DEV_USERNAME : Developer mode username (default is often "rokudev")
#   - ROKU_DEV_PASSWORD : Developer mode password you set on the device
#
# Arguments:
#   1) Path to ZIP file (defaults to ./build/roku_app.zip built by roku_pack.sh)
#
# Usage:
#   ROKU_DEV_TARGET=192.168.1.23 ROKU_DEV_USERNAME=rokudev ROKU_DEV_PASSWORD='secret' \
#     bash scripts/roku_deploy.sh ./build/roku_app.zip
#
# Notes:
#   - curl must be installed.
#   - Device must have Developer Mode enabled and accessible on the network.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

ZIP_PATH="${1:-${APP_ROOT}/build/roku_app.zip}"

log() { printf "[roku_deploy] %s\n" "$*"; }
fail() { printf "[roku_deploy][ERROR] %s\n" "$*" >&2; exit 1; }

# Validate env
: "${ROKU_DEV_TARGET:?ROKU_DEV_TARGET is required (device IP/host).}"
: "${ROKU_DEV_USERNAME:?ROKU_DEV_USERNAME is required.}"
: "${ROKU_DEV_PASSWORD:?ROKU_DEV_PASSWORD is required.}"

# Validate tools
command -v curl >/dev/null 2>&1 || fail "curl not found. Please install curl."

# Validate ZIP exists
[[ -f "${ZIP_PATH}" ]] || fail "ZIP file not found at: ${ZIP_PATH}"

BASE_URL="http://${ROKU_DEV_TARGET}"
DEV_URL="${BASE_URL}/plugin_install"

log "Target: ${ROKU_DEV_TARGET}"
log "ZIP: ${ZIP_PATH}"

# Basic connectivity check
if ! curl -s -S --connect-timeout 5 "${DEV_URL}" >/dev/null; then
  log "WARNING: Could not reach ${DEV_URL}. Ensure device is online and Developer Mode is enabled."
fi

# Delete any existing sideloaded app
log "Deleting existing sideloaded app (if any)..."
curl -sS -u "${ROKU_DEV_USERNAME}:${ROKU_DEV_PASSWORD}" \
  --digest \
  --data 'mysubmit=Delete' \
  --data 'archive=' \
  "${DEV_URL}" >/dev/null || log "Delete step may have failed or no app to delete; continuing."

# Upload and install new app
log "Uploading and installing new app..."
curl -sS -u "${ROKU_DEV_USERNAME}:${ROKU_DEV_PASSWORD}" \
  --digest \
  -F "mysubmit=Install" \
  -F "archive=@${ZIP_PATH};type=application/zip" \
  "${DEV_URL}" >/dev/null

log "Sideloaded and installed successfully."
log "To launch the app, press Home on the remote and select the sideloaded app, or use ECP to launch by sideloaded key."

exit 0
