' PUBLIC_INTERFACE
' main.brs - Entry point for BrightStream Retro Roku application.
' Initializes SceneGraph and launches the root scene.

sub main()
    ' Create the main message port and roSGScreen
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)

    ' Set the root scene to our App Scene component
    scene = screen.CreateScene("BrightAppScene")
    screen.Show()

    ' Simple event loop; keep alive while screen exists
    while true
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then
                exit while
            end if
        end if
    end while
end sub
