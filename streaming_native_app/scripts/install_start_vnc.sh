#!/usr/bin/env bash
# PUBLIC_INTERFACE
# install_start_vnc.sh - Installs the no-op VNC starter to the expected path.
# This is a standalone installer that can be used by CI or developers if needed.

set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly NOOP_VNC="${REPO_ROOT}/scripts/start_vnc.sh"
readonly TARGET_BIN="/usr/local/bin/start_vnc"

log() { printf "[install_start_vnc] %s\n" "$*"; }

if [[ ! -f "${NOOP_VNC}" ]]; then
  log "ERROR: Missing ${NOOP_VNC}"
  exit 1
fi

chmod +x "${NOOP_VNC}" || true

if ln -sf "${NOOP_VNC}" "${TARGET_BIN}" 2>/dev/null; then
  log "Symlinked ${TARGET_BIN} -> ${NOOP_VNC}"
elif cp -f "${NOOP_VNC}" "${TARGET_BIN}" 2>/dev/null; then
  chmod +x "${TARGET_BIN}" || true
  log "Copied no-op VNC script to ${TARGET_BIN}"
else
  local LOCAL_BIN="${HOME}/.local/bin"
  mkdir -p "${LOCAL_BIN}"
  cp -f "${NOOP_VNC}" "${LOCAL_BIN}/start_vnc"
  chmod +x "${LOCAL_BIN}/start_vnc" || true
  log "Installed start_vnc to ${LOCAL_BIN}/start_vnc"
  log "Note: Add ${LOCAL_BIN} to PATH if /usr/local/bin is not writable."
fi

log "Installation completed."
