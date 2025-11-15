' ========================================
' DataManager.brs
' Service for managing photo data and API requests
' ========================================

function createDataManager() as Object
    return {
        rows: GetAllRows()
        currentRowIndex: 0
        rowsData: []
        flickrTask: invalid
        global: invalid
        batchSize: 3 ' Load 3 rows at a time
        isLoadingBatch: false
        
        initialize: function(globalNode as Object)
            m.global = globalNode
            m.flickrTask = createObject("roSGNode", "FlickrImageTask")
            m.setupTaskObservers()
        end function
        
        setupTaskObservers: function()
            m.flickrTask.observeField("response", "onFlickrResponse")
            m.flickrTask.observeField("error", "onFlickrError")
            m.flickrTask.observeField("status", "onFlickrStatusChange")
        end function
        
        loadInitialData: function()
            m.loadNextBatch()
        end function
        
        hasMoreRows: function() as Boolean
            return m.currentRowIndex < m.rows.Count()
        end function
        
        loadNextBatch: sub()
            if m.isLoadingBatch or not m.hasMoreRows()
                return
            end if
            
            m.isLoadingBatch = true
            m.global.isLoadingData = true
            m.fetchNextRow()
        end sub
        
        fetchNextRow: function()
            if m.currentRowIndex < m.rows.Count()
                row = m.rows[m.currentRowIndex]
                
                ' Create new task for each request
                m.flickrTask = createObject("roSGNode", "FlickrImageTask")
                m.setupTaskObservers()
                
                m.flickrTask.rowId = row.id
                m.flickrTask.control = "RUN"
            else
                ' No more rows to fetch
                m.isLoadingBatch = false
                m.global.isLoadingData = false
            end if
        end function
        
        onFlickrResponse: function(response as Object)
            if response <> invalid
                m.rowsData.Push(response)
                m.global.allRowsData = m.rowsData
                
                if m.currentRowIndex = 0
                    m.global.firstRowLoaded = true
                end if
            end if
            
            m.global.isLoadingData = false
        end function
        
        onFlickrStatusChange: function(status as String)
            if status = "success"
                m.currentRowIndex = m.currentRowIndex + 1
                
                ' Check if we should load more rows in this batch
                rowsLoadedInBatch = m.currentRowIndex mod m.batchSize
                shouldContinueBatch = (rowsLoadedInBatch <> 0) and m.hasMoreRows()
                
                if shouldContinueBatch
                    ' Continue loading rows in current batch
                    m.fetchNextRow()
                else
                    ' Batch complete
                    m.isLoadingBatch = false
                    m.global.isLoadingData = false
                end if
            end if
        end function
        
        onFlickrError: function(errorInfo as Object)
            ' Handle errors - could implement retry logic, analytics, etc.
            ' For now, silently fail and continue with next row
            '
            m.currentRowIndex = m.currentRowIndex + 1
            
            ' Check if we should continue the batch
            rowsLoadedInBatch = m.currentRowIndex mod m.batchSize
            shouldContinueBatch = (rowsLoadedInBatch <> 0) and m.hasMoreRows()
            
            if shouldContinueBatch and errorInfo <> invalid
                m.fetchNextRow()
            else
                ' Batch complete or no more rows
                m.isLoadingBatch = false
                m.global.isLoadingData = false
            end if
        end function
        
        ' Load more rows when user is near the end
        loadMorePhotos: sub()
            m.loadNextBatch()
        end sub
        
        ' Add caching support: This will be something that will be considered for prod app
        getCachedData: function(rowId as String) as Object
            ' Implementation for caching data to reduce API calls
            return invalid
        end function
        
        clearCache: function()
            ' Implementation to clear cached data - Also something to consider for prod app
            ' like the function above
            '
        end function
    }
end function
