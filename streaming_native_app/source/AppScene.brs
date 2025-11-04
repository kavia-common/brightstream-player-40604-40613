' PUBLIC_INTERFACE
' AppScene.brs - Root scene script. Manages high-level navigation, back stack, and theme.

sub init()
    ' Node refs
    m.top.backgroundURI = ""
    m.themeNode = m.top.findNode("retroTheme")
    m.bg = m.top.findNode("bg")
    m.scanlines = m.top.findNode("scanlines")
    m.contentHost = m.top.findNode("contentHost")

    ' Navigation state (stack of {key: string, node: Node, params: assocarray, focusPath: object})
    m.navStack = []
    m.current = invalid
    m.lastDetailsItem = invalid

    ' Back key handling and global key routing
    m.top.setFocus(true)
    m.top.observeField("keyEvent", "onKeyEvent")

    setupTheme()
    applySceneTheme()

    ' Start at HomeScreen
    pushScreen("home", invalid)
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

' ---------------------------
' Navigation Helpers
' ---------------------------

' PUBLIC_INTERFACE
' Push a new screen onto the stack
sub pushScreen(target as string, params as object)
    ' Save current focus path if any
    if m.current <> invalid
        ' Use common helper if available
        if GetInterface(m.current, "ifSGNodeField") <> invalid
            m.currentFocus = SaveFocusPath(m.current)
        else
            m.currentFocus = getFocusedChildPath(m.current)
        end if
        stackEntry = {
            key: m.current.subtype()
            node: m.current
            params: m.currentParams
            focusPath: m.currentFocus
        }
        m.navStack.push(stackEntry)
        m.current.visible = false
        m.current.setFocus(false)
    end if

    ' Create next screen and attach listeners
    if target = "home"
        home = createObject("roSGNode", "HomeScreen")
        home.theme = m.top.theme
        home.observeField("navAction", "onHomeNav")
        m.contentHost.appendChild(home)
        home.setFocus(true)
        m.current = home
        m.currentParams = invalid
    else if target = "details"
        det = createObject("roSGNode", "DetailsScreen")
        det.item = params
        det.theme = m.top.theme
        det.observeField("navAction", "onDetailsNav")
        m.contentHost.appendChild(det)
        det.setFocus(true)
        m.current = det
        m.currentParams = params
        m.lastDetailsItem = params
    else if target = "player"
        vp = createObject("roSGNode", "VideoPlayer")
        vp.content = params
        vp.theme = m.top.theme
        vp.observeField("navAction", "onPlayerNav")
        m.contentHost.appendChild(vp)
        vp.setFocus(true)
        m.current = vp
        m.currentParams = params
    end if
end sub

' PUBLIC_INTERFACE
' Pop current screen and restore previous with focus
sub popScreen()
    if m.current <> invalid
        ' Remove current node
        safeRemoveNode(m.current)
        m.current = invalid
        m.currentParams = invalid
    end if

    if m.navStack.count() > 0
        prev = m.navStack.pop()
        node = prev.node
        node.visible = true
        m.contentHost.appendChild(node)
        ' Prefer common helper if present
        if prev.focusPath <> invalid and prev.focusPath.count() > 0
            RestoreFocusPath(node, prev.focusPath)
        else
            restoreFocusPath(node, prev.focusPath)
        end if
        m.current = node
        m.currentParams = prev.params
    else
        ' If nothing to pop, go back to home
        ' Avoid infinite recursion if already home
        if m.current = invalid or (m.current <> invalid and m.current.subtype() <> "HomeScreen")
            pushScreen("home", invalid)
        end if
    end if
end sub

' Safely remove node from parent
sub safeRemoveNode(n as object)
    if n = invalid then return
    p = n.getParent()
    if p <> invalid then p.removeChild(n)
end sub

' Get focused child path in a subtree to restore focus later
function getFocusedChildPath(root as object) as object
    ' Walk to find focused node; build path as array of indexes
    path = []
    if root = invalid then return path
    if root.hasFocus()
        return path
    end if
    ' BFS search for focus and track child indices
    q = [{ node: root, path: [] }]
    while q.count() > 0
        cur = q.shift()
        ch = cur.node.getChildren(-1, 0)
        idx = 0
        for each c in ch
            newPath = cur.path.clone()
            newPath.push(idx)
            if c.hasFocus()
                return newPath
            end if
            q.push({ node: c, path: newPath })
            idx = idx + 1
        end for
    end while
    return []
end function

' Restore focus based on a path of child indexes
sub restoreFocusPath(root as object, path as object)
    if root = invalid then return
    if path = invalid or path.count() = 0
        root.setFocus(true)
        return
    end if
    node = root
    for each i in path
        kids = node.getChildren(-1, 0)
        if i >= 0 and i < kids.count()
            node = kids[i]
        else
            exit for
        end if
    end for
    if node <> invalid then node.setFocus(true) else root.setFocus(true)
end sub

' ---------------------------
' Navigation Event Handlers
' ---------------------------

' PUBLIC_INTERFACE
' Callback for navigation events from HomeScreen
sub onHomeNav()
    if m.current = invalid then return
    action = m.current.navAction
    if action = invalid then return
    if action.target = "details"
        pushScreen("details", action.item)
    end if
end sub

' PUBLIC_INTERFACE
' Handle navigation from DetailsScreen
sub onDetailsNav()
    if m.current = invalid then return
    action = m.current.navAction
    if action = invalid then return
    if action.target = "back"
        popScreen()
    else if action.target = "play"
        ' Ensure item is passed as content to player
        pushScreen("player", action.item)
    end if
end sub

' PUBLIC_INTERFACE
' Handle navigation from VideoPlayer
sub onPlayerNav()
    if m.current = invalid then return
    action = m.current.navAction
    if action = invalid then return
    if action.target = "back"
        popScreen()
    end if
end sub

' ---------------------------
' Key Handling
' ---------------------------

' PUBLIC_INTERFACE
' Capture Back key to pop to previous screen and restore focus.
function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "back"
        ' If player or details/home, pop if possible
        if m.navStack.count() > 0
            popScreen()
            return true
        else
            ' Allow default behavior to exit app from Home
            return false
        end if
    end if

    ' Let child components handle navigation keys; scene does not consume them
    return false
end function

' ---------------------------
' Color helper
' ---------------------------

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
