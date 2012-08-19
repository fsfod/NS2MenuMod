
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
  self.ErrorStatus = errorStatus
  
  local modName = self:CreateFontString(22, "Left", height+30, 0)
    modName:SetTextAlignmentY(GUIItem.Align_Center)
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

  local modName = self:CreateFontString(22, "Left", 20, 0)
    modName:SetTextAlignmentY(GUIItem.Align_Center)
  self.ModNameText = modName
  
  local status = self:CreateFontString(22, "Left", 200, 0)
    //status:SetColor(Color(1,0,0,1))
    status:SetTextAlignmentY(GUIItem.Align_Center)
  self.Status = status
  
  local install = self:CreateControl("UIButton", "Reinstall", 80, height)
    //status:SetColor(Color(1,0,0,1))
    install:SetPosition(Vector(550, 0, 0))
    install.ClickAction = {self.InstallMod, self}
    self:AddChild(install)
  self.Install = install
end

function SteamModListEntry:InstallMod()
  
  if(self.ModInfo and type(self.ModInfo) ~= "number") then
    Client.InstallMod(self.ModInfo.ModIndex)
  end
end

function SteamModListEntry:SetData(modInfo)

  self:Show()

  self.ModManager = self.Parent.Parent.ModManager
  
  self.ModInfo = modInfo
 
  if(type(modInfo) == "number") then
    self.ModNameText:SetText("Mod "..modInfo)
    self.Status:SetText("Fetching Mod Details")
    self.Install:Hide()
  else
    self.ModNameText:SetText(modInfo.Name)
    
    local status = SteamModManager:GetModStatus(modInfo.ModIndex)
    
    if(status == "Updating") then
      local downloading, downloadedBytes, totalBytes = Client.GetModDownloadProgress(modInfo.ModIndex)
      
      if(not downloading or totalBytes == 0) then
        status = "Updating %%0(0/?)"
      else
        status = string.format("Updating %i%%(%i/%ikb)", 100*(downloadedBytes/totalBytes), downloadedBytes/1000, totalBytes/1000)
      end
      
    end
    
    if(status == "Not Installed") then
      self.Install:SetLabel("Install")
      self.Install:Show()
    else
      self.Install:Hide()
      //self.Install:SetLabel("Reinstall")
    end
    
    self.Status:SetText(status)
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
      {Label = "Steam Workshop", NameTag = "SteamModManager"},
      {Label = "Internal", NameTag = "ModLoader"},
      {Label = "Raw Mods", NameTag = "FullModsManager"},
    },
  },

  ModList = {
    Type = "ListView",
    Position = Vector(20, 60, 0),
    Width = 660,
    Height = 440,
    ItemHeight = 26,
    ItemSpacing = 8,
    ItemClass = "ModListEntry",
    ItemsSelectable = false,
    ScrollBarWidth = 25,
  },

  EnableAllButton = {
    Type = "UIButton",
    Width = 120,
    Position = {"BottomLeft", 30, -10, "BottomLeft"},
    Label = "Enable All", 
    ClickAction = "EnableAll",
  },
  
  DisableAllButton = {
    Type = "UIButton",
    Width = 120,
    Position = {"BottomLeft", 180, -10, "BottomLeft"},
    Label = "Disable All", 
    ClickAction = "DisableAll",
  },
  
  RefreshButton = {
    Type = "UIButton",
    Width = 120,
    Position = {"BottomLeft", 340, -10, "BottomLeft"},
    Label = "Refresh", 
    ClickAction = "RefreshModList"
  },
  
  UnsubscribeButton = {
    Type = "UIButton",
    Width = 130,
    Position = {"BottomRight", -40, -56, "BottomRight"},
    Label = "Unsubscribe Mod", 
    ClickAction = "UnsubscribeMod"
  },
  
}

function ModsPage:Initialize()
  BasePage.Initialize(self, 700, 600, self.PageName, "Mods")

  self:Hide()
  self:CreatChildControlsFromTable(self.ControlSetup)

  self.ModList:SetColor(Color(0, 0, 0, 1))

  local openModsFolder = self:CreateControl("UIButton", "Open Steamworks Folder", 190)
    openModsFolder:SetPoint("BottomLeft", 490, -10, "BottomLeft")
    openModsFolder.ClickAction = {self.OpenFolder, self}
  self:AddChild(openModsFolder)
  
  self.OpneFolder = openModsFolder
  
  
  self:SetModList("ModLoader")
