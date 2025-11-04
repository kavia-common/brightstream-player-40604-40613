# BrightStream Retro - Roku (BrightScript) Project

This folder contains a Roku BrightScript project that coexists with the provided Qt sample.

Structure:
- manifest
- components/
  - AppScene.xml
  - HomeScreen.xml
  - DetailsScreen.xml
  - VideoPlayer.xml
  - Theme.xml            (RetroTheme: tokens, toggles, and visual assets)
- source/
  - main.brs
  - AppScene.brs
  - HomeScreen.brs
  - DetailsScreen.brs
  - VideoPlayer.brs
  - Theme.brs            (RetroTheme logic and Ocean Professional mapping)
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

Theming and Tokens
- Palette: Ocean Professional
  - primary: #2563EB
  - secondary: #F59E0B (also used as success)
  - error: #EF4444
  - text base: #111827 (gray-900, for light surfaces; we use text=#FFFFFF for TV-dark scenes)
- TV-safe scene defaults:
  - background: #0E1E40 (deep ocean)
  - surface: #101826 (near black-blue)
  - text: #FFFFFF
  - textMuted: #CDD4E1

Retro tokens exposed by RetroTheme.tokens():
- Core tokens (hex strings):
  - primary, primaryLight, secondary, secondaryLight, success, error
  - background, surface, text, textMuted
- Aliases for retro UI:
  - accent -> primary
  - neon -> secondary
  - focusRingColor -> secondary
- Buttons:
  - buttonBg, buttonBgFocus, buttonText
- Tiles:
  - tileBg, tileBgFocus, tileBorder, tileBorderFocus
- HUD/Overlay:
  - hudBg, hudText
- Fonts:
  - fontSmall, fontMedium, fontLarge
- Retro assets and toggles:
  - focusRingAsset: pkg:/images/focus-ring.png
  - neonBorderBlueAsset: pkg:/images/retro/neon_border_blue.png
  - neonBorderAmberAsset: pkg:/images/retro/neon_border_amber.png
  - scanlineAsset: pkg:/images/retro/scanline_overlay.png
  - crtOverlayEnabled: boolean (from RetroTheme.enableCRTvfx)
  - neonBordersEnabled: boolean (from RetroTheme.enableNeonBorders)

Runtime toggles (Theme.xml fields on RetroTheme):
- enableCRTvfx (boolean, default true): enables CRT scanline overlay by design.
- enableNeonBorders (boolean, default true): components may use neon borders for focused states.

Usage patterns across components
- AppScene
  - Reads tokens via m.themeNode.tokens() and assigns m.top.theme for children.
  - Applies background color and may toggle scene-level scanlines based on tokens.crtOverlayEnabled.
- HomeScreen / DetailsScreen
  - Use theme.text / textMuted for Label colors.
  - Use ApplyRetroFocus(...) to keep consistent focus animations and, if desired, future neon borders.
- VideoPlayer
  - Uses theme.background for backdrop, theme.secondary for progressFill, HUD colors from hudBg/hudText.

Example: apply color
  label.color = colorToRGBA(m.top.theme.text)

Example: use accent/neon aliases
  buttonBgColor = colorToRGBA(m.top.theme.accent)
  focusOutline = colorToRGBA(m.top.theme.focusRingColor)

Extending theming
- To disable CRT overlay globally at runtime:
  scene.findNode("retroTheme").enableCRTvfx = false
- To disable neon borders:
  scene.findNode("retroTheme").enableNeonBorders = false
- To add new tokens, extend source/Theme.brs tokens() and document them here.

Assets
- Replace placeholder assets under images/retro/* with production-ready files.
- Focus ring and overlays are referenced via token URIs; ensure file names match or update tokens accordingly.
