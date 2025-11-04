# BrightStream Retro - Roku (BrightScript) Project

This folder now contains a Roku BrightScript project that coexists with the provided Qt sample.

Structure:
- manifest
- components/
  - AppScene.xml
  - HomeScreen.xml
  - DetailsScreen.xml
  - VideoPlayer.xml
  - Theme.xml            (RetroTheme: tokens and visuals)
- source/
  - main.brs
  - AppScene.brs
  - HomeScreen.brs
  - DetailsScreen.brs
  - VideoPlayer.brs
  - Theme.brs            (RetroTheme logic)
- images/ (placeholder assets)
  - retro/
    - scanline_overlay.png (placeholder)
    - neon_border_blue.png (placeholder)
    - neon_border_amber.png (placeholder)
- fonts/ (optional)

Running on a Roku device (sideload):
1. Replace placeholder images in images/ with actual PNG/JPG files.
2. Ensure content URLs in HomeScreen.brs are valid or updated.
3. Zip the following at the root of streaming_native_app/:
   - manifest
   - components/
   - source/
   - images/
   - fonts/ (optional)
4. Enable Developer Mode on your Roku device.
5. Upload the zip via the Roku Developer web interface at your device's developer portal (http://<device-ip>).
6. Install and run.

Notes:
- This BrightScript project is independent of the Qt sample and does not affect CMake builds.
- Theme colors and tokens are centralized in components/Theme.xml and source/Theme.brs.
- AppScene instantiates RetroTheme and passes theme tokens to screens.
