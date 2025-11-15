' ========================================
' Config.brs
' Application Configuration Constants
' ========================================

function GetFlickrConfig() as Object
    return {
        ' Flickr API Configuration
        apiUrl: "https://api.flickr.com/services/rest/"
        imageBaseUrl: "https://live.staticflickr.com/"
        apiKey: "452b3b7a5d806dcd110842e6649c604d"
        
        ' API Methods
        searchMethod: "flickr.photos.search"
        interestingnessMethod: "flickr.interestingness.getList"
        popularMethod: "flickr.photos.getPopular"
        recentMethod: "flickr.photos.getRecent"
        
        ' Default Parameters
        format: "json"
        nojsoncallback: "1"
        perPage: "20"  ' Number of images per row
        
        ' Image size suffix for constructing URLs
        ' s - small square 75x75
        ' q - large square 150x150
        ' t - thumbnail, 100 on longest side
        ' m - small, 240 on longest side
        ' n - small, 320 on longest side
        ' w - medium 400, 400 on longest side
        ' z - medium 640, 640 on longest side
        ' c - medium 800, 800 on longest side
        ' b - large, 1024 on longest side
        ' h - large 1600, 1600 on longest side
        imageSizeSuffix: "z"  ' Medium 640px
        
        ' Extra fields to request from the API
        extras: "description,url_z,url_c,url_l,url_o"
        
        ' Row definitions - defines all rows to display
        rows: [
            ' Special rows using different API methods
            { name: "Featured & Trending", method: "flickr.interestingness.getList", id: "featured", type: "interestingness" }
            { name: "Popular", method: "flickr.photos.search", tags: "popular", sort: "interestingness-desc", id: "popular-photos", type: "search" }
            { name: "Recent Uploads", method: "flickr.photos.getRecent", id: "recent", type: "recent" }
            
            ' Category rows using search with tags
            { name: "Nature", method: "flickr.photos.search", tags: "nature,landscape,scenery", id: "nature", type: "search" }
            { name: "Architecture", method: "flickr.photos.search", tags: "architecture,building,cityscape", id: "architecture", type: "search" }
            { name: "Animals", method: "flickr.photos.search", tags: "animals,wildlife,pets", id: "animals", type: "search" }
            { name: "Sports", method: "flickr.photos.search", tags: "sports,athletics,games", id: "sports", type: "search" }
            { name: "Travel", method: "flickr.photos.search", tags: "travel,vacation,tourism", id: "travel", type: "search" }
            { name: "Food", method: "flickr.photos.search", tags: "food,cuisine,culinary", id: "food", type: "search" }
            { name: "Art", method: "flickr.photos.search", tags: "art,painting,sculpture", id: "art", type: "search" }
            { name: "Technology", method: "flickr.photos.search", tags: "technology,innovation,digital", id: "technology", type: "search" }
            { name: "Fashion", method: "flickr.photos.search", tags: "fashion,style,clothing", id: "fashion", type: "search" }
            { name: "Music", method: "flickr.photos.search", tags: "music,concert,instruments", id: "music", type: "search" }
            { name: "Historical", method: "flickr.photos.search", tags: "historical,vintage,history", id: "historical", type: "search" }
        ]
    }
end function

' Helper function to get all category IDs
function GetCategoryIds() as Object
    config = GetFlickrConfig()
    categoryIds = []
    for each category in config.categories
        categoryIds.push(category.id)
    end for

    return categoryIds
end function

' Helper function to get category by ID
function GetCategoryById(categoryId as String) as Object
    config = GetFlickrConfig()
    for each category in config.categories
        if category.id = categoryId
            return category
        end if
    end for

    return invalid
end function

' Helper function to get all row definitions
function GetAllRows() as Object
    config = GetFlickrConfig()
    return config.rows
end function

' Helper function to get row by ID
function GetRowById(rowId as String) as Object
    config = GetFlickrConfig()
    for each row in config.rows
        if row.id = rowId
            return row
        end if
    end for
    return invalid
end function
