' PUBLIC_INTERFACE
' RetroTheme - Theme provider with Ocean Professional palette and retro visuals.
' Provides:
' - tokens(): assocarray of color/font/visual tokens that map the Ocean Professional palette:
'     primary=#2563EB, secondary/success=#F59E0B, error=#EF4444, text=#111827 (used as base for light contexts),
'     plus dark-scene overrides suited to TV UIs (background/surface).
'   Retro aliases:
'     accent -> primary
'     neon   -> secondary
'     focusRingColor -> secondary
'     crtOverlayEnabled -> enableCRTvfx field on component
'     neonBordersEnabled -> enableNeonBorders field on component
'     focusRingAsset -> pkg:/images/focus-ring.png
'     neonBorderBlueAsset/neonBorderAmberAsset/scanlineAsset -> asset URIs
' - getColor(name): integer RGBA for a named token
' - getFont(name): string font face key (for Label font attribute)
' - hexToRGBA(hex): helper conversion
'
' The tokens AA is safe to pass down to any component via the "theme" field.

sub init()
    ' Build token set from Ocean Professional with retro extensions.
    ' Note: We prefer a dark TV background/surface while keeping the palette mappings true.
    ocean = {
        primary: "#2563EB"      ' Ocean Professional primary
        secondary: "#F59E0B"    ' Secondary + success
        success: "#F59E0B"
        error: "#EF4444"
        textBase: "#111827"     ' Tailwind gray-900; used when on light backgrounds
        background: "#0E1E40"   ' Deep ocean for TV-safe background
        surface: "#101826"      ' Near-black blue surface
        textOnDark: "#FFFFFF"
        textMutedOnDark: "#CDD4E1"
        primaryLight: "#60A5FA"
        secondaryLight: "#FBBF24"
    }

    ' Respect component toggles when composing tokens
    crtEnabled = true
    neonEnabled = true
    if m.top.enableCRTvfx <> invalid then crtEnabled = m.top.enableCRTvfx
    if m.top.enableNeonBorders <> invalid then neonEnabled = m.top.enableNeonBorders

    m.top.tokens = {
        name: "Ocean Professional Retro",
        description: "Ocean Professional mapped to retro tokens with optional CRT overlay and neon borders",

        ' Core palette mappings
        primary: ocean.primary,
        primaryLight: ocean.primaryLight,
        secondary: ocean.secondary,
        secondaryLight: ocean.secondaryLight,
        success: ocean.success,
        error: ocean.error,

        ' Scene/background
        background: ocean.background,
        surface: ocean.surface,

        ' Text for TV dark backgrounds
        text: ocean.textOnDark,
        textMuted: ocean.textMutedOnDark,

        ' Retro aliases for consumers
        accent: ocean.primary,                 ' PUBLIC retro alias
        neon: ocean.secondary,                 ' PUBLIC retro alias
        focusRingColor: ocean.secondary,       ' PUBLIC retro alias for ring color

        ' Buttons
        buttonBg: ocean.primary,
        buttonBgFocus: ocean.secondary,
        buttonText: "#FFFFFF",

        ' Tiles
        tileBg: ocean.surface,
        tileBgFocus: "#16243B",
        tileBorder: "#1F2A44",
        tileBorderFocus: ocean.secondary,

        ' HUD/Overlay
        hudBg: "#0B1220",
        hudText: "#FFFFFF",

        ' Fonts
        fontSmall: "Small",
        fontMedium: "Medium",
        fontLarge: "Large",

        ' Retro assets and toggles (PUBLIC retro tokens)
        focusRingAsset: "pkg:/images/focus-ring.png",
        neonBorderBlueAsset: "pkg:/images/retro/neon_border_blue.png",
        neonBorderAmberAsset: "pkg:/images/retro/neon_border_amber.png",
        scanlineAsset: "pkg:/images/retro/scanline_overlay.png",
        crtOverlayEnabled: crtEnabled,
        neonBordersEnabled: neonEnabled
    }
end sub

' PUBLIC_INTERFACE
' Returns current token set.
function tokens() as object
    return m.top.tokens
end function

' PUBLIC_INTERFACE
' Get color by token name as integer RGBA; returns white if not found.
function getColor(name as string) as integer
    if m.top.tokens = invalid then return &hFFFFFFFF
    hex = m.top.tokens[name]
    if type(hex) = "String" then return hexToRGBA(hex)
    return &hFFFFFFFF
end function

' PUBLIC_INTERFACE
' Get font by logical name; falls back to "Medium"
function getFont(name as string) as string
    if m.top.tokens = invalid then return "Medium"
    f = m.top.tokens[name]
    if type(f) = "String" then return f
    return "Medium"
end function

' PUBLIC_INTERFACE
' Convert "#RRGGBB" to BrightScript RGBA integer (opaque alpha)
function hexToRGBA(hex as string) as integer
    if hex = invalid then return &hFFFFFFFF
    if left(hex, 1) = "#"
        r = val("&h" + mid(hex, 2, 2))
        g = val("&h" + mid(hex, 4, 2))
        b = val("&h" + mid(hex, 6, 2))
        return (r << 24) + (g << 16) + (b << 8) + &hFF
    end if
    return &hFFFFFFFF
end function
