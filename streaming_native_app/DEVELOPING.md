# streaming_native_app - Development Notes

- A common setup step in CI may attempt to execute /usr/local/bin/start_vnc.
- This project provides a safe no-op script at scripts/start_vnc.sh.
- The prebuild script scripts/prebuild.sh ensures the expected path exists by linking or copying the script.

Usage:
- Run: bash scripts/prebuild.sh
- This is idempotent and safe to run multiple times.

Troubleshooting:
- If you see errors like "sudo: /usr/local/bin/start_vnc: command not found", ensure prebuild has run and that /usr/local/bin is writable.
- If not writable, the script installs to ~/.local/bin; add it to PATH if necessary.
