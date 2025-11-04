' PUBLIC_INTERFACE
' FeedService.brs
' Provides async feed loading via Task-compatible entrypoint and sync helpers.

' Dependencies:
' - source/models/ContentModel.brs
' - source/utils/Validators.brs
' - source/config/config.brs

' PUBLIC_INTERFACE
' Task entry: expects m.top fields - input (assocarray) with { url }, output (ContentNode), error (string)
sub init()
    ' When run as a Task's script, Task automatically calls init and then runs on port wait loop via observe.
    ' We'll observe "input" field changes to trigger load.
    m.top.observeField("input", "onInputChanged")
end sub

' PUBLIC_INTERFACE
' Triggered when input changes; loads feed and sets output or error with retry/backoff.
sub onInputChanged()
    cfg = AppConfig()
    input = m.top.input
    url = invalid
    if input <> invalid and input.url <> invalid then url = input.url
    if url = invalid then url = cfg.feedUrl

    LogInfo("FeedService: load begin", { url: url })

    maxAttempts = 3
    attempt = 0
    result = invalid
    while attempt < maxAttempts
        result = LoadFeed(url, cfg.requestTimeoutMs)
        if result.success
            exit while
        end if
        attempt = attempt + 1
        LogWarn("FeedService: load failed; will retry", { attempt: attempt, error: result.error })
        ' Exponential backoff: 0.5s, 1s, 2s
        backoffMs = 500 * (2 ^ (attempt - 1))
        sleepMs(backoffMs)
    end while

    if result <> invalid and result.success
        LogInfo("FeedService: load success")
        m.top.output = result.contentNode
        m.top.error = ""
    else
        errMsg = "Failed to load feed"
        if result <> invalid and result.error <> invalid then errMsg = result.error
        LogError("FeedService: giving up", { error: errMsg })
        m.top.error = errMsg
        ' Return an empty content root to avoid null deref in UI
        m.top.output = CreateObject("roSGNode", "ContentNode")
    end if
end sub

' PUBLIC_INTERFACE
' Load feed from url (supports pkg:/ and http(s)://). Returns assocarray:
' { success: boolean, contentNode: ContentNode, error: string }
function LoadFeed(url as string, timeoutMs as integer) as object
    if left(LCase(url), 6) = "pkg:/"
        parsed = readJsonFromPkg(url)
        if parsed.success
            root = ParseFeedToContent(parsed.json)
            return { success: true, contentNode: root, error: "" }
        else
            return { success: false, contentNode: CreateObject("roSGNode", "ContentNode"), error: parsed.error }
        end if
    else
        fetched = fetchJson(url, timeoutMs)
        if fetched.success
            root = ParseFeedToContent(fetched.json)
            return { success: true, contentNode: root, error: "" }
        else
            return { success: false, contentNode: CreateObject("roSGNode", "ContentNode"), error: fetched.error }
        end if
    end if
end function

' Read a JSON file from the package and parse
function readJsonFromPkg(pkgUrl as string) as object
    aa = { success: false, json: invalid, error: "" }
    file = CreateObject("roByteArray")
    if not file.ReadFile(pkgUrl)
        aa.error = "Failed to read file: " + pkgUrl
        return aa
    end if
    text = file.ToAsciiString()
    parser = CreateObject("roJSONParser")
    json = parser.Parse(text)
    if json = invalid
        aa.error = "Invalid JSON in: " + pkgUrl
        return aa
    end if
    aa.success = true
    aa.json = json
    return aa
end function

' Fetch JSON from network via roUrlTransfer
function fetchJson(url as string, timeoutMs as integer) as object
    aa = { success: false, json: invalid, error: "" }

    ut = CreateObject("roUrlTransfer")
    ut.SetUrl(url)
    ut.SetCertificatesFile("common:/certs/ca-bundle.crt")
    ut.AddHeader("Accept", "application/json")
    ut.SetRequest("GET")
    if timeoutMs > 0 then ut.SetTimeout(timeoutMs)

    rsp = ut.GetToString()
    if rsp = invalid
        aa.error = "Network error or empty response"
        return aa
    end if

    parser = CreateObject("roJSONParser")
    json = parser.Parse(rsp)
    if json = invalid
        aa.error = "Invalid JSON from network"
        return aa
    end if

    aa.success = true
    aa.json = json
    return aa
end function

' Sleep helper using blocking approximation (kept short)
sub sleepMs(ms as integer)
    start = CreateObject("roDateTime").AsSeconds() * 1000
    while (CreateObject("roDateTime").AsSeconds() * 1000) - start < ms : end while
end sub
