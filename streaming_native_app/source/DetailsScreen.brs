' PUBLIC_INTERFACE
' DetailsScreen.brs - Shows selected item details and offers Play/Back actions.

sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.desc = m.top.findNode("desc")
    m.playBtn = m.top.findNode("playBtn")
    m.backBtn = m.top.findNode("backBtn")

    m.playBtn.observeField("buttonSelected", "onPlay")
    m.backBtn.observeField("buttonSelected", "onBack")

    applyTheme()
    updateFromItem()
    m.top.observeField("item", "updateFromItem")
end sub

sub applyTheme()
    if m.top.theme = invalid then return

    ' Apply text colors and fonts
    m.title.color = colorToRGBA(m.top.theme.text)
    m.desc.color = colorToRGBA(m.top.theme.text)
    m.title.font = "Large"
    m.desc.font = "Medium"

    ' Buttons: attempt to use theme colors where possible. Native <Button> exposes limited styling;
    ' we rely on focus ring and text for accents.
    if m.playBtn <> invalid then m.playBtn.text = "Play"
    if m.backBtn <> invalid then m.backBtn.text = "Back"
end sub

sub updateFromItem()
    it = m.top.item
    if it = invalid then return
    if it.hdposterurl <> invalid then m.poster.uri = it.hdposterurl
    if it.title <> invalid then m.title.text = it.title
    if it.description <> invalid then m.desc.text = it.description
end sub

sub onPlay()
    m.top.navAction = { target: "play", item: m.top.item }
end sub

sub onBack()
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
