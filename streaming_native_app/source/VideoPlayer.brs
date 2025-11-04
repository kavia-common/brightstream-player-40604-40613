' PUBLIC_INTERFACE
' VideoPlayer.brs - Minimal player stub to prepare for future expansion.
' Uses FocusHelpers for consistent key handling and retro focus visuals.

sub init()
    m.video = m.top.findNode("player")
    m.backdrop = m.top.findNode("backdrop")
    m.hint = m.top.findNode("hint")

    applyTheme()

    m.top.observeField("content", "onContentChanged")

    ' Default focus to the Video node so transport keys work
    if m.video <> invalid then m.video.setFocus(true)

    ' Apply retro focus to highlight video focus subtly (no-op for Video)
    ApplyRetroFocus(m.video, m.top.theme)

    ' Standardized key handling for transport and back
    AttachStandardKeyHandler(m.top, {
        onBack: function() as boolean
            m.top.navAction = { target: "back" }
            return true
        end function
        onPlay: function() as boolean
            if m.video <> invalid then m.video.control = "play"
            return true
        end function
        onPause: function() as boolean
            if m.video <> invalid then m.video.control = "pause"
            return true
        end function
        onOK: function() as boolean
            ' Toggle play/pause
            if m.video = invalid then return false
            state = m.video.state
            if state = "playing" then
                m.video.control = "pause"
            else
                m.video.control = "play"
            end if
            return true
        end function
        onUp: function() as boolean : return false : end function
        onDown: function() as boolean : return false : end function
        onLeft: function() as boolean : return false : end function
        onRight: function() as boolean : return false : end function
    })
end sub

sub applyTheme()
    if m.top.theme = invalid then return
    if m.backdrop <> invalid then m.backdrop.color = colorToRGBA(m.top.theme.background)
    if m.hint <> invalid then m.hint.color = colorToRGBA(m.top.theme.text)
end sub

sub onContentChanged()
    c = m.top.content
    if c = invalid then return

    ' Build a minimal content node for the Video component
    cn = CreateObject("roSGNode", "ContentNode")
    cn.title = c.title
    cn.streamformat = "mp4"
    ' This is a stub URL. Real content handling will be added later.
    cn.url = c.url

    m.video.content = cn
    ' Autoplay for now
    m.video.control = "play"
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
