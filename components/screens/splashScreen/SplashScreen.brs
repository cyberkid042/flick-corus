' ========================================
' SplashScreen.brs
' Splash screen with loading animation
' ========================================

sub init()
    initializeState()
    setupUI()
    setupObservers()
end sub

sub initializeState()
    m.minDisplayDuration = 3
    m.minTimeElapsed = false
    m.dataReady = false
end sub

sub setupUI()
    m.loadingAnimation = m.top.findNode("loadingAnimation")
    m.minimumDisplayTimer = m.top.findNode("minimumDisplayTimer")
    
    if m.loadingAnimation <> invalid
        m.loadingAnimation.control = "start"
    end if
end sub

sub setupObservers()
    m.minimumDisplayTimer.observeFieldScoped("fire", "onMinimumTimerFired")
    m.minimumDisplayTimer.control = "start"
    m.global.observeField("firstRowLoaded", "onDataReady")
end sub

sub onMinimumTimerFired()
    m.minTimeElapsed = true
    checkIfReadyToHide()
end sub

sub onDataReady()
    m.dataReady = true
    checkIfReadyToHide()
end sub

sub checkIfReadyToHide()
    if m.minTimeElapsed and m.dataReady
        hide()
    end if
end sub

sub hide()
    if not m.minTimeElapsed then return
    
    if m.loadingAnimation <> invalid
        m.loadingAnimation.control = "stop"
    end if
    
    m.top.visible = false
    m.global.splashDone = true
end sub
