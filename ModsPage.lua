
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

  local disabled, realName, loadState = ModLoader:GetModInfo(modName)
  
  self.Checked = not disabled
  
  self.ModName = modName
  
  if(loadState < 0) then
    self.ErrorStatus:SetIsVisible(true)
    self.ErrorStatus:SetText((loadState ~= 0 and tostring(loadState) or ""))
  else
    self.ErrorStatus:SetIsVisible(false)
  end
  
  self.ModNameText:SetText(realName)
  self.Button:SetCheckedState(self.Checked)
end

function ModListEntry:GetRoot()
	return self.RootFrame
end

function ModListEntry:OnHide()
	self:Hide()
end

function ModListEntry:OnShow()
	self:Show()
end

function ModListEntry:OnCheckedToggled()
  self.Checked = not self.Checked
  
  if(self.Checked ) then
    ModLoader:EnableMod(self.ModName)
  else
    ModLoader:DisableMod(self.ModName)
  end
  
  return self.Checked
end

ControlClass('ModsPage', BasePage)

ModsPage.PageName = "Mods"

function ModsPage:Initialize()
  BasePage.Initialize(self, 600, 500, self.PageName, "Mods")

  self:Hide()

  local modList = self:CreateControl("ListView", 560, 350, "ModListEntry", 26, 8)
   modList.RootFrame:SetColor(Color(0, 0, 0, 1))
   modList.ItemsSelectable = false
   modList:SetPosition(20, 60)
   modList.ScrollBar:SetWidth(25)
   self:AddChild(modList)
  self.ModList = modList
  
  local list = ModLoader:GetModList(true)
  table.sort(list)
  modList:SetDataList(list)
  
  if(NS2_IO) then
    local openModsFolder = self:CreateControl("UIButton", "Open Mods Folder", 150)
      openModsFolder:SetPoint("BottomLeft", 400, -20, "BottomLeft")
      openModsFolder.ClickAction = NS2_IO.OpenModsFolder
    self:AddChild(openModsFolder)
  end
  
  local enableAll = self:CreateControl("UIButton", "Enable All", 130)
    enableAll:SetPoint("BottomLeft", 30, -20, "BottomLeft")
    enableAll.ClickAction = function()
      ModLoader:EnableAllMods()
      self.ModList:ListDataModifed()
    end
  self:AddChild(enableAll)
  
  local disableAll = self:CreateControl("UIButton", "Disable All", 130)
    disableAll:SetPoint("BottomLeft", 180, -20, "BottomLeft")
    disableAll.ClickAction = function()
      ModLoader:DisableAllMods() 
      self.ModList:ListDataModifed()
    end
  self:AddChild(disableAll)
end

if(HotReload) then
  GUIMenuManager:RecreatePage(ModsPage.PageName)
end