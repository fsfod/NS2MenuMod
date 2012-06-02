
local HotReload = ModListEntry

ControlClass('ModListEntry', BaseControl)

function ModListEntry:Initialize(listview, width, height)

  BaseControl.Initialize(self, width, height)
  self.Parent = listview

  self:SetColor(Color(0,0,0,0))

  local button =  self:CreateControl("CheckButton", height, false)
    button:SetPosition(22, 0)
    self:AddChild(button)
  self.Button = button
  
  local errorStatus = self:CreateFontString(22, "Left", 2, 0)
    errorStatus:SetColor(Color(1,0,0,1))
    errorStatus:SetTextAlignmentY(GUIItem.Align_Center)
    self:AddGUIItemChild(errorStatus)
  self.ErrorStatus = errorStatus
  
  local modName = self:CreateFontString(22, "Left", height+30, 0)
    modName:SetTextAlignmentY(GUIItem.Align_Center)
    self:AddGUIItemChild(modName)
  self.ModNameText = modName
end

function ModListEntry:SetData(modName)

  self:Show()

  self.ModManager = self.Parent.Parent.ModManager

  local disabled, realName, errorValue = self.ModManager:GetModInfo(modName)
  
  self.Checked = not disabled
  
  self.ModName = modName
  
  if(errorValue < 0 or (self.ModManager == FullModsManager and errorValue > 0)) then
    self.ErrorStatus:SetIsVisible(true)
    self.ErrorStatus:SetText((errorValue ~= 0 and tostring(errorValue) or ""))
  else
    self.ErrorStatus:SetIsVisible(false)
  end
  
  self.ModNameText:SetText(realName)
  self.Button:SetCheckedState(self.Checked)
end

function ModListEntry:GetRoot()
	return self.RootFrame
end

function ModListEntry:OnCheckedToggled()
  self.Checked = not self.Checked
  
  if(self.Checked ) then
    self.ModManager:EnableMod(self.ModName)
  else
    self.ModManager:DisableMod(self.ModName)
  end

  self.Parent:ListDataModifed()
  
  return self.Checked
end

ControlClass('SteamModListEntry', BaseControl)

function SteamModListEntry:Initialize(listview, width, height)

  BaseControl.Initialize(self, width, height)
  self.Parent = listview

  self:SetColor(Color(0,0,0,0))

  local modName = self:CreateFontString(22, "Left", height+30, 0)
    modName:SetTextAlignmentY(GUIItem.Align_Center)
    self:AddGUIItemChild(modName)
  self.ModNameText = modName
  
  local status = self:CreateFontString(22, "Left", 200, 0)
    //status:SetColor(Color(1,0,0,1))
    status:SetTextAlignmentY(GUIItem.Align_Center)
    self:AddGUIItemChild(status)
  self.Status = status
  
end

function SteamModListEntry:SetData(modIndex)

  self:Show()

  self.ModManager = self.Parent.Parent.ModManager
  
  self.ModIndex = modIndex
 
  if(not Client.ModDetailsAreKnown(modIndex)) then
    self.ModNameText:SetText("Unknown")
    self.Status:SetText("Unknown")
  else
    local active, realName, statusText = SteamWorkshopModManager:GetModInfo(modIndex)

    self.ModNameText:SetText(realName)
  
    self.Status:SetText(realName)
  end
end

ControlClass('ModsPage', BasePage)

ModsPage.PageName = "Mods"

//ModListEntry pull this value from us when its created
ModsPage.ModManager = ModLoader

ModsPage.ControlSetup = {

  ModListSelector = {
    Type = "TabHeader",
    Mode = "Tab",
    Position = {"Top", 0, 24},
    Height = 30,
    FontSize = 25,
    Width = 560,
    TabSpacing = 8,
    ExpandTabsToFit = true,
    TabPressed = "TabClicked",
    ActiveTab = "ModLoader",
    TabList = {
      {Label = "Steam Workshop", NameTag = "SteamWorkshop"},
      {Label = "Internal", NameTag = "ModLoader"},
      {Label = "Raw Mods", NameTag = "FullModsManager"},
    },
  },

  ModList = {
    Type = "ListView",
    Position = Vector(40, 60, 0),
    Width = 560,
    Height = 350,
    ItemHeight = 26,
    ItemSpacing = 8,
    ItemClass = "ModListEntry",
    ItemsSelectable = false,
    ScrollBarWidth = 25,
  },

  EnableAllButton = {
    Type = "UIButton",
    Width = 130,
    Position = {"BottomLeft", 30, -20, "BottomLeft"},
    Label = "Enable All", 
    ClickAction = "EnableAll",
  },
  
  DisableAllButton = {
    Type = "UIButton",
    Width = 130,
    Position = {"BottomLeft", 180, -20, "BottomLeft"},
    Label = "Disable All", 
    ClickAction = "DisableAll",
  },
}

