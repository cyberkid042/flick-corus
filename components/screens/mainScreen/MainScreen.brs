' ========================================
' MainScreen.brs
' Main gallery screen component
' ========================================

sub init()
    initializeRowList()
    setupObservers()
end sub

sub initializeRowList()
    m.rowList = m.top.findNode("galleryRowList")
    m.rootContent = CreateObject("roSGNode", "ContentNode")
    m.rowsDisplayed = 0
    
    m.loadingLabel = m.top.findNode("loadingLabel")
    
    m.rowList.content = m.rootContent
    m.rowList.visible = true
    m.rowList.setFocus(true)
end sub

sub setupObservers()
    m.top.observeField("visible", "onVisibleChanged")
    m.global.observeField("allRowsData", "onAllRowsDataChanged")
    m.global.observeField("isLoadingData", "onLoadingStateChanged")
    m.rowList.observeFieldScoped("rowItemSelected", "onRowItemSelected")
    m.rowList.observeFieldScoped("rowItemFocused", "onRowItemFocused")
end sub

sub onVisibleChanged(msg as object)
    if msg.GetData() and m.rowList <> invalid
        m.rowList.setFocus(true)
    end if
end sub

sub onAllRowsDataChanged(msg as object)
    allRowsData = msg.GetData()
    
    if allRowsData <> invalid and allRowsData.Count() > m.rowsDisplayed
        appendNewRows(allRowsData)
    end if
end sub

sub onLoadingStateChanged(msg as object)
    isLoading = msg.GetData()
    
    if m.loadingLabel <> invalid
        m.loadingLabel.visible = isLoading
    end if
end sub

sub appendNewRows(allRowsData as object)
    for i = m.rowsDisplayed to allRowsData.Count() - 1
        rowData = allRowsData[i]
        if rowData <> invalid and rowData.photos <> invalid and rowData.photos.Count() > 0
            createRow(rowData)
            m.rowsDisplayed = m.rowsDisplayed + 1
        end if
    end for
end sub

sub onRowItemSelected(msg as object)
    row = msg.GetData()[0]
    itemIndex = msg.GetData()[1]
    selectedItem = m.rowList.content.GetChild(row).GetChild(itemIndex)
    
    photoData = findPhotoData(selectedItem.id)
    
    if photoData <> invalid
        m.global.selectedPhotoData = photoData
        m.global.navigateTo = "detailsScreen"
    end if
end sub

sub onRowItemFocused(msg as object)
    focusedRow = msg.GetData()[0]
    totalRows = m.rowsDisplayed
    
    ' When user is within 2 rows of the end, load more
    if focusedRow >= totalRows - 2 and not m.global.isLoadingData
        m.global.loadMoreRows = true
    end if
end sub

function findPhotoData(photoId as String) as Object
    allRows = m.global.allRowsData
    if allRows = invalid then return invalid

    for each rowData in allRows
        for each photo in rowData.photos
            if photo.id = photoId
                return photo
            end if
        end for
    end for

    return invalid
end function

sub createRow(rowData as object)
    rowNode = m.rootContent.CreateChild("ContentNode")
    rowNode.title = rowData.rowName
    
    for each photo in rowData.photos
        img = getPhotoUrl(photo)
        if img <> ""
            itemNode = rowNode.CreateChild("ContentNode")
            itemNode.HDPosterUrl = img
            itemNode.SDPosterUrl = img
            itemNode.title = photo.title
            itemNode.id = photo.id
            itemNode.description = photo.description
        end if
    end for
end sub

function getPhotoUrl(photo as Object) as String
    if photo.thumbnailUrl <> invalid and photo.thumbnailUrl <> ""
        return photo.thumbnailUrl
    else if photo.imageUrl <> invalid and photo.imageUrl <> ""
        return photo.imageUrl
    end if
    return ""
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press and key = "back"
        if m.rowList.itemFocused <> 0
            m.rowList.animateToItem = 0
            return true
        else
            m.global.exitChannel = true
            return true
        end if
    end if
    return false
end function
