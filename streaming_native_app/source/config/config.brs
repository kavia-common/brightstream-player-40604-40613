' PUBLIC_INTERFACE
' config.brs - Centralized configuration for the app

' PUBLIC_INTERFACE
' Returns configuration assocarray.
function AppConfig() as object
    ' Feed source: default to packaged mock; can be switched to remote URL later.
    return {
        feedUrl: "pkg:/test/feeds/sample-feed.json"
        requestTimeoutMs: 8000
        retryCount: 0
        useTaskForFetch: true
    }
end function
