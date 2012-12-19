
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
  
  local errorStatus = self:CreateFontString(20, "Left", 2, 0)
    errorStatus:SetColor(Color(1,0,0,1))
    errorStatus:SetTextAlignmentY(GUIItem.Align_Center)
  self.ErrorStatus = errorStatus
  
  local modName = self:CreateFontString(20, "Left", height+30, 0)
    modName:SetTextAlignmentY(GUIItem.Align_Center)
  self.ModNameText = modName
end

function ModListEntry:SetData(modName)

  self:Show()

  self.ModManager = self.Parent.Parent.ModManager

  local disabled, realName, errorValue = self.ModManager:GetModInfo(modName)
  
  self.Checked = not disabled
  
  self.ModName = modName
  
  if(errorValue < 0) then
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

SteamModListEntry.Layout = {
    
  Enabled = {
    Type = "CheckBox",
    Position = Vector(22, 0, 0),
    CheckChanged = function(checked, self)
      SteamModManager:SetModEnabled(self.Parent.ModInfo.ModIndex, checked)
    end,
    Label = "",
    Height = 22,
  },
  
  ModName = {
    Type = "Text",
    Position = Vector(60, 0, 0),
    FontSize = 22,
    Width = 260,
  },
 
  Status = {
    Type = "Text",
    Position = {"Left", 340, 0},
    FontSize = 22,
  },
  
  Active = {
    Type = "Text",
    Position = {"Left", 500, 0},
    FontSize = 22,
  },
  
  Subscribed = {
    Type = "Text",
    Position = {"Left", 630, 0},
    FontSize = 22,
  },  
}

function SteamModListEntry:Initialize(listview, width, height)

  BaseControl.Initialize(self, width, height)
  self.Parent = listview

  self:SetColor(Color(0,0,0,0))

  self:CreatChildControlsFromTable(self.Layout)

  //self.ModName:SetTextAlignmentY(GUIItem.Align_Center)
  //self.Status:SetTextAlignmentY(GUIItem.Align_Center)
end

function SteamModListEntry:SetData(modInfo)

  self:Show()

  self.ModManager = self.Parent.Parent.ModManager
  
  self.ModInfo = modInfo
 
  if(type(modInfo) == "number") then
    self.ModName:SetText("Mod "..modInfo)
    self.Status:SetText("Fetching Mod Details")
    self.Enabled:Hide()
    self.Active:SetText("")
    self.Subscribed:SetText("")
  else
    self.ModName:SetText(modInfo.Name)
    
    local modIndex = modInfo.ModIndex
    
    self.Enabled:Show()
    self.Enabled:SetChecked(Client.GetIsModActive(modIndex))
    
    local status = Client.GetModState(modIndex)
    
    if(status == "downloading") then
      status = SteamModManager:GetPrettyModUpdateProgress(modIndex)
      self.Active:SetText("")
      self.Subscribed:SetText("")
    else
      self.Active:SetText((SteamModManager:GetIsModActive(modIndex) and "Active") or "Not Active")
      self.Subscribed:SetText((Client.GetIsSubscribedToMod(modIndex) and "Subscribed") or "Not Subscribed")
    end
    
    //just leave the status blank if its not intresting
    if(status == "available") then
      status = ""
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
    ActiveTab = "SteamModManager",
    TabList = {
      {Label = "Steam Workshop", NameTag = "SteamModManager"},
      {Label = "Internal", NameTag = "ModLoader"},
    },
  },

  ModList = {
    Type = "ListView",
    Position = {"TopLeft", 20, 60},
    Point2 = {"BottomRight", -20, -120},
   // Width = 660,
    //Height = 440,
    ItemHeight = 20,
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
  
  RestartButton = {
    Type = "UIButton",
    Width = 130,
    Position = {"BottomRight", -200, -56, "BottomRight"},
    Label = "Restart", 
    ClickAction = function() Client.RestartMain() end
  },
}

function ModsPage:Initialize()
  BasePage.Initialize(self, 800, 600, self.PageName, "Mods")

  self:Hide()
  self:CreatChildControlsFromTable(self.ControlSetup)

  self.ModList:SetColor(Color(0, 0, 0, 1))

  local openModsFolder = self:CreateControl("UIButton", "Open Steamworks Folder", 190)
    openModsFolder:SetPoint("BottomLeft", 490, -10, "BottomLeft")
    openModsFolder.ClickAction = {self.OpenFolder, self}
  self:AddChild(openModsFolder)
  
  self.OpneFolder = openModsFolder
  
  
  self:SetModList("SteamModManager")
