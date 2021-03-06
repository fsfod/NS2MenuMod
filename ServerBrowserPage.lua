//
//   Created by:   fsfod
//
ControlClass('ServerBrowserPage', BasePage)

ServerBrowserPage.FallbackToOfflineListTimeOut = 8
ServerBrowserFontSize = ServerBrowserFontSize or 20

ServerBrowserPage.PingLimits = {
  0,
  50,
  100, 
  150,
  250,
}

local headerFont = FontTemplate(19)
headerFont:SetCenterAlignAndAnchor()


function GetTrimmedMapName(mapName)

    for trimmedName in string.gmatch(mapName, [[\/(.+)\.level]]) do
        return trimmedName
    end
    
    return mapName
end

function GetServerInfo(serverIndex)
    
    local playerCount = Client.GetServerNumPlayers(serverIndex)
    local maxPlayers = Client.GetServerMaxPlayers(serverIndex)
    
    local playeryCount, botCount
    local botCount = (ServerList and ServerList:GetServerBotCount(serverIndex)) or 0
    
    if(botCount ~= 0) then
      playeryCount = string.format("%i(bots %i)/%i", playerCount, botCount, maxPlayers)
    else
      playeryCount = playerCount.. " / "..maxPlayers
    end
    

    return
        { 
            name = Client.GetServerName(serverIndex),
            map = GetTrimmedMapName(Client.GetServerMapName(serverIndex)),
            numPlayers = playerCount,
            maxPlayers = maxPlayers,
            ping = Client.GetServerPing(serverIndex),
            requiresPassword = Client.GetServerRequiresPassword(serverIndex),
            address = Client.GetServerAddress(serverIndex),
            Index = serverIndex,
            QueryPort = ServerList and ServerList:GetServerQueryPort(serverIndex),
            BotCount = botCount,
            GameTag = ServerList and ServerList:GetServerGameTags(serverIndex),
            playeryCount,
        }
end


local HotReload = ServerListEntry

ControlClass('ServerListEntry', BaseControl)

ServerListEntry.FontSize = ServerBrowserFontSize
ServerListEntry.PingColour100 = Color(0, 1, 0, 1)
ServerListEntry.PingColour250 = Color(0.8588, 0.8588, 0, 1)
ServerListEntry.PingColour600 = Color(1, 0.4901, 0, 1)
ServerListEntry.PingColourWorst = Color(1, 0, 0, 1)

ServerListEntry.ValueIndent = 4

function ServerListEntry:Initialize(owner, width, height, fontSize, layout)
  
  BaseControl.Initialize(self, width, height)
  
  self.Owner = owner
  
  self.FontSize = fontSize
  
  local passwordIcon = self:CreateGUIItem()
    passwordIcon:SetSize(Vector(10,12, 0))
    passwordIcon:SetTexture("ui/passworded.dds")
  self.requiresPassword = passwordIcon
  
  local serverName = self:CreateFontString(self.FontSize)
   serverName:SetPosition(Vector(18, 1, 0))
   serverName:SetTextAlignmentY(GUIItem.Align_Min)
  self.name = serverName

  self.map = self:CreateFontString(self.FontSize)
  
  self.numPlayers = self:CreateFontString(self.FontSize)
  
  self.ping = self:CreateFontString(self.FontSize)

  local gameTag = self:CreateFontString(self.FontSize)
  self.GameTag = gameTag

  self:SetColor(Color(0,0,0,0))

  self:UpdateLayout(layout)

  self:SetWidth(width)
end

function ServerListEntry:OnHide()
  self:Hide()
end

function ServerListEntry:OnClick(button, down)

  if(not down) then
    return
  end

  if(button == InputKey.MouseButton1) then 
    self.Owner:SetSelectedItem(self)
    
    //we were rightclicked so show a server info window for this entry
    GUIMenuManager:CreateWindow("ServerInfoWindow", self.Data)
  elseif(button == InputKey.MouseButton0) then
    
    if(self.LastClicked and (Client.GetTime()-self.LastClicked) < GUIMenuManager.DblClickSpeed) then
      self.Owner.Parent:Connect(self.Data.Index)
     return
    end

    self.LastClicked = Client.GetTime()
    
    return false
  end
