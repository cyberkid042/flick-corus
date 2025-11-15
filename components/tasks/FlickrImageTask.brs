' ========================================
' FlickrImageTask.brs
' Task for fetching images from Flickr API
' ========================================

sub init()
    m.top.functionName = "fetchFlickrImages"
end sub

sub fetchFlickrImages()
    ' Get configuration
    config = GetFlickrConfig()

    ' Validate row ID
    rowId = m.top.rowId
    if rowId = invalid or rowId = ""
        setError("INVALID_INPUT", "Row ID is required")
        return
    end if

    ' Get row details
    row = GetRowById(rowId)
    if row = invalid
        setError("INVALID_ROW", "Row not found: " + rowId)
        return
    end if

    m.top.status = "loading"

    ' Build API URL based on row type
    url = buildFlickrUrl(config, row)

    response = makeHttpRequest(url)

    if response.success
        parsedData = parseFlickrResponse(response.data, row)
        if parsedData <> invalid
            m.top.response = parsedData
            m.top.status = "success"
        else
            setError("PARSE_ERROR", "Failed to parse Flickr API response")
        end if
    else
        setError("NETWORK_ERROR", response.errorMessage)
    end if
end sub

function buildFlickrUrl(config as Object, row as Object) as String
    baseUrl = config.apiUrl
    
    ' Get pagination parameters
    page = m.top.page
    if page = invalid or page < 1 then page = 1
    
    perPage = m.top.perPage
    if perPage = invalid or perPage < 1 then perPage = 20

    ' Base parameters common to all methods
    params = {
        method: row.method
        api_key: config.apiKey
        format: config.format
        nojsoncallback: config.nojsoncallback
        per_page: perPage.ToStr()
        page: page.ToStr()
        safe_search: "1"
        content_type: "1"
        extras: config.extras
    }

    if row.type = "search"
        params.tags = row.tags
        if row.sort <> invalid and row.sort <> ""
            params.sort = row.sort
        else
            params.sort = "relevance"
        end if
    else if row.type = "interestingness"
        ' Interestingness - no extra params needed
    else if row.type = "recent"
        ' Recent photos - no extra params needed
    else if row.type = "popular"
        params.sort = "interestingness-desc"
    end if

    ' Construct URL with parameters
    url = baseUrl + "?"
    firstParam = true
    for each key in params
        if not firstParam
            url = url + "&"
        end if
        url = url + key + "=" + params[key]
        firstParam = false
    end for

    return url
end function

function makeHttpRequest(url as String) as Object
    urlTransfer = CreateObject("roUrlTransfer")
    urlTransfer.SetUrl(url)
    urlTransfer.RetainBodyOnError(true)
    urlTransfer.EnableEncodings(true)

    urlTransfer.SetMessagePort(CreateObject("roMessagePort"))

    ' Set headers
    urlTransfer.AddHeader("Content-Type", "application/json")
    urlTransfer.AddHeader("User-Agent", "RokuFlickrApp/1.0")

    result = {
        success: false
        data: invalid
        errorMessage: ""
    }

    responseCode = urlTransfer.GetToString()

    if responseCode <> invalid and responseCode <> ""
        result.success = true
        result.data = responseCode
    else
        ' Handle errors
        failureReason = urlTransfer.GetFailureReason()
        responseCode = urlTransfer.GetResponseCode()

        if responseCode = -1
            result.errorMessage = "Connection timeout or DNS lookup failure"
        else if responseCode = -2
            result.errorMessage = "Network connection lost"
        else if responseCode >= 400 and responseCode < 500
            result.errorMessage = "Client error: HTTP " + responseCode.ToStr()
        else if responseCode >= 500
            result.errorMessage = "Server error: HTTP " + responseCode.ToStr()
        else
            result.errorMessage = "Request failed: " + failureReason
        end if
    end if

    return result
end function

function parseFlickrResponse(jsonString as String, row as Object) as Object
    if jsonString = invalid or jsonString = ""
        return invalid
    end if

    json = ParseJson(jsonString)
    if json = invalid
        return invalid
    end if

    if json.stat <> "ok"
        return invalid
    end if

    if json.photos = invalid or json.photos.photo = invalid
        return invalid
    end if

    config = GetFlickrConfig()

    photos = []
    suffix = config.imageSizeSuffix
    for each photo in json.photos.photo
        photoData = {
            id: photo.id
            title: photo.title
            description: photo.description._content
            imageUrl: photo["url_" + suffix]
            imageWidth: photo["width_" + suffix]
            imageHeight: photo["height_" + suffix]
            thumbnailUrl: constructImageUrl(photo, "m")
        }
        photos.push(photoData)
    end for

    parsedResponse = {
        rowId: row.id
        rowName: row.name
        rowType: row.type
        totalPhotos: json.photos.total
        page: json.photos.page
        perPage: json.photos.perpage
        photos: photos
        timestamp: CreateObject("roDateTime").AsSeconds()
    }

    return parsedResponse
end function

function constructImageUrl(photo as Object, sizeSuffix as String) as String
    if photo.server = invalid or photo.id = invalid or photo.secret = invalid
        return ""
    end if

    config = GetFlickrConfig()
    baseUrl = config.imageBaseUrl
    url = baseUrl + photo.server + "/" + photo.id + "_" + photo.secret

    if sizeSuffix <> invalid and sizeSuffix <> ""
        url = url + "_" + sizeSuffix
    end if

    url = url + ".jpg"

    return url
end function

sub setError(errorCode as String, errorMessage as String)
    m.top.error = {
        code: errorCode
        message: errorMessage
        timestamp: CreateObject("roDateTime").AsSeconds()
    }
    m.top.status = "error"
end sub