end

function ModsPage:OpenFolder()
  OpenSteamWorkshopFolder()
end

function ModsPage:TabClicked(tab)  
  self:SetModList(tab.NameTag)
end


function ModsPage:Update()

  SteamModManager:UpdateDownloadRates()

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
  
  if(modManager == "ModLoader") then
    
    self.ModManager = _G[modManager]
    self.ModList:ChangeItemClass("ModListEntry", true)
    
    self.UnsubscribeButton:Hide()
    
  elseif(modManager == "SteamModManager") then
    
    self.ModManager = SteamModManager
    self.ModList:ChangeItemClass("SteamModListEntry", true)
    //disable the UnsubscribeButton until Client.SubscribeToMod works again
    self.UnsubscribeButton:Hide()
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
  
  //if(self.ModManager == SteamModManager and Client.GetNumModsInDownloadQueue() > 0) then
    //dont refresh while prevent crash 
    //return
  //end

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
  ModsUpdating = {},
  ModEntrys = {},
  LastModCount = 0,
  ActiveFetchs = {},
  ModNameLookup = {},
  ActiveAtStartup = {},
}

SteamModManager.ModStates ={
  getting_info    = "GETTING INFO",
  downloading     = "DOWNLOADING",
  unavailable     = "UNAVAILABLE",
  available       = "AVAILABLE",
}

function SteamModManager:EnableAllMods()
  for id=1,Client.GetNumMods() do
    SafeCall(Client.SetModActive, id, true)
  end
end

function SteamModManager:DisableAllMods()
  for id=1,Client.GetNumMods() do
    SafeCall(Client.SetModActive, id, false)
  end
end

//returns weather a mod is active even it was changed to disabled this session
function SteamModManager:GetIsModActive(modIndex)

  local entry = self.ModEntrys[modIndex] 
    
  if(entry) then
    return self.ActiveAtStartup[entry.Name] == true
  end
  
  return false
end

function SteamModManager:SetModEnabled(modIndex, enabled)
  Client.SetModActive(modIndex, enabled)
end

function SteamModManager:EnableMod(modIndex)
  Client.SetModActive(modIndex, true)
end

function SteamModManager:DisableMod(modIndex)
  Client.SetModActive(modIndex, false)
end

function SteamModManager:RefreshModList()
  Client.RefreshModList()
  
  self.ModsUpdating = {}
  self.ModEntrys = {}
  self.LastModCount = 0
  
  self.ActiveFetchs = {}
  self.ModNameLookup = {}
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

function SteamModManager:GetEstimatedUpdateTime()
  
  for index,entry in pairs(self.ModsUpdating) do
    
  end
end

function SteamModManager:GetModDownloadTimeLeft(modIndex)
  
  local modinfo = self.ModEntrys[modIndex]
  
  if(not modinfo) then
    error("GetModDownloadTimeLeft: Error no mod with that index")
  end
  
  local downloading, downloadedBytes, totalBytes = Client.GetModDownloadProgress(modIndex)
  
  if(not downloading) then
    return 0
  end
  
  local rate = modInfo.DownloadRate
  
  return (totalBytes-downloadedBytes)/rate
end

function SteamModManager:GetPrettyModUpdateProgress(modIndex)
  assert(type(modIndex) == "number")

  local modInfo = self.ModEntrys[modIndex]
  
  if(not modInfo) then
    error("GetModDownloadProgress: Error no mod with that index")
  end
  
  local downloading, downloadedBytes, totalBytes = Client.GetModDownloadProgress(modIndex)
  
  if(not downloading) then
    return "Queued For Download"
  elseif(totalBytes == 0) then
    return "Download Complete"
  elseif(downloadedBytes == 0) then
    return "Download Starting"
  end
  
  local rate = modInfo.DownloadRate
  
  if(rate) then
    rate = rate/1000
  else
    rate = 0
  end
  
  local fmtString, downloaded, total
  
  if(totalBytes > 1000000) then
    downloaded, total = downloadedBytes/1000000, totalBytes/1000000
    fmtString = "Updating %.1f%%(%.3f/%.2fMB) %.2fKBs"
  else
    downloaded, total = downloadedBytes/1000, totalBytes/1000
    fmtString = "Updating %.1f%%(%.1f/%.1fMB) %.2fKBs"
  end
        
  return string.format(fmtString, 100*(downloadedBytes/totalBytes), downloaded, total, rate)
