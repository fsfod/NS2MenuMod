
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

class 'ServerInfoWindow'(BaseWindow)

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

function ServerInfoWindow:__init(serverAddress, queryPort)
  BaseWindow.__init(self, 280, 410, "Server Info")

  self.DestroyOnClose = true

  self.LastRefresh = 0

  local xOffset = 13
  local yOffset = 21

  for i=1,#InfoList do
    local text = self:CreateFontString(infoFont, nil, xOffset, yOffset+((i-1)*self.InfoSpacing))
   
    text:SetText(InfoList[i]..":")
    
    self[InfoList[i]] = text
  end

  self.Address:SetText("IP Address: "..serverAddress)
 
  self.ServerAddress = serverAddress
  self.QueryPort = queryPort
 
  local playerList = ListView(240, 200, PlayerListEntry, PlayerListEntry.FontSize)
    playerList:SetPoint("Bottom", 0, -15, "Bottom")
    playerList:SetColor(Color(0,0,0,1))
    
  self:AddChild(playerList)
  self.PlayerListView = playerList

  self.PlayerCount = self:AddGUIItemChild(GUIManager:CreateTextItem())
  
  local refreshButton = UIButton("Refresh", 80, 24)
    refreshButton:SetPosition(15, 160)
    refreshButton.ClickAction = function() 
      if(not self.RefreshActive) then
        self:Refresh() 
      end
    end
  self:AddChild(refreshButton)
  
   local connectButton = UIButton("Connect", 80, 24)
    connectButton:SetPosition(160, 160)
    connectButton.ClickAction = function() 
      MainMenu_SBJoinServer(self.ServerAddress)
    end
  self:AddChild(connectButton)

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
  if(not self.RootFrame) then
    return
  end

  if(not serverInfo) then
    self:SetBlank()
   return
  end
  
  self.ServerQueryActive = false    
  
  self.ServerName:SetText("Name: "..serverInfo.Name)
  self.Map:SetText("Map: "..GetTrimmedMapName(serverInfo.Map))
  self.Ping:SetText("Ping: "..tostring(serverInfo.Ping))
  self.Players:SetText(string.format("Player: %i / %i", serverInfo.PlayerCount, serverInfo.MaxPlayers))
  
  self.GameMode:SetText("GameMode: "..serverInfo.GameMode)
end

function ServerInfoWindow:PlayerCallback(playerList)
  
  --we been destroyed so don't update anything
  if(not self.RootFrame) then
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

class'PlayerListEntry'

PlayerListEntry.FontSize = 14
PlayerListEntry.DefaultWidth = 300
PlayerListEntry.PlayerNameOffset = Vector(5, 0, 0)
PlayerListEntry.TimePlayedOffset = Vector(120, 0, 0)
PlayerListEntry.ScoreOffset = Vector(190, 0, 0)



function PlayerListEntry:__init(owner, width, height)
    
  local playerName = GUIManager:CreateTextItem()
   playerName:SetFontSize(self.FontSize)
   playerName:SetPosition(self.PlayerNameOffset)
  self.PlayerName = playerName

  local timePlayed = GUIManager:CreateTextItem()
   timePlayed:SetPosition(self.TimePlayedOffset)
   timePlayed:SetFontSize(self.FontSize)
  self.TimePlayed = timePlayed
  
  local score = GUIManager:CreateTextItem()
   score:SetFontSize(self.FontSize)
   score:SetPosition(self.ScoreOffset)
  self.Score = score  
  
  local Background = GUIManager:CreateGraphicItem()
    Background:SetSize(Vector(width, self.FontSize, 0))
    Background:SetColor(Color(0,0,0,0))
    Background:AddChild(playerName)
    Background:AddChild(timePlayed)
    Background:AddChild(score)
  self.Background = Background
  
  self.PositionVector = Vector(0,0,0)
  
  //self:SetWidth(width)
end

function PlayerListEntry.UpdateWidths(width, entrys)
  
  local widthScale = self.DefaultWidth/width
  
  for i,entry in ipairs(entrys) do
    
  end
end

function PlayerListEntry:OnHide()
  if(not self.Hidden) then
   self.Background:SetIsVisible(false)
  end
end

function PlayerListEntry:OnShow()
  if(not self.Hidden) then
    self.Background:SetIsVisible(true)
  end
end

function PlayerListEntry:SetPosition(x,y)
  local vec = self.PositionVector
   vec.x = x
   vec.y = y
  
  self.Background:SetPosition(vec)
end

function PlayerListEntry:GetRoot()
  return self.Background
end

function PlayerListEntry:SetData(playerData)
  if(self.Hidden) then
    self.Background:SetIsVisible(true)
    self.Hidden = nil
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