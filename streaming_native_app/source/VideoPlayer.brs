' PUBLIC_INTERFACE
' VideoPlayer.brs - Enhanced player with transport controls, auto-hide HUD, and playback service integration.

sub init()
    m.video = m.top.findNode("player")
    m.backdrop = m.top.findNode("backdrop")
    m.hint = m.top.findNode("hint")
    m.hud = m.top.findNode("hud")
    m.hudBg = m.top.findNode("hudBg")
    m.lblTitle = m.top.findNode("title")
    m.lblTime = m.top.findNode("time")
    m.progressBg = m.top.findNode("progressBg")
    m.progressFill = m.top.findNode("progressFill")
    m.captions = m.top.findNode("captions")

    ' HUD auto-hide state
    m.hudVisible = true
    m.lastInputAt = GetNowMs()
    m.hudAutoHideMs = 3000

    applyTheme()

    ' Playback service
    m.playSvc = CreateObject("roSGNode", "Node")
    m.playSvc.script = "pkg:/source/services/PlaybackService.brs"
    m.playSvc.videoNode = m.video
    m.playSvc.observeField("state", "onSvcState")
    m.playSvc.observeField("event", "onSvcEvent")
    m.playSvc.observeField("error", "onSvcError")

    ' Update on content changes
    m.top.observeField("content", "onContentChanged")
    onContentChanged()

    ' Default focus to Video for transport key handling
    if m.video <> invalid then m.video.setFocus(true)

    ' Apply retro focus (no-op for Video but keeps consistency)
    ApplyRetroFocus(m.video, m.top.theme)

    ' Standardized key handling
    AttachStandardKeyHandler(m.top, {
        onBack: function() as boolean
            ' Stop playback, signal nav back
            if m.playSvc <> invalid then m.playSvc.control = "stop"
            m.top.navAction = { target: "back" }
            return true
        end function
        onOK: function() as boolean
            togglePlayPause()
            return true
        end function
        onLeft: function() as boolean
            seekDelta(-10)
            return true
        end function
        onRight: function() as boolean
            seekDelta(10)
            return true
        end function
        onUp: function() as boolean
            showHUD(true)
            return true
        end function
        onDown: function() as boolean
            ' Optionally hide HUD
            showHUD(false)
            return true
        end function
        onPlay: function() as boolean
            if m.playSvc <> invalid then m.playSvc.control = "play"
            touchHUD()
            return true
        end function
        onPause: function() as boolean
            if m.playSvc <> invalid then m.playSvc.control = "pause"
            touchHUD()
            return true
        end function
    })

    ' Kick off a timer for HUD auto-hide
    m.hudTimer = createTimer(300)
    m.hudTimer.control = "start"
end sub

' Theming and UI

sub applyTheme()
    if m.top.theme = invalid then return
    if m.backdrop <> invalid then m.backdrop.color = colorToRGBA(m.top.theme.background)
    if m.hint <> invalid then m.hint.color = colorToRGBA(m.top.theme.text)
    if m.hudBg <> invalid then m.hudBg.color = colorToRGBAWithAlpha(m.top.theme.hudBg, &hCC)
    if m.lblTitle <> invalid then m.lblTitle.color = colorToRGBA(m.top.theme.text)
    if m.lblTime <> invalid then m.lblTime.color = colorToRGBA(m.top.theme.text)
    if m.progressBg <> invalid then m.progressBg.color = colorToRGBA("#333C4D")
    if m.progressFill <> invalid then m.progressFill.color = colorToRGBA(m.top.theme.secondary)
end sub

' Content handling

sub onContentChanged()
    c = m.top.content
    if c = invalid then return
    ' UI labels
    if m.lblTitle <> invalid then
        if c.title <> invalid then m.lblTitle.text = c.title else m.lblTitle.text = ""
    end if

    ' Inform service and start playback
    m.playSvc.content = normalizeContent(c)
    m.playSvc.control = "start"
end sub

function normalizeContent(c as object) as object
    ' Ensure we have url, streamformat if derivable, and duration if present
    norm = {
        title: ""
        url: ""
        streamformat: invalid
        duration: 0
    }
    if c.title <> invalid then norm.title = c.title
    if c.url <> invalid then norm.url = c.url
    if c.streamformat <> invalid then norm.streamformat = c.streamformat
    if c.duration <> invalid then norm.duration = c.duration
    return norm
