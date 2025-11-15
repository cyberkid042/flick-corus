' ========================================
' MainScene.brs
' Main Scene Controller - Manages navigation and global state
' ========================================

sub init()
  initializeGlobalConfig()
  initializeScreens()
  initializeDataManager()
  setupObservers()
  m.dataManager.loadInitialData()
end sub

sub initializeGlobalConfig()
  m.global.Update({
    "config": GetFlickrConfig(),
  }, true)

  if not m.global.hasField("navigateTo")
    m.global.addField("navigateTo", "string", false)
    m.global.navigateTo = invalid
  end if
end sub

sub initializeScreens()
  m.screens = {}
  screenIds = ["splashScreen", "mainScreen", "detailsScreen"]

  for each screenId in screenIds
    screenNode = m.top.findNode(screenId)
    if screenNode <> invalid
      m.screens[screenId] = screenNode
    end if
  end for
end sub

sub initializeDataManager()
  m.dataManager = createDataManager()
  m.dataManager.initialize(m.global)
end sub

sub setupObservers()
  m.global.observeFieldScoped("splashDone", "onSplashDone")
  m.global.observeFieldScoped("navigateTo", "onNavigateTo")
  m.global.observeFieldScoped("loadMoreRows", "onLoadMoreRows")
  m.dataManager.flickrTask.observeField("response", "onFlickrResponse")
  m.dataManager.flickrTask.observeField("error", "onFlickrError")
  m.dataManager.flickrTask.observeField("status", "onFlickrStatusChange")
end sub

sub onFlickrStatusChange(msg as object)
  status = msg.GetData()
  m.dataManager.onFlickrStatusChange(status)
end sub

sub onFlickrResponse(msg as object)
  response = msg.GetData()
  m.dataManager.onFlickrResponse(response)
end sub

sub onFlickrError(msg as object)
  errorInfo = msg.GetData()
  m.dataManager.onFlickrError(errorInfo)
end sub

sub onNavigateTo(msg as object)
  screen = msg.GetData()
  if screen = invalid then return

  hideAllScreens()
  showScreen(screen)
end sub

sub hideAllScreens()
  for each screenId in m.screens
    screenNode = m.screens[screenId]
    if screenNode <> invalid
      screenNode.visible = false
    end if
  end for
end sub

sub showScreen(screenName as String)
  if not m.screens.doesExist(screenName) then return
  
  targetScreen = m.screens[screenName]
  if targetScreen <> invalid
    targetScreen.visible = true
    targetScreen.setFocus(true)
    ? "[Navigation] Current Screen: " + screenName
  end if
end sub

sub onSplashDone(msg as object)
  if msg.GetData() = true then m.global.navigateTo = "mainScreen"
end sub

sub onLoadMoreRows(msg as object)
  if msg.GetData() = true
    m.dataManager.loadMorePhotos()
    m.global.loadMoreRows = false
  end if
end sub
