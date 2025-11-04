' PUBLIC_INTERFACE
' DetailsScreen.brs - Shows selected item details and offers Play/Back actions.
' Uses FocusHelpers for consistent key handling and retro focus visuals.
sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.desc = m.top.findNode("desc")
    m.playBtn = m.top.findNode("playBtn")
    m.backBtn = m.top.findNode("backBtn")
    m.overlay = m.top.findNode("overlay")

    m.playBtn.observeField("buttonSelected", "onPlay")
    m.backBtn.observeField("buttonSelected", "onBack")

    applyTheme()
    updateFromItem()
    m.top.observeField("item", "updateFromItem")

    ' Apply retro focus visuals where possible
    ApplyRetroFocus(m.playBtn, m.top.theme)
    ApplyRetroFocus(m.backBtn, m.top.theme)

    ' Default focus to Play button for quick start
    if m.playBtn <> invalid then m.playBtn.setFocus(true)

    ' Standardized key handling: Back, OK dispatch, navigation keys no-op
    AttachStandardKeyHandler(m.top, {
        onBack: function() as boolean
            m.top.navAction = { target: "back" }
            return true
        end function
        onOK: function() as boolean
            ' Prefer play button behavior when focused on buttons
            if m.playBtn <> invalid and m.playBtn.hasFocus()
                onPlay()
                return true
            end if
            ' If focus not on button, still treat OK as Play
            onPlay()
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

    ' Apply text colors and fonts
    if m.title <> invalid then
        m.title.color = colorToRGBA(m.top.theme.text)
        m.title.font = "Large"
    end if
    if m.desc <> invalid then
        m.desc.color = colorToRGBA(m.top.theme.textMuted)
        m.desc.font = "Medium"
    end if

    ' Buttons: rely on built-in focus with theme accents
    if m.playBtn <> invalid then m.playBtn.text = "Play"
    if m.backBtn <> invalid then m.backBtn.text = "Back"
end sub

sub updateFromItem()
    it = m.top.item
    if it = invalid then
        LogWarn("DetailsScreen: item invalid; showing error overlay")
        showError("No item to display.", false)
        return
    end if
    hideOverlay()
    if it.hdposterurl <> invalid then m.poster.uri = it.hdposterurl
    if it.title <> invalid then m.title.text = it.title
    if it.description <> invalid then m.desc.text = it.description
end sub

sub showError(msg as string, withRetry as boolean)
    if m.overlay = invalid then return
    m.overlay.theme = m.top.theme
    m.overlay.mode = "error"
    m.overlay.message = msg
    m.overlay.retryVisible = withRetry
    m.overlay.visible = true
end sub

sub hideOverlay()
    if m.overlay <> invalid then m.overlay.visible = false
end sub

sub onPlay()
    LogInfo("DetailsScreen: play requested")
    m.top.navAction = { target: "play", item: m.top.item }
end sub

sub onBack()
    LogInfo("DetailsScreen: back requested")
    m.top.navAction = { target: "back" }
end sub

' Convert #RRGGBB to RGBA
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
