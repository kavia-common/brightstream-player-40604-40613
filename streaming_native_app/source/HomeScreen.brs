' PUBLIC_INTERFACE
' HomeScreen.brs - Displays rows of items from a feed and navigates to Details on OK.
' Uses FocusHelpers for consistent key handling and retro focus visuals.
sub init()
    m.rowlist = m.top.findNode("rowlist")
    m.titleNode = m.top.findNode("title")
    m.statusNode = m.top.findNode("status")
    m.overlay = m.top.findNode("overlay")

    if m.rowlist <> invalid then
        m.rowlist.observeField("itemSelected", "onItemSelected")
        m.rowlist.observeField("rowItemSelected", "onItemSelected")
    end if

    setupTitle()
    setupListStyle()
    showLoading("Loading content...")
    loadFeedAsync()

    ' Apply retro focus visuals
    if m.rowlist <> invalid then ApplyRetroFocus(m.rowlist, m.top.theme)

    ' Attach standardized key handler at component level for Back/OK fallback
    AttachStandardKeyHandler(m.top, {
        onBack: function() as boolean
            ' Let scene handle back; also provide navAction for consistency
            m.top.navAction = { target: "back" }
            return false ' do not consume to allow scene back
        end function
        onOK: function() as boolean
            ' If OK pressed and RowList has a current item, dispatch
            if m.rowlist <> invalid then
                onItemSelected()
                return true
            end if
            return false
        end function
        onUp: function() as boolean : return false : end function
        onDown: function() as boolean : return false : end function
        onLeft: function() as boolean : return false : end function
        onRight: function() as boolean : return false : end function
    })
end sub

sub setupTitle()
    t = m.titleNode
    if m.top.theme <> invalid and t <> invalid
        t.color = colorToRGBA(m.top.theme.text)
        t.text = "BrightStream Retro"
    end if
    if m.statusNode <> invalid
        if m.top.theme <> invalid then m.statusNode.color = colorToRGBA(m.top.theme.textMuted)
        m.statusNode.text = ""
    end if
end sub

' Configure RowList visuals using theme tokens where possible
sub setupListStyle()
    if m.top.theme = invalid then return
    ' RowList style tweaks could be added here if supported by firmware/skin.
end sub

sub showLoading(msg as string)
    if m.overlay <> invalid
        m.overlay.theme = m.top.theme
        m.overlay.mode = "loading"
        m.overlay.message = msg
        m.overlay.retryVisible = false
        m.overlay.visible = true
    end if
end sub

sub showError(msg as string, withRetry as boolean)
    if m.overlay <> invalid
        m.overlay.theme = m.top.theme
        m.overlay.mode = "error"
        m.overlay.message = msg
        m.overlay.retryVisible = withRetry
        m.overlay.visible = true
        if withRetry
            m.overlay.observeField("onRetry", "onRetryOverlay")
        end if
    end if
end sub

sub hideOverlay()
    if m.overlay <> invalid then m.overlay.visible = false
end sub

' Attempt to load feed asynchronously using a Task running FeedService.brs.
sub loadFeedAsync()
    cfg = AppConfig()
    LogInfo("HomeScreen: starting feed load", { url: cfg.feedUrl })

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
        LogWarn("Feed loaded but empty; showing fallback")
        setStatus("No feed content. Showing samples.")
        hideOverlay()
        populateFallbackContent()
    else
        LogInfo("Feed loaded successfully")
        if m.statusNode <> invalid then m.statusNode.text = ""
        m.rowlist.content = content
        if m.rowlist <> invalid then
            ApplyRetroFocus(m.rowlist, m.top.theme)
            m.rowlist.setFocus(true)
        end if
        hideOverlay()
    end if
end sub

' Handle feed errors gracefully: show message and populate fallback
sub onFeedError()
    if m.feedTask = invalid then return
    err = m.feedTask.error
    if err = invalid then err = "Unable to load feed."
    LogError("Feed error", { error: err })
    setStatus(err + " Showing samples.")
    showError(err, true)
    populateFallbackContent()
end sub

sub onRetryOverlay()
    LogInfo("Retry requested from overlay")
    showLoading("Retrying...")
    loadFeedAsync()
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

    LogDebug("Navigating to details", { index: itemIndex })
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
