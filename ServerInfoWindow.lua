
/*
  buttons= connect , refresh, show rules list

    "Name"
    "Map"
    "Address"
    "QueryPort"
    "GameMode"
    "GameTag"
    "PlayerCount"
    "MaxPlayers"
    "Passworded"
    "Ping"

   
    ServerInfo.
    
    QueryGameInfo
    QueryPlayerList
    QueryServerRules

    def("CheckActiveQuerys", &SingleQueryManager::CheckActiveQuerys),
    def("CancelActiveQuerys", &SingleQueryManager::CancelActiveQuerys)
*/
ControlClass('PlayerListEntry', BaseControl)

PlayerListEntry.FontSize = 15
PlayerListEntry.DefaultWidth = 300
PlayerListEntry.PlayerNameOffset = Vector(5, 0, 0)
PlayerListEntry.TimePlayedOffset = Vector(120, 0, 0)
PlayerListEntry.ScoreOffset = Vector(190, 0, 0)

ControlClass('ServerInfoWindow', BaseWindow)

ServerInfoWindow.InfoSpacing = 22

local infoFont = FontTemplate(17)

local InfoList = {
  "ServerName",
  "Address",
  "Map",
  "Ping",
  "GameMode",
  "Players",
}


ServerInfoWindow.ListSetup = {
  Width = 240,
  Height = 200,
  ItemClass = "PlayerListEntry",
  ItemHeight = PlayerListEntry.FontSize,
}

function ServerInfoWindow:Initialize(server, queryPort)
  BaseWindow.Initialize(self, 280, 410, "Server Info")

  self.DestroyOnClose = true

  self.LastRefresh = 0

  local xOffset = 13
  local yOffset = 21

  for i=1,#InfoList do
    local text = self:CreateFontString(infoFont, nil, xOffset, yOffset+((i-1)*self.InfoSpacing))
   
    text:SetText(InfoList[i]..":")
    
    self[InfoList[i]] = text
  end

  if(type(server) == "string") then
    self.ServerAddress = server
    
    self.QueryPort = queryPort or 27015
  else
    assert(type(server) == "table")

    self.OldServerInfo = server

    self.ServerInfo = server
    self.ServerAddress = server.Address
 
    self.QueryPort = server.QueryPort
  end

  self.Address:SetText("IP Address: "..self.ServerAddress)


  local playerList = self:CreateControl("ListView", self.ListSetup)
    playerList:SetPoint("Bottom", 0, -15, "Bottom")
    playerList:SetColor(Color(0,0,0,1))
    
  self:AddChild(playerList)
  self.PlayerListView = playerList

  self.PlayerCount = self:AddGUIItemChild(GUIManager:CreateTextItem())
  
  local refreshButton = self:CreateControl("UIButton", "Refresh", 75, 24)
    refreshButton:SetPosition(8, 160)
    refreshButton.ClickAction = function() 
      if(not self.RefreshActive) then
        self:Refresh() 
      end
    end
  self:AddChild(refreshButton)
  
  local connectButton = self:CreateControl("UIButton", "Connect", 80, 24)
    connectButton:SetPosition(100, 160)
    connectButton.ClickAction = function()
      
      if(self.ServerInfo) then
        ConnectedInfo:ConnectToServer(server)
      else
        MainMenu_SBJoinServer(self.ServerAddress)
      end
    end
  self:AddChild(connectButton)

  local retryButton = self:CreateControl("UIButton", "Auto retry", 80, 24)
    retryButton:SetPosition(195, 160)
    retryButton.ClickAction = function()
      
      self.AutoRetryConnect = not self.AutoRetryConnect
      retryButton:SetHighlightLock(self.AutoRetryConnect)
    end
    retryButton:Hide()
  self:AddChild(retryButton)
  self.RetryButton = retryButton

  self.PlayerCallbackFunc = function(playerList)
    self:PlayerCallback(playerList)
  end

  self.ServerName:SetTextClipped(true, self:GetWidth()-xOffset, infoFont.FontSize)

  self.ServerCallbackFunc = function(serverInfo)
    self:ServerCallback(serverInfo)
  end
  
  self:Refresh()
