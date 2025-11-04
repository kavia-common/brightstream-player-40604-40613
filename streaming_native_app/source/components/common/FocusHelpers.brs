' PUBLIC_INTERFACE
' FocusHelpers.brs - Common helpers for key handling and focus management across screens.
' Provides:
' - AttachStandardKeyHandler(node, handlerAA): attaches onKeyEvent with standardized behavior.
' - ApplyRetroFocus(node, theme): applies retro-themed focus visuals to supported nodes.
' - SaveFocusPath(root): returns an array path to the focused child.
' - RestoreFocusPath(root, path): restores focus based on a previously saved path.
' - Color conversion utilities.

' PUBLIC_INTERFACE
' Attach standardized onKeyEvent that dispatches to provided callbacks.
' handlerAA keys (optional): onUp, onDown, onLeft, onRight, onOK, onBack, onPlay, onPause
sub AttachStandardKeyHandler(node as object, handlerAA as object)
    if node = invalid then return
    ' Store callbacks on node's m for later use
    node.handlerAA = handlerAA
    node.observeField("keyEvent", "FocusHelpers_OnKeyEvent")
end sub

' The shared key event dispatcher used by AttachStandardKeyHandler.
function FocusHelpers_OnKeyEvent(key as string, press as boolean) as boolean
    ' Event is raised on component top, so m.top resolves to the owning node
    if not press then return false
    if m.top = invalid then return false

    ha = invalid
    if m.top.handlerAA <> invalid then ha = m.top.handlerAA else ha = {}

    ' Map Roku keys to provided handlers; return true if handled
    if key = "up" and ha.onUp <> invalid then return ha.onUp()
    if key = "down" and ha.onDown <> invalid then return ha.onDown()
    if key = "left" and ha.onLeft <> invalid then return ha.onLeft()
    if key = "right" and ha.onRight <> invalid then return ha.onRight()
    if (key = "ok" or key = "select") and ha.onOK <> invalid then return ha.onOK()
    if key = "back" and ha.onBack <> invalid then return ha.onBack()
    if (key = "play" or key = "playpause") and ha.onPlay <> invalid then return ha.onPlay()
    if key = "pause" and ha.onPause <> invalid then return ha.onPause()

    return false
end function

' PUBLIC_INTERFACE
' Apply retro focus visuals for standard nodes using theme tokens.
' For RowList/MarkupGrid, we can set focus animation style or colors where available.
' For Button, rely on built-in focus and theme colors where possible.
sub ApplyRetroFocus(node as object, theme as object)
    if node = invalid or theme = invalid then return

    nodeType = lcase(node.subtype())
    ' RowList focus animation
    if nodeType = "rowlist"
        ' floatingFocus is already in xml; ensure it remains
        node.vertFocusAnimationStyle = "floatingFocus"
        return
    end if

    ' Label / Buttons use color accents
    if nodeType = "label" and theme.text <> invalid
        ' No special focus on static labels
        return
    end if

    ' For Button, set its focused text color via focus visuals (limited API).
    ' We'll try to set focus ring assets through theme tokens if available in future.
end sub

' PUBLIC_INTERFACE
' Save focus in subtree as path of child indexes
function SaveFocusPath(root as object) as object
    path = []
    if root = invalid then return path
    if root.hasFocus()
        return path
    end if
    q = [{ node: root, path: [] }]
    while q.count() > 0
        cur = q.shift()
        kids = cur.node.getChildren(-1, 0)
        idx = 0
        for each c in kids
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

' PUBLIC_INTERFACE
' Restore focus using a previously saved path
sub RestoreFocusPath(root as object, path as object)
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

' PUBLIC_INTERFACE
' Convert "#RRGGBB" to RGBA int
function HexToRGBA(hex as string) as integer
    if hex = invalid then return &hFFFFFFFF
    if left(hex, 1) = "#"
        r = val("&h" + mid(hex, 2, 2))
        g = val("&h" + mid(hex, 4, 2))
        b = val("&h" + mid(hex, 6, 2))
        return (r << 24) + (g << 16) + (b << 8) + &hFF
    end if
    return &hFFFFFFFF
end function