function ModsPage:Initialize()
  BasePage.Initialize(self, 600, 500, self.PageName, "Mods")

  self:Hide()
  self:CreatChildControlsFromTable(self.ControlSetup)

  self.ModList:SetColor(Color(0, 0, 0, 1))
    
  if(NS2_IO) then
    local openModsFolder = self:CreateControl("UIButton", "Open Mods Folder", 150)
      openModsFolder:SetPoint("BottomLeft", 400, -20, "BottomLeft")
      openModsFolder.ClickAction = NS2_IO.OpenModsFolder
    self:AddChild(openModsFolder)
  end
  
  self:SetModList("ModLoader")
end

function ModsPage:TabClicked(tab)
  self:SetModList(tab.NameTag)
  
  if(self.ModList.ItemClass == "LVTextItem") then 
   // self.ModList:ChangeItemClass("ModListEntry")
  else
    //self.ModList:ChangeItemClass("SteamModListEntry")
  end
end

function ModsPage:Update()

  if(not Client.ModListIsBeingRefreshed() or self.ModManager ~= SteamWorkshopModManager) then
    return
  end
  
  local count = Client.GetNumMods()
  local new = count-self.LastModCount
  
  if(new == 0) then
    return
  end

  for i=self.LastModCount+1,count do
    self.ModEntryList[i] = i
  end

  self.ModList:ListDataModifed()
  
  self.LastModCount =  count
end

function ModsPage:SetModList(modManager)
 
  local list = {}
  
  self.ModList:SetDataList(list)
  
  if(modManager == "ModLoader" or modManager == "FullModsManager") then
    self.ModManager = _G[modManager]
    
    self.ModList:ChangeItemClass("ModListEntry")
    
    list = self.ModManager:GetModList(true)
    table.sort(list)
    
  elseif(modManager == "SteamWorkshop") then
    self.ModManager = SteamWorkshopModManager
   
    Client.RefreshModList()
    self.LastModCount = 0

    self.ModList:ChangeItemClass("SteamModListEntry")
  end
  
  self.ModEntryList = list
  
  self.ModList:SetDataList(list)
  
end

function ModsPage:EnableAll()
  
  self.ModManager:EnableAllMods()
  self.ModList:ListDataModifed()
end

function ModsPage:DisableAll()
  
  self.ModManager:DisableAllMods() 
  self.ModList:ListDataModifed()
end


SteamWorkshopModManager = SteamWorkshopModManager or {}

function SteamWorkshopModManager:EnableAllMods()
end

function SteamWorkshopModManager:DisableAllMods()
end

function SteamWorkshopModManager:EnableMod(modIndex)
  //Client.ActivateMod(modIndex)
end

function SteamWorkshopModManager:DisableMod(modIndex)
 // Client.ActivateMod(modIndex)
end

function SteamWorkshopModManager:GetModList()

  local list = {}
 
  for i=1,Client.GetNumMods() do
    list[i] = i
  end
  
  return list
end

function SteamWorkshopModManager:GetModInfo(modIndex)
  //disabled, realName, errorValue
  
  //local value1, value2, Client.GetModInfo(modIndex)
  return Client.ModIsActive(modIndex), Client.GetModTitle(modIndex), self.ModStates[Client.GetModState(modIndex)]
end

Event.Hook("LoadComplete", function()
  
  local modStates = {}
  
  SteamWorkshopModManager.ModStates = modStates
  
  modStates[Client.ModVersionState_ErroneousInstall] = "Erroneous Install"
  modStates[Client.ModVersionState_NotInstalled] = "NotInstalled"
  modStates[Client.ModVersionState_OutOfDate] = "Out of date" 
  modStates[Client.ModVersionState_Unknown] = "Unknown"
  modStates[Client.ModVersionState_UnknownInstalled] = "Unknown installed"
  modStates[Client.ModVersionState_Updating] = "Updating"
  modStates[Client.ModVersionState_QueuedForUpdate] = "Queued for update"
  modStates[Client.ModVersionState_UpToDate] = "Uptodate"
end)


function MakeStateNumberToString()
  Client.GetModState()
  
  Client.GetNumMods()
  Client.InstallMod()
  Client.ModDownloadProgress()
  Client.RefreshModList()
  Client.ModListIsBeingRefreshed()
end

if(HotReload) then
  GUIMenuManager:RecreatePage(ModsPage.PageName)
end