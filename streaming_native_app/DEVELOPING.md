# streaming_native_app - Development Notes

- A common setup step in CI may attempt to execute /usr/local/bin/start_vnc.
- This project provides a safe no-op script at scripts/start_vnc.sh.
- The prebuild script scripts/prebuild.sh ensures the expected path exists by linking or copying the script.

Usage:
- Run: bash scripts/prebuild.sh
- This is idempotent and safe to run multiple times.

Roku packaging and sideload
- Package the BrightScript app:
  bash scripts/roku_pack.sh
  # Output: build/roku_app.zip

- Sideload to device:
  export ROKU_DEV_TARGET=192.168.1.23
  export ROKU_DEV_USERNAME=rokudev
  export ROKU_DEV_PASSWORD='your-password'
  bash scripts/roku_deploy.sh build/roku_app.zip

Troubleshooting:
- If you see errors like "sudo: /usr/local/bin/start_vnc: command not found", ensure prebuild has run and that /usr/local/bin is writable.
- If not writable, the script installs to ~/.local/bin; add it to PATH if necessary.
- If sideload fails, verify Developer Mode is enabled and the IP/credentials are correct by visiting http://$ROKU_DEV_TARGET/plugin_install in a browser.
