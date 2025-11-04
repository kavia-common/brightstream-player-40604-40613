' PUBLIC_INTERFACE
' RetroTheme - Theme provider with Ocean Professional palette and retro visuals.
' Provides:
' - tokens(): assocarray of color/font constants
' - getColor(name): integer RGBA for a named token
' - getFont(name): string font face key (for Label font attribute)
' - hexToRGBA(hex): helper conversion

sub init()
    ' Default tokens aligning with Ocean Professional palette and retro vibe
    m.top.tokens = {
        name: "Ocean Professional Retro"
        description: "Blue primary with amber accents; retro scanlines and neon borders"

        ' Core colors (hex strings)
        primary: "#2563EB"         ' blue-600
        primaryLight: "#60A5FA"    ' blue-400
        secondary: "#F59E0B"       ' amber-500
        secondaryLight: "#FBBF24"  ' amber-400
        background: "#0E1E40"      ' deep ocean
        surface: "#101826"         ' near black-blue
        text: "#FFFFFF"
        textMuted: "#CDD4E1"
        success: "#F59E0B"         ' stylistic success to match amber
        error: "#EF4444"

        ' Focus colors
        focusGlow: "#60A5FA"
        focusRing: "#F59E0B"

        ' Button tokens
        buttonBg: "#2563EB"
        buttonBgFocus: "#F59E0B"
        buttonText: "#FFFFFF"

        ' RowList/Tile tokens
        tileBg: "#101826"
        tileBgFocus: "#16243B"
        tileBorder: "#1F2A44"
        tileBorderFocus: "#F59E0B"

        ' Overlay / HUD
        hudBg: "#0B1220"
        hudText: "#FFFFFF"

        ' Fonts (Label font face keys; keep to Roku standard faces)
        fontSmall: "Small"
        fontMedium: "Medium"
        fontLarge: "Large"
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
