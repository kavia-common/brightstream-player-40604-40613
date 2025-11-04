# BrightStream Retro (Roku BrightScript) - Manual Smoke Test Plan

Scope
- Validate basic app launch, navigation (Home → Details → Video), playback controls, focus restoration on back navigation, error/loading overlays, and feed failure fallback.
- Verify retro visual themes and overlays.
- Include guidance to point the app at the included sample feed, and a brief sideload verification checklist.

Prerequisites
- Roku device with Developer Mode enabled.
- Network connectivity to the device.
- Sideload package built with scripts/roku_pack.sh and deployed with scripts/roku_deploy.sh.
- Remote or equivalent control (OK/Select, Back, Up/Down/Left/Right, Play/Pause).

References
- Packaging: scripts/roku_pack.sh (outputs build/roku_app.zip)
- Deployment: scripts/roku_deploy.sh
- Theme and tokens: components/Theme.xml, source/Theme.brs
- Sample feed file: test/feeds/sample-feed.json
- Default AppConfig feed URL: source/config/config.brs

Note about using the local sample feed
- The app is already configured to load the packaged sample feed by default:
  - In source/config/config.brs:
    feedUrl: "pkg:/test/feeds/sample-feed.json"
- If you changed AppConfig().feedUrl to a remote URL for testing, you can switch back to the packaged file by setting:
  - feedUrl: "pkg:/test/feeds/sample-feed.json"
- The pkg:/ path references a file included in the app package; the existing test/feeds/sample-feed.json is included in the repository and will be packaged.

Test Areas and Steps

1) App Launch and Home Screen
- Steps:
  1. Launch the app from Roku home after sideloading.
  2. Observe initial background and any scene-level overlays.
- Expected:
  - App shows the Home screen (title “BrightStream Retro”).
  - Background uses the deep ocean color palette (e.g., dark blue background).
  - Scanline CRT overlay may be present if enabled by theme (RetroTheme.enableCRTvfx defaults true).
  - Title text is legible and bright (white), status area is empty or shows “Loading content…” while fetching.
  - No errors shown on fresh launch with sample feed.

2) Feed Load Success Path (using packaged sample feed)
- Steps:
  1. Wait for loading to complete on Home screen.
  2. Confirm rows and items appear from the sample feed.
- Expected:
  - A “Featured” row and a “Classics” row from sample-feed.json are displayed.
  - Tiles show the “retro-bg.png” image from pkg:/images/retro-bg.png.
  - Focus ring or focus animation style is apparent (RowList uses floatingFocus).
  - Status overlay (if shown) hides after data appears.

3) Navigation: Home → Details
- Steps:
  1. Use Left/Right to focus an item in “Featured”.
  2. Press OK.
- Expected:
  - Details screen opens with:
    - Poster thumbnail.
    - Title/description from the item.
    - Two buttons: Play and Back.
  - Focus should land on Play by default.
  - Text and UI respect retro theme colors (title = white, description = muted white).

4) Navigation: Details → Video (Play)
- Steps:
  1. From Details, press OK (Play) or select Play and OK.
- Expected:
  - Video screen opens with:
    - Dark backdrop.
    - Video node area covering the screen.
    - HUD at bottom (auto-hide after a few seconds).
    - Title on HUD.
    - Progress bar background and amber progress fill.
    - Transport hints label.
  - A “Loading…” overlay briefly appears then hides when playback starts (if the stream is valid).

5) Playback Controls
- Steps:
  - During playback:
    a) Press OK to toggle Play/Pause.
    b) Press Play and Pause (if available on your remote) to confirm mapped behavior.
    c) Press Left/Right to seek -10s/+10s.
    d) Press Up to show the HUD immediately.
    e) Wait 3+ seconds of inactivity to confirm HUD auto-hides.
- Expected:
  - OK toggles between play and pause; HUD remains visible briefly and then auto-hides.
  - Play/Pause keys also work when applicable.
  - Left/Right seek updates progress and time label.
  - Up shows HUD; HUD auto-hides after ~3 seconds without input.
  - Time label updates in mm:ss/mm:ss format.

6) Navigation Back and Focus Restoration
- Steps:
  1. From Video screen, press Back.
  2. Expect return to Details screen, then press Back again to return to Home.
  3. Verify focus returns to the previously selected item on the Home screen or to a reasonable default.
