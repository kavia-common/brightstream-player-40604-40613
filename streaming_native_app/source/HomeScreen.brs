' PUBLIC_INTERFACE
' HomeScreen.brs - Displays a simple grid of items and navigates to Details on OK.

sub init()
    m.rowlist = m.top.findNode("rowlist")
    m.rowlist.observeField("itemSelected", "onItemSelected")
    m.rowlist.observeField("rowItemSelected", "onItemSelected")

    setupTitle()
    populateContent()
end sub

sub setupTitle()
    t = m.top.findNode("title")
    if m.top.theme <> invalid
        t.color = colorToRGBA(m.top.theme.text)
    end if
end sub

' Create simple stub content
sub populateContent()
    contentRows = CreateObject("roSGNode", "ContentNode")

    row = CreateObject("roSGNode", "ContentNode")
    row.title = "Featured"

    for i = 1 to 10
        item = CreateObject("roSGNode", "ContentNode")
        item.title = "Retro Clip " + i.ToStr()
        item.description = "Sample description for clip " + i.ToStr()
        item.hdposterurl = "pkg:/images/retro-bg.png"
        ' video URL is placeholder
        item.url = "http://example.com/video" + i.ToStr() + ".mp4"
        row.appendChild(item)
    end for

    contentRows.appendChild(row)
    m.rowlist.content = contentRows
end sub

' When an item is selected with OK, navigate to details
sub onItemSelected()
    sel = m.rowlist.rowItemSelected
    if sel = invalid then return

    rowIndex = sel[0]
    itemIndex = sel[1]

    row = m.rowlist.content.getChild(rowIndex)
    if row = invalid then return
    item = row.getChild(itemIndex)
    if item = invalid then return

    m.top.navAction = { target: "details", item: {
        title: item.title
        description: item.description
        url: item.url
        hdposterurl: item.hdposterurl
    } }
end sub

' Convert hex string like "#RRGGBB" to BrightScript RGBA integer with opaque alpha
function colorToRGBA(hex as string) as integer
    if hex = invalid then return &hFFFFFFFF
    ' Expect #RRGGBB
    if left(hex, 1) = "#"
        r = val("&h" + mid(hex, 2, 2))
        g = val("&h" + mid(hex, 4, 2))
        b = val("&h" + mid(hex, 6, 2))
        return (r << 24) + (g << 16) + (b << 8) + &hFF
    end if
    return &hFFFFFFFF
end function
