' ========================================
' GalleryItem.brs
' Custom item component for RowList
' ========================================

sub init()
    m.poster = m.top.findNode("poster")
end sub

sub onContentChanged(msg as object)
    ' Clear previous image to prevent flickering
    m.poster.uri = ""

    content = m.top.itemContent
    
    ' Set new image
    if content <> invalid and content.HDPosterUrl <> invalid
        m.poster.uri = content.HDPosterUrl
    end if
end sub
