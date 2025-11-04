' PUBLIC_INTERFACE
' Validators.brs - Common validation helpers

' PUBLIC_INTERFACE
' Returns true if s is a non-empty string.
function IsNonEmptyString(s as dynamic) as boolean
    return type(s) = "String" and len(s) > 0
end function

' PUBLIC_INTERFACE
' Returns true if candidate looks like a URL (simple heuristic).
function LooksLikeUrl(candidate as dynamic) as boolean
    if type(candidate) <> "String" then return false
    low = LCase(candidate)
    return (left(low, 7) = "http://" or left(low, 8) = "https://")
end function

' PUBLIC_INTERFACE
' Ensure assocarray has one of the keys.
function HasAnyKeys(obj as dynamic, keys as object) as boolean
    if type(obj) <> "roAssociativeArray" then return false
    for each k in keys
        if obj[k] <> invalid then return true
    end for
    return false
end function

' PUBLIC_INTERFACE
' Non-null check
function NotInvalid(v as dynamic) as boolean
    return v <> invalid
end function