- Expected:
  - Back from Video returns to Details with Play focused (or previously focused control).
  - Back from Details returns to Home with focus restored as best as possible to the previously selected tile.
  - No crashes, no orphan overlays.

7) Error and Loading Overlays
- Steps:
  1. Observe Home screen during initial loading: loading overlay should show “Loading content…”.
  2. If network feed is used and fails:
     - Force a failure (wrong URL, unreachable host) and reload the app.
- Expected:
  - Loading overlay shows during feed load.
  - On error, an error overlay displays with a Retry button.
  - Pressing Retry triggers another load attempt and updates the overlay/state text.

8) Feed Failure Fallback
- Steps:
  1. Set AppConfig().feedUrl to an invalid URL (e.g., "https://invalid/doesnotexist.json").
  2. Relaunch the app.
- Expected:
  - Home screen shows error overlay with Retry.
  - Status area indicates fallback to samples.
  - The grid populates with fallback sample content (e.g., “Sample Clip 1..8” items).
  - Navigation and Details/Video flows still work (using the fallback items).

9) Retro Theme Visual Verification
- Steps:
  1. On Home, Details, and Video screens, visually inspect:
     - Colors: primary (#2563EB), secondary/amber (#F59E0B), error (#EF4444), text white on dark surfaces.
     - Background and surface shades: deep ocean background and near-black/blue surfaces.
     - HUD: amber progress fill, dark translucent background.
  2. Verify presence of retro overlays/borders when enabled:
     - CRT scanline overlay visible (Theme.enableCRTvfx default true).
     - Neon borders (Theme.enableNeonBorders default true) – placeholder assets in images/retro.
- Expected:
  - Theme tokens are consistently applied to labels, backgrounds, and HUD.
  - Overlays/borders appear if enabled and assets are present (placeholders are OK for smoke).
  - Focus visuals are consistent across screens.

10) Details Screen Error Handling
- Steps:
  1. From Home, attempt to navigate to Details with an item that might be malformed (optional synthetic test).
  2. If item is invalid, verify Details shows an error overlay instead of crashing.
- Expected:
  - Error overlay with a clear message, no app crash.
  - Back returns to Home normally.

Sideload Verification Checklist (after packaging)
- Package:
  - Run: bash scripts/roku_pack.sh
  - Confirm output at: build/roku_app.zip
  - ZIP contains only:
    - manifest
    - source/
    - components/
    - images/
    - fonts/ (optional)
- Deploy:
  - Export environment:
    - ROKU_DEV_TARGET=<device-ip>
    - ROKU_DEV_USERNAME=rokudev
    - ROKU_DEV_PASSWORD=<password>
  - Run: bash scripts/roku_deploy.sh build/roku_app.zip
  - Confirm “Sideloaded and installed successfully.” in script output.
- Launch:
  - On Roku device, return to Home and find the sideloaded app.
  - Launch and proceed with the smoke steps above.

Notes and Tips
- If you switch AppConfig().feedUrl between remote and packaged:
  - Remote example: "https://example.com/feed.json"
  - Packaged/local: "pkg:/test/feeds/sample-feed.json"
- If overlays are too obtrusive during a test pass, you can temporarily disable retro toggles at runtime in AppScene by setting:
  - scene.findNode("retroTheme").enableCRTvfx = false
  - scene.findNode("retroTheme").enableNeonBorders = false
- For troubleshooting, use console logs emitted by Log.brs helpers (INFO/WARN/ERROR).

Pass/Fail Criteria
- Pass if:
  - App launches, loads feed (or shows fallback), and allows Home → Details → Video navigation.
  - Playback controls (play/pause/seek, Up to show HUD, Back to exit) function as expected.
  - Focus restoration works when backing out from Video to Details to Home.
  - Overlays for loading and errors appear with correct content and do not block normal use beyond necessary.
  - Retro visual elements (palette, overlays, progress bar color) appear consistently.
- Fail if:
  - Crashes, infinite spinners, or missing focus on navigation.
  - Controls do not respond or seek is not reflected in UI.
  - Overlays obscure the UI persistently or do not appear when expected.
  - Visual theme colors are incorrect or unreadable on TV.
