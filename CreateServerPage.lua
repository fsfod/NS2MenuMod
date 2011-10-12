
local HotReload = CreateServerPage
local maps

ControlClass('CreateServerPage', BasePage)


function CreateServerPage:Initialize()
  BasePage.Initialize(self, 600, 400, "Create Listen Server")
  BaseControl.Hide(self)
  
  self:SetColor(Color(0.1, 0.1, 0.1,0.7))

  local gameName = self:CreateControl("TextBox", 200, 22)
    gameName:SetPoint("Top", 0, 50, "Top")
    gameName:SetLabel("Game Name")
    gameName:SetConfigBinding("serverName", "NS2 Server")
  self:AddChild(gameName)

  local password = self:CreateControl("TextBox", 200, 22)
    password:SetPoint("Top", 0, 100, "Top")
    password:SetLabel("Password (if any)")
    password:SetConfigBinding("serverPassword", "")
  self:AddChild(password)

  MapList:Init()
  
  local map = self:CreateControl("ComboBox", 200, 20, MapList.Maps, function(entry) return entry.name end)
    map:SetPoint("Top", 0, 150, "Top")
    map:SetConfigBinding("mapName", "", nil, self.MapValueConverter)
    map:SetLabel("Map")
  self:AddChild(map)
  self.MapComboBox = map
  
  local converter = function(value) 
    if(type(value) == "string") then
      return tonumber(value)
    else
      return tostring(value)
    end
  end
  
  local playerLimit = self:CreateControl("TextBox", 30, 20)
    playerLimit:SetLabel("Player Limit")
    playerLimit:SetPoint("Top", -85, 200, "Top")
    playerLimit:SetConfigBinding("playerLimit", 16, nil, converter):SetValidator(function(value) 
      local valid, result = pcall(tonumber, value)
      
      return valid and result > 0
    end)
  self:AddChild(playerLimit)
  
  local lanGame = self:CreateControl("CheckBox", "Lan Game")
    lanGame:SetPoint("Top", -10, 200, "Top")
    lanGame:SetConfigBinding("lanGame", true)
  self:AddChild(lanGame)
  
  local create = self:CreateControl("UIButton", "Create", 200, 40)
    create:SetPoint("Bottom", 0, -70, "Bottom")
    create.ClickAction = {self.CreateServer, self}
  self:AddChild(create)

  self:AddBackButton("BottomLeft", 20, -15, "BottomLeft")
end

function CreateServerPage:CreateServer()

  local password      = Client.GetOptionString("serverPassword", "")
  local port          = 27015
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

    if(Client.StartServer( mapName, password, port, maxPlayers )) then
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