end

function ModsPage:OpenFolder()
  OpenSteamWorkshopFolder()
end

function ModsPage:TabClicked(tab)  
  self:SetModList(tab.NameTag)
end

function ModsPage:Update()

  if(self.ModManager ~= SteamModManager) then
    return
  end
  
  local selected = self.ModList:GetSelectedIndexData()
  
  local newEntrys = SteamModManager:CheckGetNewEntrys(self.ModEntryList)
  
  local fetched = SteamModManager:GetNewModDetailsFetched()
  
  if(fetched) then
    for modIndex, modEntry in pairs(fetched) do
      self.ModEntryList[modIndex] = modEntry
    end
  end
  
  local downloadsActive = true
  
  if(Shared.GetBuildNumber() > 210) then
    downloadsActive = Client.GetModDownloadProgress()
  end
  
  local listChanged = false
  
  if(newEntrys) then
    self.ModList:ListDataModifed()
    listChanged = true
  elseif(fetched or downloadsActive or self.DownloadsActive or Client.ModListIsBeingRefreshed()) then
    //we trigger one last update after a mod has finshed download otherwise the list item still be left showing 99% downloaded
    self.ModList:RefreshItems()
    listChanged = true
  end

  if(selected and listChanged) then
    if(type(selected) == "number") then
      selected = self.ModEntryList[selected]
    end
    
    self.ModList:SetSelectedListEntry(selected)
  end

  //
  self.DownloadsActive = downloadsActive
end

function ModsPage:SetModList(modManager)
 
  local list = {}
  
  if(modManager == "ModLoader" or modManager == "FullModsManager") then
    
    self.ModManager = _G[modManager]
    self.ModList:ChangeItemClass("ModListEntry", true)
    
    self.EnableAllButton:Show()
    self.DisableAllButton:Show()
    self.UnsubscribeButton:Hide()
    
  elseif(modManager == "SteamModManager") then
    
    self.ModManager = SteamModManager
    self.ModList:ChangeItemClass("SteamModListEntry", true)
    
    self.EnableAllButton:Hide()
    self.DisableAllButton:Hide()
    self.UnsubscribeButton:Show()
  end
  
  self.ModList:SetDataList(list)

  self.ModList:SetItemsSelectable(modManager == "SteamModManager")

  self:RefreshModList(true)
end

function ModsPage:RefreshModList(managerSwitched)

  if(managerSwitched ~= true and self.ModManager == ModLoader) then
    //no support for refreshing modloader yet
    return
  end
  
  if(self.ModManager == SteamModManager and Client.GetNumModsInDownloadQueue() > 0) then
    //dont refresh while prevent crash 
    //return
  end

  local list
  local modManager = self.ModManager

  if(modManager.RefreshModList) then
    modManager:RefreshModList()
  end
  
  if(modManager == SteamModManager) then
    list = {}
  else
  
    list = modManager:GetModList(true)
    table.sort(list)
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

function ModsPage:UnsubscribeMod()
  
  local entry = self.ModList:GetSelectedIndexData()
  
  if(entry) then
    Client.SubscribeToMod((type(entry) == "number" and entry) or entry.ModIndex, false)
    self:RefreshModList()
  end
end


SteamModManager = SteamModManager or {
}

function SteamModManager:EnableAllMods()
end

function SteamModManager:DisableAllMods()
end

function SteamModManager:EnableMod(modIndex)
  //Client.ActivateMod(modIndex)
end

function SteamModManager:DisableMod(modIndex)
 // Client.ActivateMod(modIndex)
end

function SteamModManager:RefreshModList()
  Client.RefreshModList()
  
  self.ModsUpdating = {}
  self.ModEntrys = {}
  self.LastModCount = 0
  
  self.ActiveFetchs = {}
end

