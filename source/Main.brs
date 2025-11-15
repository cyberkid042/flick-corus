sub Main()
    ' Create the screen and scene
    m.screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    m.screen.setMessagePort(port)
    m.scene = m.screen.CreateScene("MainScene")

    ? "[Main] Setting up screen's global node before showing screen"
    m.global = m.screen.getGlobalNode()

    m.global.Update({
        "allRowsData": [],
        "selectedPhotoData": { },
        "firstRowLoaded": false,
        "splashDone": false,
        "exitChannel": false,
        "isLoadingData": false,
        "loadMoreRows": false,
    }, true)

    ' Show the screen
    m.screen.show()

    ' Observe for when we should exit the scene.
    m.global.ObserveFieldScoped("exitChannel", port)
    m.global.ObserveFieldScoped("hasExitedChannel", port)

    while(true)
        msg = wait(0, port)
        msgType = type(msg)

        if msgType = "roSGNodeEvent"
            field = msg.GetField()

            ? "[Main] Received node event for field: " + field
            if field = "exitChannel" and msg.GetData() then
                ' Ask the channel to close by closing the roSGScreen. Once the screen is closed,
                ' Roku will fire off another roSGNodeEvent event with msg.isScreenClosed() that
                ' we can act upon to exit this loop. Note that starting in OS12, Roku will forgo
                ' closing the screen, and instead will suspend the channel. In that scenario we
                ' won't get a msg.isScreenClosed() event to exit the loop, however we'll now
                ' receive a custom event named hasExitedChannel that can be used to exit the
                ' loop.
                '
                m.screen.Close()
            else if field = "hasExitedChannel" and msg.GetData() then
                ' We have been notified the channel has exited, so we can safely exit the loop.
                return
            end if
        else if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then
                return
            end if
        end if
    end while
end sub
