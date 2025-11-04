' PUBLIC_INTERFACE
' ContentModel.brs
' Provides normalized content item and feed parsing utilities.

' PUBLIC_INTERFACE
' Create a normalized content item assocarray from a raw assocarray.
' Ensures presence of expected keys: id, title, description, url, hdposterurl, category, duration, streamformat.
function CreateContentItem(raw as object) as object
    item = {
        id: ""
        title: ""
        description: ""
        url: ""
        hdposterurl: ""
        category: ""
        duration: 0
        streamformat: "mp4"
        meta: {}
    }

    if raw = invalid then return item

    if raw.id <> invalid then item.id = raw.id
    if raw.title <> invalid then item.title = raw.title
    if raw.description <> invalid then item.description = raw.description
    if raw.url <> invalid then item.url = raw.url
    if raw.streamformat <> invalid then item.streamformat = raw.streamformat

    ' poster fallbacks
    if raw.hdposterurl <> invalid then
        item.hdposterurl = raw.hdposterurl
    else if raw.poster <> invalid then
        item.hdposterurl = raw.poster
    else if raw.thumbnail <> invalid then
        item.hdposterurl = raw.thumbnail
    else
        item.hdposterurl = "pkg:/images/retro-bg.png"
    end if

    if raw.category <> invalid then item.category = raw.category
    if raw.duration <> invalid then item.duration = raw.duration

    ' carry any leftover fields under meta
    mkeys = []
    for each k in raw
        if not (k = "id" or k = "title" or k = "description" or k = "url" or k = "hdposterurl" or k = "poster" or k = "thumbnail" or k = "category" or k = "duration" or k = "streamformat")
            mkeys.push(k)
        end if
    end for
    meta = {}
    for each mk in mkeys
        meta[mk] = raw[mk]
    end for
    item.meta = meta

    return item
end function

' PUBLIC_INTERFACE
' Convert a normalized content item to a ContentNode suitable for RowList/MarkupGrid/Video.
function ContentItemToNode(item as object) as object
    node = CreateObject("roSGNode", "ContentNode")
    if item = invalid then return node
    node.id = item.id
    node.title = item.title
    node.description = item.description
    node.url = item.url
    node.hdposterurl = item.hdposterurl
    node.streamformat = item.streamformat
    if item.duration <> invalid then node.length = item.duration
    return node
end function

' PUBLIC_INTERFACE
' Parse a feed assocarray into a ContentNode tree in the form:
' root (ContentNode)
'   -> row (ContentNode) with .title
'       -> items (ContentNode children)
function ParseFeedToContent(feed as object) as object
    root = CreateObject("roSGNode", "ContentNode")
    if feed = invalid then return root

    ' Two supported shapes:
    ' 1) { rows: [ { title: "Row", items: [ {item} ... ] }, ... ] }
    ' 2) { items: [ {item} ... ] } -> wrapped into a single row "All"
    if feed.rows <> invalid and GetInterface(feed.rows, "ifArray") <> invalid then
        for each row in feed.rows
            rowNode = CreateObject("roSGNode", "ContentNode")
            if row.title <> invalid then rowNode.title = row.title else rowNode.title = "Row"
            if row.items <> invalid and GetInterface(row.items, "ifArray") <> invalid
                for each raw in row.items
                    norm = CreateContentItem(raw)
                    rowNode.appendChild(ContentItemToNode(norm))
                end for
            end if
            root.appendChild(rowNode)
        end for
        return root
    end if

    if feed.items <> invalid and GetInterface(feed.items, "ifArray") <> invalid then
        rowNode = CreateObject("roSGNode", "ContentNode")
        rowNode.title = "All"
        for each raw in feed.items
            norm = CreateContentItem(raw)
            rowNode.appendChild(ContentItemToNode(norm))
        end for
        root.appendChild(rowNode)
        return root
    end if

    ' Unknown shape, attempt best-effort: treat feed as a single item
    norm = CreateContentItem(feed)
    if norm.title <> "" or norm.url <> "" then
        rowNode = CreateObject("roSGNode", "ContentNode")
        rowNode.title = "All"
        rowNode.appendChild(ContentItemToNode(norm))
        root.appendChild(rowNode)
    end if

    return root
end function
