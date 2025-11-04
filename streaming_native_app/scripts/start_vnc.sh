#!/usr/bin/env bash
# PUBLIC_INTERFACE
# start_vnc.sh - Safe no-op VNC starter for the streaming_native_app container.
# This script is provided to satisfy environments that attempt to call a VNC
# startup command during container setup. It will not fail if VNC is not required.
# It logs an informational message and exits successfully.

set -euo pipefail

main() {
  echo "[start_vnc.sh] VNC startup not required for streaming_native_app. No-op."
  echo "[start_vnc.sh] To enable VNC in this container, replace this script with actual VNC startup logic."
  exit 0
}

main "$@"