end

function ServerInfoWindow:ServerCallback(serverInfo)

  --we been destroyed so don't update anything
  if(not IsValidControl(self)) then
    return
  end

  if(not serverInfo) then
    self:SetBlank()
   return
  end

  self.OldServerInfo = serverInfo

  self.ServerFull = serverInfo.PlayerCount >= serverInfo.MaxPlayers

  if(self.ServerFull) then
    self.RetryButton:Show()
  else
    if(not self.AutoRetryConnect) then
      self.RetryButton:Hide()
    end
  end

  if(self.AutoRetryConnect and not self.ServerFull) then
    self.AutoRetryConnect = false

    ConnectedInfo:SetServerInfo(self.ServerInfo)
    MainMenu_SBJoinServer(self.ServerAddress)
  end
  
  self.ServerInfo = serverInfo
  
  self.ServerQueryActive = false    
  
  self.ServerName:SetText("Name: "..serverInfo.Name)
  self.Map:SetText("Map: "..GetTrimmedMapName(serverInfo.Map))
  self.Ping:SetText("Ping: "..tostring(serverInfo.Ping))
  self.Players:SetText(string.format("Player: %i / %i", serverInfo.PlayerCount, serverInfo.MaxPlayers))
  
  self.GameMode:SetText("GameMode: "..serverInfo.GameMode)
end

function ServerInfoWindow:PlayerCallback(playerList)
  
  --we been destroyed so don't update anything
  if(not IsValidControl(self)) then
    return
  end
  
  self.RefreshActive = false    
  
  self.PlayerList = playerList
  self.PlayerListView:SetDataList(self.PlayerList or {})
 end

function ServerInfoWindow:SetBlank()
  self.ServerName:SetText("Name:")
  self.Map:SetText("Map:")
  self.Ping:SetText("Ping:")
  self.Players:SetText("Player:")
end

function ServerInfoWindow:Update()
  
  if(Client.GetTime()-self.LastRefresh > 10 and not self.RefreshActive) then
    self:Refresh()
  end
end

function ServerInfoWindow:Refresh()

  self.LastRefresh = Client.GetTime()

  ServerInfo.QueryPlayerList(self.ServerAddress, self.QueryPort, self.PlayerCallbackFunc)
  ServerInfo.QueryGameInfo(self.ServerAddress, self.QueryPort, self.ServerCallbackFunc)

  self.ServerQueryActive = true
  self.RefreshActive = true
end


function PlayerListEntry:Initialize(owner, width, height)

  BaseControl.Initialize(self, width, height)
  
  self:SetColor(0,0,0,0)
  
  local playerName = self:CreateFontString(self.FontSize)
   playerName:SetPosition(self.PlayerNameOffset)
  self.PlayerName = playerName

  local timePlayed = self:CreateFontString(self.FontSize)
   timePlayed:SetPosition(self.TimePlayedOffset)
  self.TimePlayed = timePlayed
  
  local score = self:CreateFontString(self.FontSize)
   score:SetPosition(self.ScoreOffset)
  self.Score = score  
  
  //self:SetWidth(width)
end

function PlayerListEntry.UpdateWidths(width, entrys)
  
  local widthScale = self.DefaultWidth/width
  
  for i,entry in ipairs(entrys) do
    
  end
end

function PlayerListEntry:GetRoot()
  return self.RootFrame
end

function PlayerListEntry:SetData(playerData)
  if(self.Hidden) then
    self:Show()
  end

  self.PlayerName:SetText(playerData[1])
  self.Score:SetText(tostring(playerData[2]))
  
  local time = math.floor(playerData[3])
  
  local seconds = time%60

  if(time > 60) then
    local mins = (time-seconds)/60
    
    if(time > 60*60) then
      local hours = mins
      
      mins = mins%60
      hours = (hours-mins)/60

      time = string.format("%ih %im %is", hours, mins, seconds)
    else
      time = string.format("%im %is", mins, seconds)
    end
  else
    time = string.format("%is", seconds)
  end

  self.TimePlayed:SetText(time)
end