function SteamModManager:CheckGetNewEntrys(modList)

  local count = Client.GetNumMods()
  local new = count-self.LastModCount
  
  if(new == 0) then
    return nil
  end

  modList = modList or {}

  for i=self.LastModCount+1,count do
    self.ActiveFetchs[i] = true
    table.insert(modList, i)
  end
  
  self.LastModCount = count

  return modList
end

function SteamModManager:ModDetailsBeingFetched()
  return next(self.ActiveFetchs) ~= nil
end

function SteamModManager:UnsubscribeMod(modIndex)
  Client.SubscribeToMod(modIndex, false)
  self:RefreshModList()
end

function SteamModManager:CheckStateChanges()
  
  local changed = false
  
  for i=1,Client.GetNumMods() do
    
    local entry = self.ModEntrys[i] 
    
    if(entry) then
      local state = self.ModStates[Client.GetModState(i)]
      
      if(entry.State ~= state) then
        entry.State = state
        changed = true
      end
    end
  end

  return changed
end
  
function SteamModManager:BuildEntry(modIndex)

  local state = Client.GetModState(modIndex)
 
  if(state == Client.ModVersionState_Updating or state == Client.ModVersionState_QueuedForUpdate) then
    self.ModsUpdating[modIndex] = true

    state = state
  end

  local entry = {
    ModIndex = modIndex,
    Name = Client.GetModTitle(modIndex), 
    State = self.ModStates[state],
    ModKind = Client.GetModKind(modIndex), 
  }

  self.ModEntrys[modIndex] = entry
  
  return entry
end

function SteamModManager:GetNewModDetailsFetched()

  local fetched

  for modIndex,_ in pairs(self.ActiveFetchs) do
    
    if(Client.ModDetailsAreKnown(modIndex)) then
      self.ActiveFetchs[modIndex] = nil
      fetched = fetched or {}

      fetched[modIndex] = self:BuildEntry(modIndex)
    end
  end

  return fetched
end

function SteamModManager:GetModList()

  local list = {}
 
  for i=1,Client.GetNumMods() do
    list[i] = self.ModEntrys[i] or i
  end
  
  return list
end

function SteamModManager:GetModInfo(modIndex)
  //disabled, realName, errorValue
  
  //local value1, value2, Client.GetModInfo(modIndex)
  return Client.ModIsActive(modIndex), Client.GetModTitle(modIndex), self.ModStates[Client.GetModState(modIndex)]
end

function SteamModManager:GetModStatus(modIndex)
  return self.ModStates[Client.GetModState(modIndex)]
end

Event.Hook("LoadComplete", function()
  
  local modStates = {}
  
  SteamModManager.ModStates = modStates
  
  modStates[Client.ModVersionState_ErroneousInstall] = "Erroneous Install"
  modStates[Client.ModVersionState_NotInstalled] = "Not Installed"
  modStates[Client.ModVersionState_OutOfDate] = "Out of Date" 
  modStates[Client.ModVersionState_Unknown] = "Unknown"
  modStates[Client.ModVersionState_UnknownInstalled] = "Unknown Installed"
  modStates[Client.ModVersionState_Updating] = "Updating"
  modStates[Client.ModVersionState_QueuedForUpdate] = "Queued for Update"
  modStates[Client.ModVersionState_UpToDate] = "Up to Date"
  
  local kind = {
    [Client.ModKind_Cosmetic] = "Cosmetic",
    [Client.ModKind_Game] = "Game",
    [Client.ModKind_Gameplay] = "Gameplay",
    [Client.ModKind_Level] = "Map",
    [Client.ModKind_Server] = "Server",
    [Client.ModKind_Unknown] = "Unknown",
  }
  
  SteamModManager.ModKind = kind
end)


function MakeStateNumberToString()
  Client.GetModState()
  
  Client.GetNumMods()
  Client.InstallMod()
  Client.ModDownloadProgress()
  Client.RefreshModList()
  Client.ModListIsBeingRefreshed()
  Client.GetNumModsInDownloadQueue()
  Client.GetNameOfDownloadingMod()
end

if(HotReload) then
  GUIMenuManager:RecreatePage(ModsPage.PageName)
end