local PingLimits = {
  0,
  50,
  100, 
  150,
  250,
}


local ServerField ={
  Name = 1,
  GameMode = 2,
  Map = 3,
  PlayerCount = 4,
  MaxPlayers = 5,
  Ping = 6,
  Passworded = 7,
  Index = 8,
  PlayerCountString = 9,
}

local function GetServerRecord(serverIndex)
    
    local playerCount = Client.GetServerNumPlayers(serverIndex)
    local maxPlayers = Client.GetServerMaxPlayers(serverIndex)
    
    return
        { 
            Name = Client.GetServerName(serverIndex),
            GameMode = Client.GetServerGameMode(serverIndex),
            Map = GetTrimmedMapName(Client.GetServerMapName(serverIndex)),
            PlayerCount = playerCount,
            MaxPlayers = maxPlayers,
            Ping = Client.GetServerPing(serverIndex),
            Passworded = Client.GetServerRequiresPassword(serverIndex),
            Address = Client.GetServerAddress(serverIndex),
            Index = serverIndex,
            playerCount.." / "..maxPlayers,
        }
end


class'ServerListEntry'

ServerListEntry.FontSize = 14
ServerListEntry.PingColour100 = Color(0, 1, 0, 1)
ServerListEntry.PingColour250 = Color(0.8588, 0.8588, 0, 1)
ServerListEntry.PingColour600 = Color(1, 0.4901, 0, 1)
ServerListEntry.PingColourWorst = Color(1, 0, 0, 1)

function ServerListEntry:__init()
  
  local passwordIcon = GUIManager:CreateGraphicItem()
    passwordIcon:SetSize(Vector(10,12, 0))
    passwordIcon:SetTexture("ui/passworded.dds")
  self.Passworded = passwordIcon
  
  local serverName = GUIManager:CreateTextItem()
   serverName:SetFontSize(self.FontSize)
   serverName:SetPosition(Vector(18, 0, 0))
   serverName:SetAnchor(GUIItem.Left, GUIItem.Center)
   serverName:SetTextAlignmentX(GUIItem.Align_Min)
   serverName:SetTextAlignmentY(GUIItem.Align_Min)
  self.ServerName = serverName
  
  
  local gameMode = GUIManager:CreateTextItem()
   gameMode:SetFontSize(self.FontSize)
   gameMode:SetAnchor(GUIItem.Left, GUIItem.Center)
   gameMode:SetTextAlignmentX(GUIItem.Align_Min)
   gameMode:SetTextAlignmentY(GUIItem.Align_Min)
  self.GameMode = gameMode
  
  local map = GUIManager:CreateTextItem()
   map:SetFontSize(self.FontSize)
   map:SetAnchor(GUIItem.Left, GUIItem.Center)
   map:SetTextAlignmentX(GUIItem.Align_Min)
   map:SetTextAlignmentY(GUIItem.Align_Min)
  self.MapName = map
  
  local playerCount = GUIManager:CreateTextItem()
   playerCount:SetFontSize(self.FontSize)
   playerCount:SetAnchor(GUIItem.Left, GUIItem.Center)
   playerCount:SetTextAlignmentX(GUIItem.Align_Min)
   playerCount:SetTextAlignmentY(GUIItem.Align_Min)
  self.PlayerCount = playerCount
  
  local ping = GUIManager:CreateTextItem()
   ping:SetFontSize(self.FontSize)
   ping:SetAnchor(GUIItem.Left, GUIItem.Center)
   ping:SetTextAlignmentX(GUIItem.Align_Min)
   ping:SetTextAlignmentY(GUIItem.Align_Min)
  self.Ping = ping
  
  local Background = GUIManager:CreateGraphicItem()
    Background:SetColor(Color(0,0,0,0))
    Background:AddChild(passwordIcon)
    Background:AddChild(serverName)
    Background:AddChild(gameMode)
    Background:AddChild(map)
    Background:AddChild(playerCount)
    Background:AddChild(ping)
  self.Background = Background
  
  self.PositionVector = Vector(0,0,0)
  
  self:SetWidth(300)
end

function ServerListEntry:OnHide()
  if(not self.Hidden) then
   self.Background:SetIsVisible(false)
  end
end

function ServerListEntry:OnShow()
  if(not self.Hidden) then
    self.Background:SetIsVisible(true)
  end
end

function ServerListEntry:SetPos(x,y)
  local vec = self.PositionVector
   vec.x = x
   vec.y = y
  
  self.Background:SetPosition(vec)
