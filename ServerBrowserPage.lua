local PingLimits = {
  0,
  50,
  100, 
  150,
  250,
}

local NameOffset = 0
local GameModeOffset = 0.4
local MapOffset = 0.15
local PlayerOffset = 0.2
local PingOffset = 0.15

local Headers = {
  {"Name",    NameOffset},
  {"Game",    GameModeOffset, "GameMode"},
  {"Map",     MapOffset},
  {"Players", PlayerOffset,  "PlayerCount", true},
  {"Ping",    PingOffset},
}

local headerFont = FontTemplate(19)
headerFont:SetCenterAlignAndAnchor()

class'SBListHeader'(BaseControl)

ButtonMixin:Mixin(SBListHeader)

function SBListHeader:__init(fieldName, label, startDescending)
  
  local text = headerFont:CreateFontString()
   text:SetText(label)
  self.Label = text
  
  BaseControl.Initialize(self, text:GetTextWidth(label)+8, text:GetTextHeight(label)+4)
  ButtonMixin.__init(self)
  
  self:SetColor(Color(1,1,1,0.2))
  self:AddGUIItemChild(text)
  
  self.ServerInfoField = fieldName
  
  self.Ascending = not startDescending
  
  self.ClickAction = {self.ButtonClicked, self}
end

function SBListHeader:ButtonClicked()
  self.Parent:SetServerSorting(self.ServerInfoField, self.Ascending)
  self.Ascending = not self.Ascending
end

function SBListHeader:OnEnter()
	self.Label:SetColor(Color(0.8666, 0.3843, 0, 1))
	PlayerUI_PlayButtonEnterSound()
end

function SBListHeader:OnLeave()
	self.Label:SetColor(Color(1, 1, 1, 1))
end


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

local HotReload = ServerListEntry

class'ServerListEntry'

ServerListEntry.FontSize = 14
ServerListEntry.PingColour100 = Color(0, 1, 0, 1)
ServerListEntry.PingColour250 = Color(0.8588, 0.8588, 0, 1)
ServerListEntry.PingColour600 = Color(1, 0.4901, 0, 1)
ServerListEntry.PingColourWorst = Color(1, 0, 0, 1)

function ServerListEntry:__init(owner, width, height)
  
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
  
  self:SetWidth(width)
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

function ServerListEntry:SetPosition(x,y)
  local vec = self.PositionVector
   vec.x = x
   vec.y = y
  
  self.Background:SetPosition(vec)
end

function ServerListEntry:GetRoot()
  return self.Background
end

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


class'ServerBrowserPage'(BasePage)

function ServerBrowserPage:__init()

  BasePage.__init(self, 740, 500, "Server Browser")

  MapList:Init()

  self.CurrentCount = 0
  self.Servers = {}
  self.Filters = {}
  
  self.FilteredList = self.Servers 

  self:Hide()

  self:SetColor(PageBgColour)

  self.ServerCountDisplay = self:CreateFontString(17, nil, 30, 12)
  

  local ServerList = ListView(700, 350, ServerListEntry)
   ServerList.RootFrame:SetColor(Color(0, 0, 0, 1))
   self:AddChild(ServerList)
   ServerList:SetPosition(20, 60)
   ServerList.ItemDblClicked = function(data, index) self:Connect(data.Index) end
   ServerList:SetDataList(self.Servers)
  self.ServerList = ServerList

  local x = 18+20 
  local width = ServerList.ItemWidth
  
  for i,headerInfo in ipairs(Headers) do
    local Label = SBListHeader(headerInfo[3] or headerInfo[1], headerInfo[1], headerInfo[4])
    self:AddChild(Label)
    
    x = x+(headerInfo[2]*width)
    
    Label:SetPosition(x, 35)
  end
  
  
  local refresh = UIButton("Refresh")
    refresh:SetPoint("BottomLeft", 150, -15, "BottomLeft")
    refresh.ClickAction = {self.RefreshList, self}
  self:AddChild(refresh)
  
  local backButton = UIButton("Back to menu")
    backButton:SetPoint("BottomLeft", 20, -15, "BottomLeft")
    backButton.ClickAction = function() self.Parent:ReturnToMainPage() end
  self:AddChild(backButton)
  
  local connectButton = UIButton("Connect")
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
    pingfilter.ItemPicked = {self.SetPingFilter, self}
    pingfilter:SetConfigBindingAndTriggerChange("ServerBrowser/Ping", 0, "number")
    pingfilter:SetLabel("Ping")
  self:AddChild(pingfilter)

  local hasPlayers = CheckBox("Has Players", false)
    hasPlayers:SetPoint("BottomLeft", 580, -55, "BottomLeft")
    hasPlayers.CheckChanged = {self.SetEmptyServersFilter, self}
    hasPlayers:SetConfigBindingAndTriggerChange("ServerBrowser/HasPlayers", false)
  self:AddChild(hasPlayers)
  
  local notFull = CheckBox("Not Full", false)
    notFull:SetPoint("BottomLeft", 580, -20, "BottomLeft")
    notFull.CheckChanged = {self.SetNotFullFilter, self}
    notFull:SetConfigBindingAndTriggerChange("ServerBrowser/Full", false)
  self:AddChild(notFull)
