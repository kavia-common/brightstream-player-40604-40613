#!/usr/bin/env bash
# PUBLIC_INTERFACE
# prebuild.sh - Prepare environment for streaming_native_app common setup.
# Ensures that a VNC startup command exists at /usr/local/bin/start_vnc by
# delegating to this repository's no-op VNC script. Prevents setup failures
# when the environment expects a VNC starter.
#
# Behavior:
# - Requires no environment variables
# - Safe to run multiple times (idempotent)
# - Exits 0 on success, non-zero on fatal error

set -euo pipefail

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SCRIPT_DIR="${REPO_ROOT}/scripts"
readonly NOOP_VNC="${SCRIPT_DIR}/start_vnc.sh"
readonly TARGET_BIN="/usr/local/bin/start_vnc"

log() { printf "[prebuild] %s\n" "$*"; }

install_start_vnc() {
  if [[ ! -f "${NOOP_VNC}" ]]; then
    log "ERROR: Expected VNC script not found at ${NOOP_VNC}"
    return 1
  fi

  # Ensure executable bit
  chmod +x "${NOOP_VNC}" || true

  # If target exists as a symlink to the correct source, nothing to do.
  if [[ -L "${TARGET_BIN}" ]] && [[ "$(readlink -f "${TARGET_BIN}")" == "$(readlink -f "${NOOP_VNC}")" ]]; then
    log "Existing symlink already points to no-op VNC script at ${TARGET_BIN}"
    return 0
  fi

  # Attempt to create a symlink; fall back to copying if symlinking not permitted.
  if ln -sf "${NOOP_VNC}" "${TARGET_BIN}" 2>/dev/null; then
    log "Symlinked ${TARGET_BIN} -> ${NOOP_VNC}"
  else
    # Some environments may not allow symlink creation to system dirs; try copying.
    if cp -f "${NOOP_VNC}" "${TARGET_BIN}" 2>/dev/null; then
      chmod +x "${TARGET_BIN}" || true
      log "Copied no-op VNC script to ${TARGET_BIN}"
    else
      # As a last resort, install into a writable local bin and export PATH message.
      local LOCAL_BIN="${HOME}/.local/bin"
      mkdir -p "${LOCAL_BIN}"
      cp -f "${NOOP_VNC}" "${LOCAL_BIN}/start_vnc"
      chmod +x "${LOCAL_BIN}/start_vnc" || true
      log "Installed start_vnc to ${LOCAL_BIN}/start_vnc"
      log "Note: Add ${LOCAL_BIN} to PATH if the environment resolves /usr/local/bin/start_vnc differently."
    fi
  fi
}

main() {
  log "Starting prebuild steps for streaming_native_app"
  install_start_vnc
  log "Prebuild steps completed successfully."
}

main "$@"
