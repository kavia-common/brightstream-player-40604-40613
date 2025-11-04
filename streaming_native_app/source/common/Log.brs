' PUBLIC_INTERFACE
' Log.brs - Centralized logging utilities for the app.
' Usage:
'   LogInfo("message", { context: "HomeScreen" })
'   LogWarn("warning")
'   LogError("error message", { code: 123 })
'   LogDebug("debug details")
' Ensures consistent prefixing and safe assocarray -> string formatting.

' PUBLIC_INTERFACE
' Info level log
sub LogInfo(msg as string, meta = invalid as dynamic)
    _logInternal("INFO", msg, meta)
end sub

' PUBLIC_INTERFACE
' Warning level log
sub LogWarn(msg as string, meta = invalid as dynamic)
    _logInternal("WARN", msg, meta)
end sub

' PUBLIC_INTERFACE
' Error level log
sub LogError(msg as string, meta = invalid as dynamic)
    _logInternal("ERROR", msg, meta)
end sub

' PUBLIC_INTERFACE
' Debug level log
sub LogDebug(msg as string, meta = invalid as dynamic)
    _logInternal("DEBUG", msg, meta)
end sub

' INTERNAL
sub _logInternal(level as string, msg as string, meta = invalid as dynamic)
    timestamp = CreateObject("roDateTime").AsDateString() + " " + CreateObject("roDateTime").AsTimeString()
    metaStr = ""
    if meta <> invalid then metaStr = " " + _safeToString(meta)
    print "[BrightStream][" + level + "][" + timestamp + "] " + msg + metaStr
end sub

' Convert assocarray/array to a stable printable string
function _safeToString(v as dynamic) as string
    t = type(v)
    if t = "roAssociativeArray"
        parts = []
        for each k in v
            parts.push(k + ":" + _safeToString(v[k]))
        end for
        return "{" + Join(parts, ",") + "}"
    else if t = "roArray"
        parts = []
        for each e in v
            parts.push(_safeToString(e))
        end for
        return "[" + Join(parts, ",") + "]"
    else if t = "String"
        return v
    else if t = "Integer" or t = "Float" or t = "Double" or t = "Boolean"
        return v.ToStr()
    else if v = invalid
        return "invalid"
    else
        return "<" + t + ">"
    end if
end function

' Helper join for string arrays
function Join(arr as object, sep as string) as string
    if arr = invalid then return ""
    s = ""
    for i = 0 to arr.count() - 1
        s = s + arr[i]
        if i < arr.count() - 1 then s = s + sep
    end for
    return s
end function
