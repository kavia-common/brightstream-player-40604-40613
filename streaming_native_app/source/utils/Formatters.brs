' PUBLIC_INTERFACE
' Formatters.brs - Small formatting helpers

' PUBLIC_INTERFACE
' Safely join path segments using a forward slash.
function JoinPath(a as string, b as string) as string
    if right(a, 1) = "/" then
        if left(b, 1) = "/" then return a + mid(b, 2)
        return a + b
    else
        if left(b, 1) = "/" then return a + b
        return a + "/" + b
    end if
end function

' PUBLIC_INTERFACE
' Humanize seconds to mm:ss
function HumanizeDuration(seconds as dynamic) as string
    if type(seconds) <> "Integer" and type(seconds) <> "Float" then return ""
    s = int(seconds)
    m = s \ 60
    r = s mod 60
    return m.ToStr() + ":" + Right("0" + r.ToStr(), 2)
end function