end

function ListView:Uninitialize()
  BaseControl.Uninitialize(self)
  
  if(self.PasswordPrompt) then
    self.PasswordPrompt:Close()
    self.PasswordPrompt:Uninitialize()
  end
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

function ServerBrowserPage:Connect(server, password)
  
  if(type(server) == "number") then 
	  --the games server indexs are 0 based
	  server = self.Servers[server+1]
  end
	
	if(server.Passworded and not password) then
	  self.PasswordPrompt = self.PasswordPrompt or ServerPasswordPrompt(self)
  
    self.PasswordPrompt.Server = server
    GUIMenuManager:ShowMessageBox(self.PasswordPrompt)
   return
	end
	
	MapList:CheckMountMap(server.Map)
	
  MainMenu_SBJoinServer(server.Address, password)
end

function ServerBrowserPage:RemoveFilter(filter)
  
  if(not filter) then
    return false
  end
  
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
      //ServerList:GetServerRules(i-1, RullCallback)
      //ServerInfo.QueryGameInfo(server.Address, RullCallback)
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

class'ServerPasswordPrompt'(BorderedSquare)

function ServerPasswordPrompt:__init(owner)
  BorderedSquare.__init(self, 400, 100, 4)
  self:Hide()

  local connectButton = UIButton("Connect")
    connectButton:SetPoint("Bottom", 100, -10, "Bottom")
    connectButton.ClickAction = function()
      local password = self.PasswordBox:GetText()
      
      self:Close()
    
      owner:Connect(self.Server, password)
      self.Server = nil
    end
  self:AddChild(connectButton)
  self.Connect = connectButton
 
  local cancelButton = UIButton("Cancel")
   cancelButton:SetPoint("Bottom", -100, -10, "Bottom")
   cancelButton.ClickAction = {self.Close, self}
  self:AddChild(cancelButton)
  self.CancelBtn = cancelButton
 
  local passwordBox = TextBox(150, 20, 19)
    passwordBox:SetPoint("Top", 20, 20, "Top")
    passwordBox:SetLabel("Enter Password")
  self:AddChild(passwordBox)
  self.PasswordBox = passwordBox
end

function ServerPasswordPrompt:Show()
  self.PasswordBox:ClearText()
  
  BaseControl.Show(self)
  self.PasswordBox:SetFocus()
end

function ServerPasswordPrompt:Close()
  if(not self.Hidden) then
   self:Hide(self)
   
   GUIMenuManager:MesssageBoxClosed(self)
  end
end


if(HotReload) then
  GUIMenuManager:RecreatePage("ServerBrowser")
end