end

function ServerListEntry:OnShow()
  self:Show()
end

function ServerListEntry:GetRoot()
  return self.RootFrame
end

function ServerListEntry:UpdateLayout(positionList)
  local height = self:GetHeight()
  local Widths = self.Owner.ColumnWidths

  for name,offset in pairs(positionList) do

    local control = self[name]
    control:SetPosition(offset)
    
    if(name ~= "requiresPassword") then
      control:SetTextClipped(true, Widths[name]-self.ValueIndent, height)
    end
  end
end

function ServerListEntry:SetWidth(width) 

end

function ServerListEntry:SetData(serverData)
  if(self.Hidden) then
    self:Show()
  end

  self.Data = serverData

  self.requiresPassword:SetIsVisible(serverData.requiresPassword)

  self.name:SetText(serverData.name)
  self.map:SetText(serverData.map)
  self.numPlayers:SetText(serverData[1])
  self.ping:SetText(tostring(serverData.ping))
  self.GameTag:SetText(serverData.GameTag or "")
  
  local ping = serverData.ping
  
  if(ping <= 100) then
    self.ping:SetColor(self.PingColour100)
  elseif(ping > 600) then
    self.ping:SetColor(self.PingColourWorst)
  elseif(ping > 250) then
    self.ping:SetColor(self.PingColour600)
  elseif(ping > 100) then
    self.ping:SetColor(self.PingColour250)
  end
end

local fontsize = 20

ServerBrowserPage.PageSetup = {
  Width = 840,
  Height = 700,
  //Position = {"Left", 30, 150, "Left"},
  Title = "Server Browser",
  PageName = "ServerBrowser",
}

ServerBrowserPage.ControlSetup = {
  
  LockHeader = {
    Type = "CheckBox",
    Height = 18,
    Position = {"TopRight", -2, 30},
    Label = "",
    Checked = false,
    CheckChanged = "SetLockHeader",
    ConfigDataBind = {
      TableKey = "ResizableTabs", 
      Table = MainMenuMod.ServerBrowser_Settings, 
      DefaultValue = true, 
      ValueConverter = function(value)
        return not value
      end,
    },
  },

  ServerList = {
    Type = "ListView",
    
    Header = {
      Type = "TabHeader",
      Width = 780,
      Height = 23,
      Position = Vector(0, 0, 0),
      Mode = "ListHeader",
      FontSize = 20,
      TabPressed = "ColumnClicked",
      TabsSwapped = "ColumnSwapped",
      TabResized = "ColumnResized",
      GetSavedLayout = "GetSavedHeaderLayout",
      RestoreSavedOptions = function()
        return MainMenuMod.ServerBrowser_Settings, {"ResizableTabs", "DraggableTabs"}
      end,
      
      TabList = {
        {Label = "",        Width = 20,  NameTag = "requiresPassword", ClickEnabled = false},
        {Label = "Name",    Width = 353, NameTag = "name"},
        {Label = "Map",     Width = 133, NameTag = "map"},
        {Label = "Players", Width = 70,  NameTag = "numPlayers", Ascending = true},
        {Label = "Ping",    Width = 47,  NameTag = "ping", MinWidth = 40},
        {Label = "Tags",    Width = 100, NameTag = "GameTag"},
      }
    },
    
    //Width = 800,
    //Height = 350,
    Position = {"TopLeft", 20, 30},
    Point2 = {"BottomRight", -20, -90},
    Color = Color(0, 0, 0, 1),
    ItemHeight = ServerBrowserFontSize+2,
    ItemSpacing = 3,
    FontSize = ServerBrowserFontSize,
    ItemClass = "ServerListEntry",
    SelectedItemColor = Color(0, 0, 0.3, 1),
    DelayCreateItems = true,
  },
      
  PingFilter = {
    Type = "ComboBox",
    Width = 100, 
    Height = fontsize+2,
    Position = {"BottomRight", -155, -55, "BottomRight"},
    
    Label = "Ping",
    ItemList = {0, 50, 100, 250}, 
    LabelCreator = function(ping) 
      if(ping == 0) then
        return "All"
      else
        return string.format("< %i", ping)
      end
    end
  },
  
  MapTextBox = {
    Type = "TextBox",
    Width = 100,
    Height = fontsize+2,
    Position = {"BottomRight", -155, -20, "BottomRight"},
    Label = "Map",
  },
  
  HasPlayers = {
    Type = "CheckBox",
    Position = {"BottomRight", -120, -55, "BottomRight"},
    FontSize = fontsize,
    Label = "Has Players", 
    Checked = false,
    CheckChanged = "SetEmptyServersFilter",
  },

  NotFull = {
    Type = "CheckBox",
    Position = {"BottomRight", -120, -20, "BottomRight"},
    FontSize = fontsize,
    Label = "Not Full", 
    Checked = false,
    CheckChanged = "SetNotFullFilter",
  },
  
  Refresh = {
    Type = "UIButton",
    Label = "Refresh",
    Position = {"BottomLeft", 150, -15, "BottomLeft"},
    ClickAction = "RefreshList",
  },
  
  ConnectButton = {
    Type = "UIButton",
    Label = "Connect",
    Position = {"BottomLeft", 300, -15, "BottomLeft"},
  },
  
  Resize = {
    Type = "ResizeButton",
    Position = {"BottomRight", 0, 0},
  },  
}