end function

' Service events

sub onSvcState()
    s = m.playSvc.state
    if s = invalid then return
    m.top.playerState = s
    updateProgressUI(s.position, s.duration)
    updateTimeLabel(s.position, s.duration)
end sub

sub onSvcEvent()
    e = m.playSvc.event
    if e = invalid then return

    m.top.playerEvent = e

    if e.type = "progress"
        updateProgressUI(e.position, e.duration)
        updateTimeLabel(e.position, e.duration)
    else if e.type = "completed"
        ' Signal up to AppScene to pop on completion
        m.top.navAction = { target: "back" }
    else if e.type = "error"
        ' Show error subtly via hint
        if m.hint <> invalid then m.hint.text = "Playback error. Press Back."
    end if
end sub

sub onSvcError()
    err = m.playSvc.error
    if err = invalid then return
    if m.hint <> invalid then m.hint.text = err
end sub

' Transport helpers

sub togglePlayPause()
    if m.playSvc = invalid then return
    s = m.playSvc.state
    if s <> invalid and s.state = "playing"
        m.playSvc.control = "pause"
    else
        m.playSvc.control = "play"
    end if
    touchHUD()
end sub

sub seekDelta(delta as integer)
    if m.playSvc = invalid then return
    if delta >= 0
        m.playSvc.control = "seek:" + delta.ToStr()
    else
        m.playSvc.control = "seek:" + delta.ToStr() ' negative supported
    end if
    touchHUD()
end sub

' HUD behavior

sub showHUD(visible as boolean)
    m.hudVisible = visible
    if m.hud <> invalid then m.hud.visible = visible
    if visible then m.lastInputAt = GetNowMs()
end sub

sub touchHUD()
    m.lastInputAt = GetNowMs()
    showHUD(true)
end sub

' Timer for auto-hide HUD
function createTimer(intervalMs as integer) as object
    t = CreateObject("roSGNode", "Timer")
    t.observeField("fire", "onHudTimerFire")
    t.duration = intervalMs / 1000.0
    t.repeat = true
    return t
end function

sub onHudTimerFire()
    if not m.hudVisible then return
    now = GetNowMs()
    if now - m.lastInputAt >= m.hudAutoHideMs
        showHUD(false)
    end if
end sub

' Progress UI

sub updateProgressUI(pos as dynamic, dur as dynamic)
    if m.progressFill = invalid or m.progressBg = invalid then return
    if type(dur) <> "Integer" and type(dur) <> "Float" then
        m.progressFill.width = 0
        return
    end if
    if dur <= 0 then
        m.progressFill.width = 0
        return
    end if
    p = 0
    if type(pos) = "Integer" or type(pos) = "Float"
        p = pos
    end if

    bgw = m.progressBg.width
    ratio = p / dur
    if ratio < 0 then ratio = 0
    if ratio > 1 then ratio = 1
    m.progressFill.width = int(bgw * ratio)
end sub

sub updateTimeLabel(pos as dynamic, dur as dynamic)
    if m.lblTime = invalid then return
    posStr = HumanizeDurationSafe(pos)
    durStr = HumanizeDurationSafe(dur)
    m.lblTime.text = posStr + "/" + durStr
end sub

function HumanizeDurationSafe(v as dynamic) as string
    if type(v) <> "Integer" and type(v) <> "Float" then return "0:00"
    s = int(v)
    m = s \ 60
    r = s mod 60
    return m.ToStr() + ":" + Right("0" + r.ToStr(), 2)
end function

' Utilities

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

' Convert #RRGGBB to RGBA with custom alpha 0x00-0xFF
function colorToRGBAWithAlpha(hex as string, a as integer) as integer
    if hex = invalid then return &hFFFFFF00 + (a and &hFF)
    if left(hex, 1) = "#"
        r = val("&h" + mid(hex, 2, 2))
        g = val("&h" + mid(hex, 4, 2))
        b = val("&h" + mid(hex, 6, 2))
        return (r << 24) + (g << 16) + (b << 8) + (a and &hFF)
    end if
    return &hFFFFFF00 + (a and &hFF)
end function

function GetNowMs() as integer
    ' roDateTime has second precision; multiply to ms for simple comparisons
    return CreateObject("roDateTime").AsSeconds() * 1000
end function
