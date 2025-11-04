' PUBLIC_INTERFACE
' PlaybackService.brs - Encapsulates SceneGraph Video playback wiring, state, and controls.
' Can be used by UI components to manage a Video node consistently.
'
' Usage (from a component):
'   m.svc = CreateObject("roSGNode", "Node")
'   m.svc.script = "pkg:/source/services/PlaybackService.brs"
'   m.svc.videoNode = m.video
'   m.svc.content = contentAA
'   m.svc.control = "start" ' initializes content on the Video node and begins playback
'
' Exposed fields (on m.top):
'   videoNode (Node)       : The SceneGraph Video node to control (required)
'   content (assocarray)   : Item with fields: url, title, streamformat?, length?, captions? (placeholder)
'   control (string)       : Write-only style commands: "start","play","pause","stop","seek:+/-sec","seekTo:sec"
'   state (assocarray)     : { state, position, duration, isPaused, isCompleted, error }
'   event (assocarray)     : Emits events like { type: "completed" | "error" | "progress" | "paused" | "playing" }
'   error (string)         : Last error description, if any

sub init()
    m.stateAA = {
        state: "init"
        position: 0
        duration: 0
        isPaused: false
        isCompleted: false
        error: ""
    }
    m.lastProgressEmit = 0
    m.progressEmitInterval = 500 ' ms throttle for progress events

    ' Observe required fields
    m.top.observeField("control", "onControl")
    m.top.observeField("content", "onContentChanged")
    m.top.observeField("videoNode", "onVideoAttached")
end sub

' PUBLIC_INTERFACE
' Handle assignment of the Video node: attach observers to its fields
sub onVideoAttached()
    if m.top.videoNode = invalid then return
    vid = m.top.videoNode

    ' Observe playback state fields
    vid.observeField("state", "onVideoState")
    vid.observeField("position", "onVideoPosition")
    vid.observeField("duration", "onVideoDuration")
    vid.observeField("streamInfo", "onVideoStreamInfo")
    vid.observeField("errorCode", "onVideoError")

    ' If content already present, prep immediately
    if m.top.content <> invalid then
        prepareContent()
    end if
end sub

' PUBLIC_INTERFACE
' Respond to content change by rebuilding the ContentNode for Video
sub onContentChanged()
    if m.top.videoNode = invalid then return
    prepareContent()
end sub

' Build a Video-compatible ContentNode and assign to the Video node
sub prepareContent()
    c = m.top.content
    vid = m.top.videoNode
    if c = invalid or vid = invalid then return

    cn = CreateObject("roSGNode", "ContentNode")
    cn.title = getString(c, "title", "")
    cn.url = getString(c, "url", "")
    cn.streamformat = detectStreamFormat(c)
    ' Optional: length in seconds
    if c.duration <> invalid then cn.length = c.duration

    ' Placeholder: captions - Roku uses 'SubtitleTracks' or 'captions' in different ways depending on format.
    ' This is a stub reserved for future integration.

    vid.content = cn
end sub

' PUBLIC_INTERFACE
' Control dispatcher: parses control string and applies to Video node
sub onControl()
    cmd = m.top.control
    if cmd = invalid then return
    m.top.control = invalid ' reset write-only control field

    vid = m.top.videoNode
    if vid = invalid then return

    if cmd = "start"
        ' Ensure content assigned and start playback
        if vid.content = invalid then prepareContent()
        vid.control = "play"
        return
    else if cmd = "play"
        vid.control = "play"
        return
    else if cmd = "pause"
        vid.control = "pause"
        return
    else if cmd = "stop"
        vid.control = "stop"
        return
    end if

    ' Seek commands: "seek:+15", "seek:-15", "seekTo:120"
    if left(cmd, 5) = "seek:"
        deltaStr = mid(cmd, 6)
        delta = val(deltaStr)
        newPos = max(0, vid.position + delta)
        if vid.duration > 0 then newPos = min(newPos, vid.duration - 1)
        vid.seek = newPos
        return
    else if left(cmd, 7) = "seekTo:"
        tgtStr = mid(cmd, 8)
        tgt = val(tgtStr)
        if tgt >= 0
            if vid.duration > 0 then tgt = min(tgt, vid.duration - 1)
            vid.seek = tgt
        end if
        return
    end if
end sub

' Video node observers

sub onVideoState()
    vid = m.top.videoNode
    if vid = invalid then return
    s = vid.state

    m.stateAA.state = s
    if s = "error"
        m.stateAA.error = "Playback error"
        m.top.error = m.stateAA.error
        m.top.event = { type: "error", detail: m.stateAA.error }
    else if s = "finished"
        m.stateAA.isCompleted = true
        m.top.event = { type: "completed" }
    else if s = "paused"
        m.stateAA.isPaused = true
        m.top.event = { type: "paused" }
    else if s = "playing"
        m.stateAA.isPaused = false
        m.top.event = { type: "playing" }
    end if

    m.top.state = m.stateAA
end sub

sub onVideoPosition()
    vid = m.top.videoNode
    if vid = invalid then return
    m.stateAA.position = vid.position
    m.top.state = m.stateAA

    ' Throttle progress events to avoid too many UI updates
    now = CreateObject("roDateTime").AsSeconds() * 1000
    if now - m.lastProgressEmit >= m.progressEmitInterval
        m.lastProgressEmit = now
        m.top.event = { type: "progress", position: m.stateAA.position, duration: m.stateAA.duration }
    end if
end sub

sub onVideoDuration()
    vid = m.top.videoNode
    if vid = invalid then return
    m.stateAA.duration = vid.duration
    m.top.state = m.stateAA
end sub

sub onVideoStreamInfo()
    ' Available when adaptive streams provide track info; not used yet.
end sub

sub onVideoError()
    vid = m.top.videoNode
    if vid = invalid then return
    code = vid.errorCode
    m.stateAA.error = "Video error code: " + code.ToStr()
    m.top.error = m.stateAA.error
    m.top.event = { type: "error", detail: m.stateAA.error, code: code }
    m.top.state = m.stateAA
end sub

' Helpers

function getString(aa as object, key as string, dflt as string) as string
    if aa = invalid then return dflt
    v = aa[key]
    if type(v) = "String" then return v
    return dflt
end function

' Determine streamformat based on explicit field or URL extension
function detectStreamFormat(c as object) as string
    if c.streamformat <> invalid and type(c.streamformat) = "String" and len(c.streamformat) > 0
        return LCase(c.streamformat)
    end if

    url = getString(c, "url", "")
    low = LCase(url)
    if right(low, 5) = ".m3u8" or instr(1, low, ".m3u8") > 0 then return "hls"
    if right(low, 5) = ".mpd" or instr(1, low, ".mpd") > 0 then return "dash"
    if right(low, 4) = ".ism" or instr(1, low, ".ism/manifest") > 0 then return "ism"
    ' Default: mp4
    return "mp4"
end function