ServerBrowserPage.Sorters = {
  numPlayers = true,
  ping = true,
  map = true,
  name = true,
}

function ServerBrowserPage:Initialize()

  local settings = MainMenuMod.ServerBrowser_Settings
  self.Settings = settings
/*
  if(Client.GetScreenWidth() > 900) then
    local width = Client.GetScreenWidth()-200
    
    width = math.min(width, 1000)
    
    self.PageSetup.Width = width
    
    self.ControlSetup.ServerList.Width = width-40
    self.ControlSetup.ServerHeader.Width = width-60
  end
*/
  self:SetupFromTable(self.PageSetup)
  self:CreatChildControlsFromTable(self.ControlSetup)

  self.ServerHeader = self.ServerList.Header

  self.CurrentCount = 0
  self.Servers = {}
  self.Filters = {}
  
  self.FilteredList = self.Servers 

  self:Hide()

  self:SetColor(PageBgColour)

  self.ServerCountDisplay = self:CreateFontString(17, nil, 30, 12)

  self.AutoSelectedConnected = true
  
  if(settings.SortColumn) then
    self:SetServerSorting(settings.SortColumn, settings.SortIsAscending)
  end
  
  local columnOffsets = {}

  for name,offset in pairs(self.ServerHeader:GetTabOffsets()) do
    columnOffsets[name] = Vector(offset+ServerListEntry.ValueIndent, 0, 0)
  end
  self.ColumnOffsets = columnOffsets
 
  local serverList = self.ServerList
  serverList.ColumnWidths = self.ServerHeader:GetTabWidths()
  serverList:SetItemLayout(columnOffsets)
  serverList:SetDataList(self.Servers)
  serverList.ItemSelected = function() 
    if(Client.GetIsConnected()) then
      self.AutoSelectedConnected = false
    end
  end
   
   
  self:AddBackButton("BottomLeft", 20, -15, "BottomLeft")

  self.ConnectButton.ClickAction = function()
    local index = self.ServerList:GetSelectedIndex()
    if(index) then
      self:Connect(self.FilteredList[index].Index)
    end
  end

  self.PingFilter.ItemPicked = {self.SetPingFilter, self}
  self.PingFilter:SetConfigBindingAndTriggerChange("ServerBrowser/Ping", 0, "number")

  //self.HasPlayers.CheckChanged = {self.SetEmptyServersFilter, self}
  self.HasPlayers:SetConfigBindingAndTriggerChange("ServerBrowser/HasPlayers", false)
  
  //self.NotFull.CheckChanged = {self.SetNotFullFilter, self}
  self.NotFull:SetConfigBindingAndTriggerChange("ServerBrowser/Full", false)
  
  self.MapTextBox.TextChanged = {self.SetMapFilter, self}
  self.MapTextBox:SetConfigBindingAndTriggerChange("ServerBrowser/Map", "")
  
  self.ServerListUpdater = self.OnlineUpdateList