end

function ServerListEntry:GetRoot()
  return self.Background
end

local headerFont = FontTemplate(19)
headerFont:SetBold()
headerFont:SetTextAlignment(GUIItem.Align_Center, GUIItem.Align_Center)

local NameOffset = 0
local GameModeOffset = 0.4
local MapOffset = 0.15
local PlayerOffset = 0.2
local PingOffset = 0.15

function ServerListEntry:SetWidth(width)
  
  local posVec = Vector(18, 0, 0)
  
  
  posVec.x = posVec.x+(width*GameModeOffset)
  self.GameMode:SetPosition(posVec)
  
  posVec.x = posVec.x+(width*MapOffset)
  self.MapName:SetPosition(posVec)
  
  posVec.x = posVec.x+(width*PlayerOffset)
  self.PlayerCount:SetPosition(posVec)
  
  posVec.x = posVec.x+(width*PingOffset)
  self.Ping:SetPosition(posVec)
end

function ServerListEntry:SetData(serverData)
  if(self.Hidden) then
    self.Background:SetIsVisible(true)
    self.Hidden = nil
  end

  self.Data = serverData

  self.Passworded:SetIsVisible(serverData.Passworded)

  self.ServerName:SetText(serverData.Name)
  self.GameMode:SetText(serverData.GameMode)
  self.MapName:SetText(serverData.Map)
  self.PlayerCount:SetText(serverData[1])
  self.Ping:SetText(tostring(serverData.Ping))
  
  local ping = serverData.Ping
  
  if(ping < 100) then
    self.Ping:SetColor(self.PingColour100)
  elseif(ping > 600) then
    self.Ping:SetColor(self.PingColourWorst)
  elseif(ping > 250) then
    self.Ping:SetColor(self.PingColour600)
  elseif(ping > 100) then
    self.Ping:SetColor(self.PingColour250)
  end
end

class'ServerBrowserPage'(BaseControl)

function ServerBrowserPage:__init()

  BaseControl.Initialize(self, 740, 500)

  self.RootFrame:SetColor(Color(0.1, 0.1, 0.1,0.3))

  self.ServerCountDisplay = self:CreateFontString(17, nil, 30, 12)
  

  local ServerList = ListView(700, 350, ServerListEntry)
   ServerList.RootFrame:SetColor(Color(0, 0, 0, 1))
   self:AddChild(ServerList)
   ServerList:SetPosition(20, 60)
   ServerList.ItemDblClicked = function(data, index) self:Connect(data.Index) end
  self.ServerList = ServerList
    
  local HeaderLabels = {"Name", "Game", "Map", "Players", "Ping"}
  local Offsets = {NameOffset, GameModeOffset, MapOffset, PlayerOffset, PingOffset}
  local FieldNames = {Game = "GameMode", Players = "PlayerCount"}
  
  local x = 18+20 
  local width = ServerList.ItemWidth
  
  for i,name in ipairs(HeaderLabels) do
    local FieldName = FieldNames[name] or name
    
    local Label = SBListHeader(name, FieldName)
    self:AddChild(Label)
    
    x = x+(Offsets[i]*width)
    
    Label:SetPosition(x, 35)
  end
  
  
  local refresh = MainMenuPageButton("Refresh")
    refresh:SetPoint("BottomLeft", 150, -15, "BottomLeft")
    refresh.ClickAction = {self.RefreshList, self}
  self:AddChild(refresh)  
  
  local backButton = MainMenuPageButton("Back to menu")
    backButton:SetPoint("BottomLeft", 20, -15, "BottomLeft")
    backButton.ClickAction = function() self.Parent:ReturnToMainPage() end
  self:AddChild(backButton)
  
  local connectButton = MainMenuPageButton("Connect")
    connectButton:SetPoint("BottomLeft", 300, -15, "BottomLeft")
    connectButton.ClickAction = function()
      local index = ServerList:GetSelectedIndex()
      if(index) then
        self:Connect(self.FilteredList[index].Index)
      end
    end
  self:AddChild(connectButton)

  local pingfilter = ComboBox(70, 20, PingLimits, function(ping) 
      if(ping == 0) then
        return "All"
      else
        return string.format("< %i", ping)
      end
    end)
    pingfilter:SetPoint("BottomLeft", 500, -55, "BottomLeft")
    pingfilter:SetLabel("Ping")
    pingfilter.ItemPicked = {self.SetPingFilter, self}
  self:AddChild(pingfilter)

  local hasPlayers = CheckBox("Has Players", false)
		hasPlayers:SetPoint("BottomLeft", 580, -55, "BottomLeft")
		hasPlayers.CheckChanged = {self.SetEmptyServersFilter, self}
  self:AddChild(hasPlayers)
  
  local notFull = CheckBox("Not Full", false)
		notFull:SetPoint("BottomLeft", 580, -20, "BottomLeft")
		notFull.CheckChanged = {self.SetNotFullFilter, self}
  self:AddChild(notFull)

  self.CurrentCount = 0
  self.Servers = {}
  self.Filters = {}
  
  self.FilteredList = self.Servers 
  
  ServerList:SetDataList(self.Servers)
  
  
