' PUBLIC_INTERFACE
' AppScene.brs - Root scene script. Manages high-level navigation and theme.

sub init()
    m.top.backgroundURI = ""

    m.themeNode = m.top.findNode("retroTheme")
    m.bg = m.top.findNode("bg")
    m.scanlines = m.top.findNode("scanlines")
    m.contentHost = m.top.findNode("contentHost")

    setupTheme()
    applySceneTheme()

    ' Start at HomeScreen
    showHomeScreen()
end sub

' Initialize theme tokens from RetroTheme and expose as assocarray on scene for children
sub setupTheme()
    if m.themeNode <> invalid
        m.top.theme = m.themeNode.tokens()
    else
        ' Fallback directly if theme node missing
        m.top.theme = {
            primary: "#2563EB"
            secondary: "#F59E0B"
            success: "#F59E0B"
            error: "#EF4444"
            background: "#0E1E40"
            surface: "#101826"
            text: "#FFFFFF"
            textMuted: "#CDD4E1"
            buttonBg: "#2563EB"
            buttonBgFocus: "#F59E0B"
            buttonText: "#FFFFFF"
        }
    end if
end sub

' Apply scene-level visuals based on theme (bg color, optional overlays)
sub applySceneTheme()
    if m.top.theme <> invalid
        bgHex = m.top.theme.background
        m.bg.color = colorToRGBA(bgHex)
    end if

    ' Optionally enable scanlines for the retro vibe
    if m.scanlines <> invalid then m.scanlines.visible = true
end sub

' PUBLIC_INTERFACE
' Show the HomeScreen
sub showHomeScreen()
    clearHost()
    home = createObject("roSGNode", "HomeScreen")
    home.observeField("navAction", "onHomeNav")
    home.theme = m.top.theme
    m.contentHost.appendChild(home)
    m.current = home
end sub

' PUBLIC_INTERFACE
' Callback for navigation events from HomeScreen
sub onHomeNav()
    action = m.current.navAction
    if action = invalid then return
    if action.target = "details"
        showDetailsScreen(action.item)
    end if
end sub

' PUBLIC_INTERFACE
' Show the Details screen
sub showDetailsScreen(item as object)
    clearHost()
    det = createObject("roSGNode", "DetailsScreen")
    det.item = item
    det.theme = m.top.theme
    det.observeField("navAction", "onDetailsNav")
    m.contentHost.appendChild(det)
    m.current = det
end sub

' PUBLIC_INTERFACE
' Handle navigation from DetailsScreen
sub onDetailsNav()
    action = m.current.navAction
    if action = invalid then return
    if action.target = "back"
        showHomeScreen()
    else if action.target = "play"
        showVideoPlayer(action.item)
    end if
end sub

' PUBLIC_INTERFACE
' Show Video Player with selected item
sub showVideoPlayer(item as object)
    clearHost()
    vp = createObject("roSGNode", "VideoPlayer")
    vp.content = item
    vp.theme = m.top.theme
    vp.observeField("navAction", "onPlayerNav")
    m.contentHost.appendChild(vp)
    m.current = vp
end sub

sub onPlayerNav()
    action = m.current.navAction
    if action = invalid then return
    if action.target = "back"
        ' Return to details if we came from there, else home
        if m.lastDetailsItem <> invalid
            showDetailsScreen(m.lastDetailsItem)
        else
            showHomeScreen()
        end if
    end if
end sub

' Utility to clear and remember details item where appropriate
sub clearHost()
    if m.current <> invalid
        if m.current.subtype() = "DetailsScreen"
            m.lastDetailsItem = m.current.item
        end if
    end if
    for each n in m.contentHost.getChildren(-1, 0)
        n.removeNode()
    end for
end sub

' PUBLIC_INTERFACE
' Convert #RRGGBB to RGBA (opaque)
function colorToRGBA(hex as string) as integer
    if hex = invalid then return &hFFFFFFFF
    if left(hex, 1) = "#"
        r = val("&h" + mid(hex, 2, 2))
        g = val("&h" + mid(hex, 4, 2))
        b = val("&h" + mid(hex, 6, 2))
        return (r << 24) + (g << 16) + (b << 8) + &hFF
    end if
    return &hFFFFFFFF
end function