end

function ServerBrowserPage:SetLockHeader(locked)

  self.Settings.ResizableTabs = not locked
  self.Settings.DraggableTabs = not locked
  
  self.ServerHeader:SetResizableTabs(not locked)
  self.ServerHeader:SetDraggableTabs(not locked)
end

function ServerBrowserPage:GetSavedHeaderLayout()
  return self.Settings.ColumnOrder, self.Settings.ColumnWidths
end

function ServerBrowserPage:ColumnSwapped()
  self.Settings.ColumnOrder = self.ServerList.Header:GetTabOrder(self.Settings.ColumnOrder)
  self:UpdateServerListLayout()
end

function ServerBrowserPage:ColumnResized()
  self.Settings.ColumnWidths = self.ServerList.Header:GetTabWidths(self.Settings.ColumnWidths) 
  self.ServerList.ColumnWidths = self.Settings.ColumnWidths
  self:UpdateServerListLayout()
end

function ServerBrowserPage:UpdateServerListLayout()

  for name,offset in pairs(self.ServerList.Header:GetTabOffsets()) do
    self.ColumnOffsets[name].x = offset+ServerListEntry.ValueIndent
  end

  self.ServerList:SetItemLayout(self.ColumnOffsets)
end

function ServerBrowserPage:Hide()
  BaseControl.Hide(self)
end

function ServerBrowserPage:ColumnClicked(tab)
  self:SetServerSorting(tab.NameTag or tab.Label, not tab.Ascending, tab)
end

function ServerBrowserPage:SetNotFullFilter(filter)
  
  if(filter) then
    self.FullFiltered = function(server) 
      return server.numPlayers >= server.maxPlayers 
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
      return server.numPlayers == 0 
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

  ConnectedInfo:ConnectToServer(server)
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

  if(self.PingFilter) then
    self:RemoveFilter(self.PingFilter)
    self.PingFilter = nil
    self.MaxPing = nil
	end

	if(maxping and maxping ~= 0) then
    self.MaxPing = maxping
    self.PingFilter = function(server) return server.ping > maxping end
    self:AddFilter(self.PingFilter)
  end
  
  self:FiltersChanged()
end

