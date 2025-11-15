' ========================================
' DetailsScreen.brs
' Screen to display photo details
' ========================================

sub init()
    initializeUI()
    setupFocusTimer()
    m.global.observeField("selectedPhotoData", "onPhotoDataChanged")
end sub

sub initializeUI()
    m.poster = m.top.findNode("photoPoster")
    m.titleLabel = m.top.findNode("titleLabel")
    m.dimensionsLabel = m.top.findNode("dimensionsLabel")
    m.descriptionText = m.top.findNode("descriptionText")
    m.loadingLabel = m.top.findNode("loadingLabel")
    
    if m.poster <> invalid
        m.poster.observeField("loadStatus", "onPosterLoadStatus")
    end if
end sub

sub setupFocusTimer()
    m.focusTimer = createObject("roSGNode", "Timer")
    m.focusTimer.duration = 0.1
    m.focusTimer.repeat = false
    m.focusTimer.observeField("fire", "onFocusTimerFired")
end sub

sub onPhotoDataChanged(msg as object)
    photoData = msg.GetData()
    if photoData <> invalid
        populate(photoData)
    end if
end sub

sub populate(data as object)
    showLoading(true)
    
    m.poster.uri = data.imageUrl
    m.titleLabel.text = data.title
    m.dimensionsLabel.text = formatDimensions(data)
    
    if m.descriptionText <> invalid
        m.descriptionText.text = ""
        m.descriptionText.text = getDescription(data)
        
        if Len(data.description) > 0
            m.focusTimer.control = "start"
        end if
    end if
end sub

sub onPosterLoadStatus(msg as object)
    status = msg.GetData()
    if status = "ready" or status = "failed"
        showLoading(false)
    end if
end sub

sub showLoading(show as Boolean)
    if m.loadingLabel <> invalid and m.poster <> invalid
        m.loadingLabel.visible = show
        m.poster.visible = not show
    end if
end sub

function formatDimensions(data as Object) as String
    if data.imageWidth = invalid or data.imageHeight = invalid
        return "Dimensions: N/A"
    end if
    return "Dimensions: " + data.imageWidth.ToStr() + "x" + data.imageHeight.ToStr()
end function

function getDescription(data as Object) as String
    if Len(data.description) > 0
        return data.description
    end if
    return "No description available."
end function

sub onFocusTimerFired()
    if m.descriptionText <> invalid
        m.descriptionText.setFocus(true)
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press and key = "back"
        m.global.navigateTo = "mainScreen"
        return true
    end if
    return false
end function