end

local MaxDownloadRateEntrys = 30
local MinRateInterval = 0.2

function SteamModManager:UpdateDownloadRates()
  
  for index,entry in pairs(self.ModsUpdating) do
    local downloading, downloadedBytes, totalBytes = Client.GetModDownloadProgress(index)
    
    if(downloading) then
      local t

      if(entry.LastDownloadCheck) then
        
        t = Client.GetTime()-entry.LastDownloadCheck
        
        if(t > MinRateInterval) then
          local rate = (downloadedBytes-entry.LastDownloadAmount)/t
          
          local rateCount = entry.DownloadRateCount
          
          local index = rateCount%MaxDownloadRateEntrys
          
          entry.DownloadRatesTotal = entry.DownloadRatesTotal+(rate - (entry.DownloadRates[index] or 0))
          entry.DownloadRates[index] = rate
          
          entry.DownloadRate = entry.DownloadRatesTotal/math.min(rateCount, MaxDownloadRateEntrys)
          entry.DownloadRateCount = entry.DownloadRateCount+1
        end
      else
        entry.DownloadRateCount = 0
        entry.DownloadRatesTotal = 0
        entry.DownloadRates = {[0] = 0, 0}
        entry.DownloadSize = totalBytes
      end

      if(not t or t > MinRateInterval) then
        entry.LastDownloadAmount = downloadedBytes
        entry.LastDownloadCheck = Client.GetTime()
      end
    else
      self.ModsUpdating[index] = nil
    end
  end
end

function SteamModManager:BuildEntry(modIndex)

  local state = Client.GetModState(modIndex)
 
  local name = Client.GetModTitle(modIndex)

  local entry = {
    ModIndex = modIndex,
    Name = name, 
    State = self.ModStates[state],
    StartupState = state,
    //ModKind = Client.GetModKind(modIndex), 
  }  
  
  if(not self.ActiveAtStartup[name]) then
    self.ActiveAtStartup[name] = Client.GetIsModActive(modIndex)
  end
  
  self.ModNameLookup[name] = modIndex
  
  if(state == "downloading") then
    self.ModsUpdating[modIndex] = entry
  end

  self.ModEntrys[modIndex] = entry
  
  return entry
end

function SteamModManager:GetNewModDetailsFetched()

  local fetched

  for modIndex,_ in pairs(self.ActiveFetchs) do
    
    if(Client.GetModState(modIndex) ~= "getting_info") then
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

//name passed in is case senstive
function SteamModManager:GetModIdForModName(modName)
  
  local modIndex = self.ModNameLookup[modName]
  
  if(not modIndex) then
    return nil
  end
  
  local name = Client.GetModTitle(modIndex)
  
  if(not name or name ~= modName) then
    return nil
  end
  
  return modIndex
end

function SteamModManager:GetModInfo(modIndex)
  //disabled, realName, errorValue
  
  //local value1, value2, Client.GetModInfo(modIndex)
  return Client.ModIsActive(modIndex), Client.GetModTitle(modIndex), self.ModStates[Client.GetModState(modIndex)]
end

function SteamModManager:GetModStatus(modIndex)
  local state = Client.GetModState(modIndex)
  
  return (state and self.ModStates[state]) or "??"
end

Event.Hook("LoadComplete", function()
  
  local modStates = {}

 // modStates[Client.ModVersionState_ErroneousInstall] = "Erroneous Install"
//  modStates[Client.ModVersionState_NotInstalled] = "Not Installed"
//  modStates[Client.ModVersionState_OutOfDate] = "Out of Date" 
//  modStates[Client.ModVersionState_Unknown] = "Unknown"
//  modStates[Client.ModVersionState_UnknownInstalled] = "Unknown Installed"
//  modStates[Client.ModVersionState_Updating] = "Updating"
 // modStates[Client.ModVersionState_QueuedForUpdate] = "Queued for Update"
 // modStates[Client.ModVersionState_UpToDate] = "Up to Date"
  
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