end

function ServerBrowserPage:SetNotFullFilter(filter)
  
  if(filter) then
    self.FullFiltered = function(server) 
      return server.PlayerCount >= server.MaxPlayers 
    end
    
    self:AddFilter(self.FullFiltered)
  else
    self:RemoveFilter(self.FullFiltered)
    self.FullFiltered = nil
  end
end

function ServerBrowserPage:SetEmptyServersFilter(filter)
  
  if(filter) then
    self.EmptyFiltered = function(server) 
      return server.PlayerCount == 0 
    end
    
    self:AddFilter(self.EmptyFiltered)
  else
    self:RemoveFilter(self.EmptyFiltered)
    self.EmptyFiltered = nil
  end
end

function ServerBrowserPage:Connect(index) 
	--the games server indexs are 0 based
	index = index+1
	
  MainMenu_SBJoinServer(self.Servers[index].Address)
end

function ServerBrowserPage:RemoveFilter(filter)
  local removed = self:ReplaceFilter(filter, nil)
  
  if(removed) then
    self:FiltersChanged()
  end
  
  return removed
end

function ServerBrowserPage:ReplaceFilter(old, new)

  for i,filter in ipairs(self.Filters) do
    if(filter == old) then
      if(new) then
        self.Filters[i] = new
      else
        table.remove(self.Filters, i)
      end

     return true
    end
  end
end

function ServerBrowserPage:SetPingFilter(maxping)  
  
  local filterChanged = false
  
  if(self.PingFilter) then
    self:RemoveFilter(self.PingFilter)
    self.PingFilter = nil
    self.MaxPing = nil
  end
  
  if(maxping ~= 0) then
    self.MaxPing = maxping
    self.PingFilter = function(server) return server.Ping > maxping end
    self:AddFilter(self.PingFilter)
  end
  
  self:FiltersChanged()
end

function ServerBrowserPage:GetSelectedServer()
  local selected = self.ServerList:GetSelectedIndex()
  
  if(selected) then
    return self.FilteredList[selected]
  end
  
  return nil
end

