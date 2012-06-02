
local HotReload = CreateServerPage
local maps


ControlClass('ConflictEntry', BaseControl)

function ConflictEntry:Initialize(owner, width, height)
  BaseControl.Initialize(self, width, height)
  
  self:SetColor(0.05, 0.05, 0.05, 1)
  
  local modList = self:CreateControl("ComboBox", {Width = 160, Height = height, ItemList = {}})
    modList.ItemSelected = function(modname)
      FullModsManager:SetConflictOverride(self.ScriptPath, modname)
    end
    modList:SetPoint("Right")
  self:AddChild(modList)
  self.ModList = modList
  
  local scriptPath = self:CreateFontString(height-4)
  
  self.ScriptPathLabel = scriptPath
end

function ConflictEntry:SetData(scriptPath)

  self.ScriptPath = scriptPath

  self.ScriptPathLabel:SetText(scriptPath)
  
  self.ModList:SetItemList(FullModsManager:GetModlistForConflict(scriptPath))
end

ControlClass('ScriptConflictWindow', BaseWindow)


function ScriptConflictWindow:Initialize()
  BaseWindow.Initialize(self, 400, 400, "Script Conflicts")
  
  local scriptList = self:CreateControl("ListView", {
      Width = 380, 
      Height = 350, 
      ItemClass = "ConflictEntry", 
      ItemHeight = 20, 
      ItemSpacing = 8,
      ItemsSelectable = false,
      ScrollBarWidth = 25,
    })
    
    scriptList:SetColor(Color(0, 0, 0, 1))
    scriptList:SetPoint("Top", 0, 30, "Top")
    self:AddChild(scriptList)
  self.ScriptList = scriptList
  
  scriptList:SetDataList(FullModsManager:GetConflictScriptList())
end


ControlClass('CreateServerPage', BasePage)

CreateServerPage.ModManager = FullModsManager

CreateServerPage.ModListSetup = {
  Width = 260,
  Height = 350,
  ItemClass = "ModListEntry",
  ItemHeight = 26,
  ItemSpacing = 8,
  ItemsSelectable = false,
  ScrollBarWidth = 25,
}

function CreateServerPage:Initialize()
  
  if(SavedVariables) then
    BasePage.Initialize(self, 700, 450, "Create Listen Server")
  else
    BasePage.Initialize(self, 600, 400, "Create Listen Server")
  end
  
  BaseControl.Hide(self)

  local xoffset = 0

  if(SavedVariables) then
    xoffset = -100

    local modList = self:CreateControl("ListView", self.ModListSetup)
     modList.RootFrame:SetColor(Color(0, 0, 0, 1))
     modList.ItemsSelectable = false
     modList:SetPoint("TopRight", -20, 30, "TopRight")
     modList.ScrollBar:SetWidth(25)
     self:AddChild(modList)
    self.ModList = modList
    
    local list = FullModsManager:GetModList(true)
    table.sort(list)
    modList:SetDataList(list)
    
    local openFolder = self:CreateControl("UIButton", "Open Folder", 120, 40)
      openFolder:SetPoint("BottomRight", -20, -20, "BottomRight")
      openFolder.ClickAction = "OpenFullModsFolder"
    self:AddChild(openFolder)
    
    local refreshList = self:CreateControl("UIButton", "Refresh List", 120, 40)
      refreshList:SetPoint("BottomRight", -160, -20, "BottomRight")
      
      refreshList.ClickAction = function()
        
        FullModsManager:RefreshModList()
        
        local list = FullModsManager:GetModList(true)
        
        table.sort(list)
        modList:SetDataList(list)
        
      end
    self:AddChild(refreshList)
    
   // GUIMenuManager:CreateWindow("ScriptConflictWindow")
  end

  local gameName = self:CreateControl("TextBox", 200, 24)
    gameName:SetPoint("Top", xoffset, 50, "Top")
    gameName:SetLabel("Game Name:")
    gameName:SetConfigBinding("serverName", "NS2 Server")
  self:AddChild(gameName)

  local password = self:CreateControl("TextBox", 200, 24)
    password:SetPoint("Top", xoffset, 100, "Top")
    password:SetLabel("Password (if any):")
    password:SetConfigBinding("serverPassword", "")
  self:AddChild(password)

  MapList:Init()
  
  local map = self:CreateControl("ComboBox", {Width = 200, Height = 20, ItemList = MapList.Maps, LabelCreator = function(entry) return entry.name end})
    map:SetPoint("Top", xoffset, 150, "Top")
    map:SetConfigBinding("mapName", "", nil, self.MapValueConverter)
    map:SetLabel("Map:")
  self:AddChild(map)
  self.MapComboBox = map
  
  local converter = function(value) 
    if(type(value) == "string") then
      return tonumber(value)
    else
      return tostring(value)
    end
  end
  
  local port = self:CreateControl("TextBox", 60, 24)
    port:SetLabel("Port:")
    port:SetPoint("Top", -70+xoffset, 240, "Top")
    port:SetConfigBinding("serverPort", 27015, nil, converter):SetValidator(function(value) 
      local valid, result = pcall(tonumber, value)
      
      return valid and result > 0
    end)
  self:AddChild(port)
  
  local playerLimit = self:CreateControl("TextBox", 30, 24)
    playerLimit:SetLabel("Player Limit:")
    playerLimit:SetPoint("Top", -85+xoffset, 200, "Top")
    playerLimit:SetConfigBinding("playerLimit", 16, nil, converter):SetValidator(function(value) 
      local valid, result = pcall(tonumber, value)
      
      return valid and result > 0
    end)
  self:AddChild(playerLimit)
  
  local lanGame = self:CreateControl("CheckBox", {Label = "Lan Game:", Checked = false })
    lanGame:SetPoint("Top", -10+xoffset, 200, "Top")
    lanGame:SetConfigBinding("lanGame", true)
  self:AddChild(lanGame)
  
  local create = self:CreateControl("UIButton", "Create", 200, 40)
    create:SetPoint("Bottom", xoffset, -50, "Bottom")
    create.ClickAction = {self.CreateServer, self}
  self:AddChild(create)

  self:AddBackButton("BottomLeft", 20, -15, "BottomLeft")
end

function CreateServerPage:CreateServer()

  local password      = Client.GetOptionString("serverPassword", "")
  local port          = Client.GetOptionInteger("serverPort", 27015)
  local maxPlayers    = Client.GetOptionInteger("playerLimit", 16)
  
  local mapEntry = self.MapComboBox:GetSelectedItem()
  local mapName
  
  
  if(mapEntry) then
    if(mapEntry.archiveType) then
      MapList:CheckMountMap(mapEntry.name)
      mapName = mapEntry.name..".level"
    else
      mapName = mapEntry.fileName
    end
    
    //vm is recreated so we can't call this here FullModsManager:MountEnabledMods()

    if(Client.StartServer( mapName, password, port, maxPlayers )) then
      FullModsManager.ClientVMIsListenServer = true
      LeaveMenu()
    end
  end
end

function CreateServerPage.MapValueConverter(entry, index)

  --getting value mode
  if(not index) then
    return MapList:GetFileEntryIndex(entry)
  else
    return entry.fileName
  end
end

if(HotReload) then
  GUIMenuManager:RecreatePage("CreateServer")
end