function ServerBrowserPage:SetMapFilter(map)  

  if(self.MapFilter) then
    self:RemoveFilter(self.MapFilter)
    self.MapFilter = nil
	end

	if(map ~= nil or map == "") then
	  map = map:lower()

    self.MapFilter = function(server) return string.find(server.map:lower(), map) == nil end
    self:AddFilter(self.MapFilter)
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
  
  self.LastUpdate = Client.GetTime()
  
  self.Servers = {}
  self.FilteredList = {}
  self.ServerList:SetDataList(self.FilteredList)

  self.ServerCountDisplay:SetText("")

  self.ConnectedEntry = nil
  self.AutoSelectedConnected = true

  self.Refreshing = true
  self.CurrentCount = 0

   if(self.ServerListUpdater == self.OfflineUpdateList or (false and MainMenuMod.KnownServers and #MainMenuMod.KnownServers > 0)) then
    self:OfflineRefresh()
  else
    Client.RebuildServerList()
  end
end

local function GetSortFunc(SortField, ascending)

  if(SortField == "map" or SortField == "name") then
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
  elseif(SortField == "numPlayers" or SortField == "ping") then
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

function ServerBrowserPage:SetServerSorting(serverField, ascending, tab)
  
  local sortField = (tab and tab.SortField) or serverField
  
  if(not self.Sorters[sortField]) then
    return
  end  

  //save the sort column and direction
  self.Settings.SortColumn = serverField
  self.Settings.SortIsAscending = ascending

  self.ServerHeader:SetTabSortDirection(tab or serverField, ascending)
    
  self.SortFunction = GetSortFunc(sortField, ascending)
  self:SortList()
end

function ServerBrowserPage:SortList(dontUpdateUI)

  if(#self.Servers ~= 0 and self.SortFunction) then
    table.sort(self.FilteredList, self.SortFunction)

    if(not dontUpdateUI) then
      self.ServerList:ListDataModifed(true)
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
  
  local text
  
  if(#self.Filters ~= 0) then
    text = string.format("Found %i(%i) Servers", #self.FilteredList, #self.Servers)
  else
    text = string.format("Found %i Servers", #self.Servers)
  end


  if(self.ServerListUpdater == self.OfflineUpdateList) then
    text = text..", Master Server Offline Mode"
  end
  
  self.ServerCountDisplay:SetText(text)
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

function ServerBrowserPage:WriteFoundServerList()
  
  local knownServers = {} 
  
  for i=1,self.CurrentCount do
    
    local server = self.Servers[i]
    
    knownServers[i] = {server.Address, server.QueryPort}
  end
  
  MainMenuMod.KnownServers = knownServers
  
end

function ServerBrowserPage:OfflineRefresh()
  //ServerList:CancelRefresh()
  //ServerInfo.CancelActiveQuerys()
  
  self.ServerListUpdater = self.OfflineUpdateList
  
  assert(MainMenuMod.KnownServers and #MainMenuMod.KnownServers > 0)
  
  self.SingleQueryResults = {}
  
  local callbackFunc = function(serverInfo)
    
    if(not self.SingleQueryCount) then
      //were no longer intested in single query results if self.SingleRequestCount is nil or false
      return
    end
 
    self.SingleQueryCount = self.SingleQueryCount+1
    
    if(not serverInfo) then
       self.FailedQueryCount = self.FailedQueryCount+1
      return
    end
    
 
    serverInfo[1] = serverInfo.numPlayers.. " / "..serverInfo.maxPlayers
      
    self.SingleQueryResults[#self.SingleQueryResults+1] = serverInfo
    
    serverInfo.Index = (self.SingleQueryCount-self.FailedQueryCount)-1
  end
  
  //TODO thottle this or do it in batchs
  for i,server in ipairs(MainMenuMod.KnownServers) do
    Client.RefreshServer(server[1], callbackFunc)
  end

  self.SingleQueryCount = 0
  self.FailedQueryCount = 0
end

function ServerBrowserPage:OfflineUpdateList()

  local NewCount = #self.SingleQueryResults

  if(self.SingleQueryCount == #MainMenuMod.KnownServers) then
    self.Refreshing = false
  end

  if(NewCount == 0) then
   return nil
  end

  for i,server in ipairs(self.SingleQueryResults) do
    self.Servers[self.CurrentCount+i] = server
  end
  
  local servers = self.SingleQueryResults
  self.SingleQueryResults = {}
  
  return servers
end

function ServerBrowserPage:OnlineUpdateList()
  
  local NewCount = Client.GetNumServers()
  local servers
  
  if(self.CurrentCount ~= NewCount) then    
  
    servers = {}
  
    NewCount = NewCount-self.CurrentCount
  
    for i=1,NewCount do
			servers[i] = GetServerInfo(self.CurrentCount+(i-1))
    end
  end
  
  if(ServerList and ServerList.RefreshFinished) then
    self.Refreshing = false
    
    if(self.CurrentCount ~= 0) then
      self:WriteFoundServerList()
    end
  end
  
  return servers
end

function ServerBrowserPage:Update()
  
  if(not self.Refreshing) then
    return
  end

  local connectedAddress

  if(Client.GetIsConnected()) then
    connectedAddress = ConnectedInfo:GetConnectedAddress()
  end
  
  local NewServers = self:ServerListUpdater()
  
  local time = Client.GetTime()
  
  if(NewServers == nil) then
    if(self.CurrentCount == 0 and self.ServerListUpdater ~= self.OfflineUpdateList and (time-self.LastUpdate) > self.FallbackToOfflineListTimeOut and
       MainMenuMod.KnownServers and #MainMenuMod.KnownServers > 0) then
       
      self:OfflineRefresh()
    end
   return
  end

  if(NewServers == nil) then
    return
  end

  self.LastUpdate = time
  
  local noFilters = #self.Filters == 0
  local filteredList = self.FilteredList
  
  for i,server in ipairs(NewServers) do
    self.Servers[self.CurrentCount+i] = server
  
    if(noFilters) then
      filteredList[#filteredList+1] = server
    end
    
    if(server.Address == connectedAddress and server.Address) then
      self.ConnectedEntry = server
    end
  end
  
  self:FilterServers(self.CurrentCount+1)
  
  self.CurrentCount = self.CurrentCount+#NewServers
  
  self:SortList()
  
  self.ServerList:ListSizeChanged()
  
  self:UpdateServerCount()

  if(self.ConnectedEntry) then
    if(self.AutoSelectedConnected and self.ServerList:GetSelectedIndexData() ~= self.ConnectedEntry) then
      self.ServerList:SetSelectedListEntry(self.ConnectedEntry)
    end
  else
    
    if(not Client.GetIsConnected()) then
      //self:TrySelectServer(server)
    end
  end
end

ControlClass('ServerPasswordPrompt', BaseWindow)

function ServerPasswordPrompt:Initialize(serverInfo, owner)
  BaseWindow.Initialize(self, 400, 100, "Enter Server Password", true)

  self.ServerInfo = serverInfo

  self.Address = self.ServerInfo.Address

  local connectButton = self:CreateControl("UIButton", "Connect")
    connectButton:SetPoint("Bottom", 100, -10, "Bottom")
    connectButton.ClickAction = function()
      self:Connect()
    end
  self:AddChild(connectButton)
 
  local cancelButton = self:CreateControl("UIButton", "Cancel")
   cancelButton:SetPoint("Bottom", -100, -10, "Bottom")
   cancelButton.ClickAction = {self.Close, self}
  self:AddChild(cancelButton)
  self.CancelBtn = cancelButton

  local passwordBox = self:CreateControl("TextBox", 150, 20, 19)
    passwordBox:SetPoint("Top", 20, 20, "Top")
    passwordBox:SetLabel("Enter Password")
    passwordBox.SendKeyEvent = function(tbSelf, key, down)
      if key == InputKey.Escape then
        self:Close()
      else
        return TextBox.SendKeyEvent(tbSelf, key, down)
      end
    end
  self:AddChild(passwordBox)
  self.PasswordBox = passwordBox
  
  self.PasswordBox:SetFocus()
end

function ServerPasswordPrompt:Connect()
	
  if(self.ServerInfo) then
	  ConnectedInfo:ConnectToServer(self.ServerInfo,  self.PasswordBox:GetText())
	else
	  MainMenu_SBJoinServer(self.Address,  self.PasswordBox:GetText())
	end

	self:Close()
end

function ServerPasswordPrompt:Show()
  self.PasswordBox:ClearText()
  
  BaseControl.Show(self)
  self.PasswordBox:SetFocus()
end

function ServerPasswordPrompt:Close()
  self.PasswordBox:ClearText()
  
  if(not self.Hidden) then
   self:Hide(self)
   
   //GUIMenuManager:MesssageBoxClosed(self)
  end
end


if(HotReload) then
  GUIMenuManager:RecreatePage("ServerBrowser")
end