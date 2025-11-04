' PUBLIC_INTERFACE
' VideoPlayer.brs - Minimal player stub to prepare for future expansion.

sub init()
    m.video = m.top.findNode("player")
    m.top.observeField("content", "onContentChanged")
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

' Roku will handle Back button by bubbling key events to Scene normally.
' The parent scene can handle setting navAction=back via key handlers if needed.
