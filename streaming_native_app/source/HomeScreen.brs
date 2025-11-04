' PUBLIC_INTERFACE
' HomeScreen.brs - Displays rows of items from a feed and navigates to Details on OK.

sub init()
    m.rowlist = m.top.findNode("rowlist")
    m.titleNode = m.top.findNode("title")
    m.statusNode = m.top.findNode("status")

    if m.rowlist <> invalid then
        m.rowlist.observeField("itemSelected", "onItemSelected")
        m.rowlist.observeField("rowItemSelected", "onItemSelected")
    end if

    setupTitle()
    setupListStyle()
    loadFeedAsync()

    ' Ensure initial focus goes to the RowList for navigation after content arrives.
    ' We'll set focus in onFeedLoaded as well.
end sub

sub setupTitle()
    t = m.titleNode
    if m.top.theme <> invalid and t <> invalid
        t.color = colorToRGBA(m.top.theme.text)
        t.text = "BrightStream Retro"
    end if
    if m.statusNode <> invalid
        if m.top.theme <> invalid then m.statusNode.color = colorToRGBA(m.top.theme.textMuted)
        m.statusNode.text = "Loading..."
    end if
end sub

' Configure RowList visuals using theme tokens where possible
sub setupListStyle()
    if m.top.theme = invalid then return
    ' RowList style tweaks could be added here if supported by firmware/skin.
end sub

' Attempt to load feed asynchronously using a Task running FeedService.brs.
sub loadFeedAsync()
    cfg = AppConfig()

    m.feedTask = CreateObject("roSGNode", "Task")
    m.feedTask.control = "stop"
    ' Use FeedService as Task script
    m.feedTask.script = "pkg:/source/services/FeedService.brs"
    m.feedTask.observeField("output", "onFeedLoaded")
    m.feedTask.observeField("error", "onFeedError")

    ' Kick off with input containing desired URL (defaults inside FeedService if absent)
    m.feedTask.input = { url: cfg.feedUrl }
    m.feedTask.control = "run"
end sub

' Handle successful feed load
sub onFeedLoaded()
    if m.feedTask = invalid then return

    content = m.feedTask.output
    if content = invalid or content.getChildCount() = 0
        ' Fallback to local stub content
        setStatus("No feed content. Showing samples.")
        populateFallbackContent()
    else
        if m.statusNode <> invalid then m.statusNode.text = ""
        m.rowlist.content = content
        if m.rowlist <> invalid then m.rowlist.setFocus(true)
    end if
end sub

' Handle feed errors gracefully: show message and populate fallback
sub onFeedError()
    if m.feedTask = invalid then return
    err = m.feedTask.error
    if err = invalid then err = "Unable to load feed."
    setStatus(err + " Showing samples.")
    populateFallbackContent()
end sub

' Show status text
sub setStatus(msg as string)
    if m.statusNode <> invalid
        m.statusNode.text = msg
    end if
end sub

' Fallback stub content to ensure UI remains usable
sub populateFallbackContent()
    contentRows = CreateObject("roSGNode", "ContentNode")

    row = CreateObject("roSGNode", "ContentNode")
    row.title = "Samples"

    for i = 1 to 8
        item = CreateObject("roSGNode", "ContentNode")
        item.title = "Sample Clip " + i.ToStr()
        item.description = "Sample description for clip " + i.ToStr()
        item.hdposterurl = "pkg:/images/retro-bg.png"
        item.url = "http://example.com/video" + i.ToStr() + ".mp4"
        row.appendChild(item)
    end for

    contentRows.appendChild(row)
    m.rowlist.content = contentRows
    if m.rowlist <> invalid then m.rowlist.setFocus(true)
end sub

' When an item is selected with OK, navigate to details
sub onItemSelected()
    if m.rowlist = invalid then return
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
