' PUBLIC_INTERFACE
' StatusOverlay.brs - Simple overlay to show Loading and Error states with optional Retry button.
' Fields:
'   mode: "loading" | "error"
'   message: string
'   retryVisible: boolean
'   onRetry: assocarray used as a signal container: set to { fire: true } from BRS when retry pressed

sub init()
    m.scrim = m.top.findNode("scrim")
    m.card = m.top.findNode("card")
    m.cardBg = m.top.findNode("cardBg")
    m.lblTitle = m.top.findNode("title")
    m.lblMsg = m.top.findNode("msg")
    m.retryBtn = m.top.findNode("retryBtn")

    ' button event
    if m.retryBtn <> invalid then m.retryBtn.observeField("buttonSelected", "onRetryPressed")

    ' react to prop changes
    m.top.observeField("mode", "applyMode")
    m.top.observeField("message", "applyMessage")
    m.top.observeField("retryVisible", "applyRetryVisible")

    applyTheme()
    applyMode()
    applyMessage()
    applyRetryVisible()
end sub

sub applyTheme()
    if m.top.theme = invalid then return
    if m.cardBg <> invalid then m.cardBg.color = colorToRGBAWithAlpha(getToken("surface"), &hE6)
    if m.lblTitle <> invalid then m.lblTitle.color = colorToRGBA(getToken("text"))
    if m.lblMsg <> invalid then m.lblMsg.color = colorToRGBA(getToken("textMuted"))
end sub

sub applyMode()
    md = lcase(m.top.mode)
    if md = "loading"
        if m.lblTitle <> invalid then m.lblTitle.text = "Loading"
        if m.lblMsg <> invalid and (m.top.message = invalid or m.top.message = "") then m.lblMsg.text = "Please wait..."
        if m.retryBtn <> invalid then m.retryBtn.visible = false
    else if md = "error"
        if m.lblTitle <> invalid then m.lblTitle.text = "Something went wrong"
        if m.retryBtn <> invalid then m.retryBtn.visible = true
    else
        ' default
        if m.lblTitle <> invalid then m.lblTitle.text = ""
    end if
end sub

sub applyMessage()
    if m.lblMsg <> invalid then
        msg = m.top.message
        if msg = invalid then msg = ""
        m.lblMsg.text = msg
    end if
end sub

sub applyRetryVisible()
    if m.retryBtn <> invalid then
        m.retryBtn.visible = m.top.retryVisible = true and lcase(m.top.mode) = "error"
    end if
end sub

sub onRetryPressed()
    ' Emit a simple signal using onRetry field AA
    m.top.onRetry = { fire: true, ts: CreateObject("roDateTime").AsSeconds() }
end sub

' Helpers
function getToken(name as string) as string
    if m.top.theme <> invalid and m.top.theme[name] <> invalid then return m.top.theme[name]
    return "#FFFFFF"
end function

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

function colorToRGBAWithAlpha(hex as string, a as integer) as integer
    if hex = invalid then return ( &hFFFFFF00 + (a and &hFF) )
    if left(hex, 1) = "#"
        r = val("&h" + mid(hex, 2, 2))
        g = val("&h" + mid(hex, 4, 2))
        b = val("&h" + mid(hex, 6, 2))
        return (r << 24) + (g << 16) + (b << 8) + (a and &hFF)
    end if
    return ( &hFFFFFF00 + (a and &hFF) )
end function
