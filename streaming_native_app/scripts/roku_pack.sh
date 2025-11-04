#!/usr/bin/env bash
# PUBLIC_INTERFACE
# roku_pack.sh - Package the Roku BrightScript app into a ZIP suitable for sideloading.
#
# This script creates a ZIP containing ONLY the BrightScript app artifacts:
#   - manifest
#   - source/
#   - components/
#   - images/
#   - fonts/ (optional)
#
# It excludes any Qt/C++ files and other non-Roku artifacts in this repository.
#
# Usage:
#   bash scripts/roku_pack.sh [OUTPUT_ZIP_PATH]
#     OUTPUT_ZIP_PATH: Optional. Defaults to ./build/roku_app.zip
#
# Examples:
#   bash scripts/roku_pack.sh
#   bash scripts/roku_pack.sh ./dist/brightstream-retro.zip
#
# Requirements:
#   - bash, zip
#
# Notes:
#   - This script must be run from the streaming_native_app directory or any subpath under it.
#   - The output path's directory will be created if needed.

set -euo pipefail

# Resolve repo root as the streaming_native_app directory (script is inside scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

OUT_PATH="${1:-${APP_ROOT}/build/roku_app.zip}"

log() { printf "[roku_pack] %s\n" "$*"; }
fail() { printf "[roku_pack][ERROR] %s\n" "$*" >&2; exit 1; }

cd "${APP_ROOT}"

# Validate required files exist
[[ -f "manifest" ]] || fail "manifest file not found in ${APP_ROOT}"
[[ -d "source" ]] || fail "source/ directory not found in ${APP_ROOT}"
[[ -d "components" ]] || fail "components/ directory not found in ${APP_ROOT}"
# images is strongly recommended
[[ -d "images" ]] || log "WARNING: images/ directory not found. Proceeding without it."
# fonts optional

# Prepare output directory
OUT_DIR="$(dirname "${OUT_PATH}")"
mkdir -p "${OUT_DIR}"

# Build a temporary staging directory with only the Roku app files
STAGE_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${STAGE_DIR}" || true
}
trap cleanup EXIT

log "Staging BrightScript app into: ${STAGE_DIR}"

cp -f "manifest" "${STAGE_DIR}/manifest"
[[ -d "source" ]] && mkdir -p "${STAGE_DIR}/source" && cp -R "source/." "${STAGE_DIR}/source/"
[[ -d "components" ]] && mkdir -p "${STAGE_DIR}/components" && cp -R "components/." "${STAGE_DIR}/components/"
[[ -d "images" ]] && mkdir -p "${STAGE_DIR}/images" && cp -R "images/." "${STAGE_DIR}/images/"
[[ -d "fonts" ]] && mkdir -p "${STAGE_DIR}/fonts" && cp -R "fonts/." "${STAGE_DIR}/fonts/"

# Create the ZIP from within the staging directory to ensure correct layout
pushd "${STAGE_DIR}" >/dev/null

# Ensure zip is available
if ! command -v zip >/dev/null 2>&1; then
  fail "zip command not found. Please install zip."
fi

# Create zip
log "Creating ZIP at: ${OUT_PATH}"
zip -q -r "${OUT_PATH}" \
  "manifest" \
  "source" \
  "components" \
  $( [[ -d "images" ]] && echo "images" ) \
  $( [[ -d "fonts" ]] && echo "fonts" )

popd >/dev/null

log "Packaged Roku app: ${OUT_PATH}"
exit 0
