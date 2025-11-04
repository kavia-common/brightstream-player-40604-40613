# brightstream-player-40604-40613

This repository contains a native Qt sample alongside a Roku BrightScript project skeleton for a streaming application.

Contents:
- streaming_native_app/ (container root)
  - Qt app (CMakeLists.txt, src/, include/) remains intact
  - BrightScript Roku project added with:
    - manifest
    - source/ (BrightScript logic)
    - components/ (SceneGraph components)
    - images/ (placeholders: icons, splash, posters)
    - fonts/ (optional, empty)

Getting Started (Roku BrightScript):
1) Structure
   streaming_native_app/
   ├── manifest
   ├── components/
   │   ├── AppScene.xml
   │   ├── HomeScreen.xml
   │   ├── DetailsScreen.xml
   │   └── VideoPlayer.xml
   ├── source/
   │   ├── main.brs
   │   ├── AppScene.brs
   │   ├── HomeScreen.brs
   │   ├── DetailsScreen.brs
   │   └── VideoPlayer.brs
   ├── images/
   │   ├── mm_icon_focus.png
   │   ├── splash_hd.jpg
   │   ├── splash_sd.jpg
   │   ├── retro-bg.png
   │   └── focus-ring.png
   ├── fonts/
   │   └── .keep
   └── (Qt files remain unchanged)

2) Entry point
   - source/main.brs initializes roSGScreen and shows components/AppScene.xml (BrightAppScene).

3) HomeScreen bootstrap
   - HomeScreen shows a simple RowList of stub content.
   - Pressing OK triggers navigation to DetailsScreen via navAction.

4) Details and Player
   - DetailsScreen displays title, description, poster, and offers Play/Back buttons.
   - VideoPlayer is a stub with a Video node wired to play the provided item.url.

5) Packaging Notes
   - To side-load to a Roku device, zip the BrightScript files from streaming_native_app/ with this structure:
     manifest
     components/*
     source/*
     images/*
     fonts/* (optional)
   - Ensure placeholder assets are replaced with real images (.png/.jpg) and valid video URLs.
   - Do not remove or modify the existing Qt files; they are independent of the Roku project.

6) Theming
   - AppScene provides a basic Ocean Professional theme (blue primary, amber accents).
   - You can update colors in source/AppScene.brs setupTheme().

7) Coexistence with Qt
   - The Qt project builds a desktop app using CMake and Qt6.
   - The BrightScript project is separate and intended for Roku devices.
   - They live side-by-side under streaming_native_app/ without interfering with each other.

See streaming_native_app/BRIGHTSCRIPT_README.md for Roku-specific notes.