function ServerBrowserPage:FiltersChanged()
  
  local selected = self:GetSelectedServer()
   
  local filtered = {}
  self.FilteredList = filtered


  if(#self.Filters == 0) then
    for i=1,#self.Servers do
      filtered[i] = self.Servers[i]
    end
  else
    self:FilterServers(1)
  end
  
	self:SortList(true)

	--delay setting the new list 
	self.ServerList:SetDataList(self.FilteredList)
	
	if(selected) then
	  self:TrySelectServer(selected)
	end
	
	self:UpdateServerCount()
end

function ServerBrowserPage:AddFilter(filter)
  self.Filters[#self.Filters+1] = filter
  
  self:FiltersChanged()
end

function ServerBrowserPage:FilterServers(start)

  if(#self.Servers == 0 or #self.Filters == 0) then
    return
  end

  local result = self.FilteredList

  for i=start, #self.Servers,1 do
    local server = self.Servers[i]
    local filtered = false

    for _,filter in ipairs(self.Filters) do
      if(filter(server)) then
        filtered = true
        break
      end
    end
    
    if(not filtered) then
      result[#result+1] = server
    end
  end
end


function ServerBrowserPage:RefreshList()
  self.Servers = {}
  self.FilteredList = {}
  self.ServerList:SetDataList(self.FilteredList)

  self.ServerCountDisplay:SetText("")

  self.Refreshing = true
  self.CurrentCount = 0
  Client.RebuildServerList()
end

local function GetSortFunc(SortField, ascending)

  if(SortField == "Map" or SortField == "Name" or SortField == "GameMode") then
    if(ascending) then
      return function(e1, e2) 
        local s1, s2 = string.lower(e1[SortField]), string.lower(e2[SortField]) 
          --use the server index if both values are equal so we get a stable sort
          if(s1 == s2) then
            return e1.Index < e2.Index
          end
        
         return s1 < s2
      end
    else
      return function(e1, e2)    
       local s1, s2 = string.lower(e1[SortField]), string.lower(e2[SortField]) 
        if(s1 == s2) then
          return e1.Index < e2.Index
        end

       return s1 > s2
      end
    end
  elseif(SortField == "PlayerCount" or SortField == "Ping") then
    if(ascending) then
      return function(e1, e2) 
        local n1, n2 = e1[SortField], e2[SortField]
        
        if(n1 == n2) then
          return e1.Index < e2.Index
        end
        
       return n1 < n2
      end
    else
      return function(e1, e2)    
        local n1, n2 = e1[SortField], e2[SortField]
        
        if(n1 == n2) then
          return e1.Index < e2.Index
        end
        
       return n1 > n2
      end
    end
  end
end

function ServerBrowserPage:SetServerSorting(serverField, ascending)
  local selected = self:GetSelectedServer()
  
  self.SortFunction = GetSortFunc(serverField, ascending)
  self:SortList()
  
  if(selected) then
	  self:TrySelectServer(selected)
	end
end

function ServerBrowserPage:SortList(dontUpdateUI)

  if(#self.Servers ~= 0 and self.SortFunction) then
    table.sort(self.FilteredList, self.SortFunction)

    if(not dontUpdateUI) then
      self.ServerList:ListDataModifed()
    end
   return true
  end
  
  return false
end

function ServerBrowserPage:Show()
  BaseControl.Show(self)
  self:RefreshList()
end

function ServerBrowserPage:UpdateServerCount()
  
  if(#self.Filters ~= 0) then
    self.ServerCountDisplay:SetText(string.format("Found %i(%i) Servers", #self.FilteredList, #self.Servers))
  else
    self.ServerCountDisplay:SetText(string.format("Found %i Servers", #self.Servers))
  end

end

function ServerBrowserPage:TrySelectServer(server)
    
  if(type(server) == "number") then
    server = self.Servers[server-1]
  end
  
  for index,server2 in ipairs(self.FilteredList) do
    if(server2 == server) then
      self.ServerList:SetSelectedIndex(index)
     return true
    end
  end
  
  return false
end

function ServerBrowserPage:Update()
  
  local NewCount = Client.GetNumServers()
  
  if(self.Refreshing and self.CurrentCount ~= NewCount) then
    
    //if(self.LastUpdate and Client.GetTime()-self.LastUpdate < 1) then
    //  return
    //end
    
    self.LastUpdate = Client.GetTime()
    local noFilters = #self.Filters == 0
    local filteredList = self.FilteredList
    
    for i=self.CurrentCount+1,NewCount do
		 local server = GetServerRecord(i-1)
      
			self.Servers[i] = server
      
			if(noFilters) then
				filteredList[#filteredList+1] = server
      end
    end
    
    self:FilterServers(self.CurrentCount+1)
    
    self.CurrentCount = NewCount
    
    self:SortList()
    
    self.ServerList:ListSizeChanged()
    
    self:UpdateServerCount()
  end
end

class 'ServerListView'(ListView)


class'SBListHeader'(BaseControl)

ButtonMixin:Mixin(SBListHeader)

function SBListHeader:__init(label, serverField)
  
  local text = headerFont:CreateFontString()
   text:SetAnchor(GUIItem.Center, GUIItem.Center)
   text:SetText(label)
  self.Label = text
  
  BaseControl.Initialize(self, text:GetTextWidth(label)+8, text:GetTextHeight(label)+4)
  ButtonMixin.__init(self)
  
  self.RootFrame:SetColor(Color(1,1,1,0.2))
  self.RootFrame:AddChild(text)
  
  self.ServerInfoField = serverField
  
  self.Ascending = false
  
  self.ClickAction = {self.ButtonClicked, self}
end

function SBListHeader:ButtonClicked()
  self.Parent:SetServerSorting(self.ServerInfoField, self.Ascending)
  self.Ascending = not self.Ascending
end

function SBListHeader:OnEnter()
	self.Label:SetColor(Color(0.8666, 0.3843, 0, 1))
	PlayerUI_PlayButtonEnterSound()
 return self
end

function SBListHeader:OnLeave()
	self.Label:SetColor(Color(1, 1, 1, 1))
end