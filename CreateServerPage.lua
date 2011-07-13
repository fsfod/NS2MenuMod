
local HotReload = CreateServerPage
local maps

class'CreateServerPage'(BasePage)


function CreateServerPage:__init()
  BasePage.__init(self, 600, 400, "Create Listen Server")
  BaseControl.Hide(self)
  
  self.RootFrame:SetColor(Color(0.1, 0.1, 0.1,0.7))

  local gameName = TextBox(200, 22)
    gameName:SetPoint("Top", 0, 50, "Top")
    gameName:SetLabel("Game Name")
    gameName:SetConfigBinding("serverName", "NS2 Server")
  self:AddChild(gameName)

  local password = TextBox(200, 22)
    password:SetPoint("Top", 0, 100, "Top")
    password:SetLabel("Password (if any)")
    password:SetConfigBinding("serverPassword", "")
  self:AddChild(password)

  MapList:Init()
  
  local map = ComboBox(200, 20, MapList.Maps, function(entry) return entry.name end)
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
  
  local playerLimit = TextBox(30, 20)
    playerLimit:SetLabel("Player Limit")
    playerLimit:SetPoint("Top", -85, 200, "Top")
    playerLimit:SetConfigBinding("playerLimit", 16, nil, converter):SetValidator(function(value) 
      local valid, result = pcall(tonumber, value)
      
      return valid and result > 0
    end)
  self:AddChild(playerLimit)
  
  local lanGame = CheckBox("Lan Game")
    lanGame:SetPoint("Top", -10, 200, "Top")
    lanGame:SetConfigBinding("lanGame", true)
  self:AddChild(lanGame)
  
  local create = MainMenuPageButton("Create", 200, 40)
    create:SetPoint("Bottom", 0, -70, "Bottom")
    create.ClickAction = {self.CreateServer, self}
  self:AddChild(create)
  
  local backButton = MainMenuPageButton("Back to menu")
    backButton:SetPoint("BottomLeft", 20, -15, "BottomLeft")
    backButton.ClickAction = function() self.Parent:ReturnToMainPage() end
  self:AddChild(backButton)
end

function CreateServerPage:CreateServer()

  local password      = Client.GetOptionString("serverPassword", "")
  local port          = 27015
  local maxPlayers    = Client.GetOptionInteger("playerLimit", 16)
  
  local mapEntry = self.MapComboBox:GetSelectedItem()
  local mapName

  if(mapEntry) then
    if(mapEntry.archiveType) then
      mapName = mapEntry.name..".level"
      
      local archive = NS2_IO.OpenArchive("maps/"..mapEntry.fileName)
      
      NS2_IO.MountMapArchive(archive)
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
  MainMenuMod:RecreatePage("CreateServer")
end