
local FriendlyNames = {
  MouseButton0 = "Mouse1",
  MouseButton1 = "Mouse2",
  MouseButton2 = "Mouse3",
  MouseButton3 = "Mouse4",
  MouseButton4 = "Mouse5",
  MouseButton5 = "Mouse6",
  MouseButton6 = "Mouse7",
  MouseButton7 = "Mouse8",
  Grave = "`",
  Num1 = "1",
  Num2 = "2",
  Num3 = "3",
  Num4 = "4",
  Num5 = "5",
  Num6 = "6",
  Num7 = "7",
  Num8 = "8",
  Num9 = "9",
  Num0 = "0",
  LeftBracket = "[",
	RightBracket = "]",
	Comma = ",",
	Period = ".",
	Slash = "/",
	JoystickButton10 = "",
}

HotReload = KeybindListEntry

class 'KeybindListEntry'(BaseControl)

KeybindListEntry.FontSize = 20
KeybindListEntry.KeyNameOffset = 300

function KeybindListEntry:__init(owner, width, height)
  BaseControl.Initialize(self, width, height)

  self.Parent = owner

  self:SetColor(1,1,1,0)

  local name = GUIManager:CreateTextItem()
   name:SetFontSize(self.FontSize)
   name:SetPosition(Vector(38, 0, 0))
   //name:SetAnchor(GUIItem.Left, GUIItem.Center)
   name:SetTextAlignmentX(GUIItem.Align_Min)
   name:SetTextAlignmentY(GUIItem.Align_Min)
  self.KeybindName = name

  local bindModeOverlay = GUIManager:CreateGraphicItem()
    bindModeOverlay:SetSize(Vector(120, 20, 0))
    bindModeOverlay:SetPosition(Vector(self.KeyNameOffset-10, 0, 0))
    bindModeOverlay:SetIsVisible(false)
	  bindModeOverlay:SetColor(Color(0.8666, 0.3843, 0, 1))
  self.BindModeOverlay = bindModeOverlay

  local boundKey = GUIManager:CreateTextItem()
   boundKey:SetPosition(Vector(self.KeyNameOffset, 0, 0))
   boundKey:SetFontSize(self.FontSize)
   //boundKey:SetAnchor(GUIItem.Left, GUIItem.Center)
   boundKey:SetTextAlignmentX(GUIItem.Align_Min)
   boundKey:SetTextAlignmentY(GUIItem.Align_Min)
  self.BoundKey = boundKey
  
  local groupLabel = GUIManager:CreateTextItem()
   groupLabel:SetPosition(Vector(8, 0, 0))
   groupLabel:SetFontSize(self.FontSize)
   groupLabel:SetColor(Color(0.8666, 0.3843, 0, 1))
   groupLabel:SetTextAlignmentX(GUIItem.Align_Min)
   groupLabel:SetTextAlignmentY(GUIItem.Align_Min)
  self.GroupLabel = groupLabel

  self:AddGUIItemChild(name)
  self:AddGUIItemChild(bindModeOverlay)
  self:AddGUIItemChild(boundKey)
  self:AddGUIItemChild(groupLabel)
end

function KeybindListEntry:OnHide()
  if(not self.Hidden) then
    self:Hide()
  end
end

function KeybindListEntry:OnShow()
  if(not self.Hidden) then
    self:Show()
  end
end

function KeybindListEntry:GetRoot()
  return self.RootFrame
end

function KeybindListEntry:SetWidth(width)
  self:SetSize(width, self:GetHeight())
end

//self.SelectBG:SetIsVisible(true)

function KeybindListEntry:OnFocusLost()
  if(self.InBindMode) then
    self:ExitBindingMode()
  end
end

function KeybindListEntry:SendKeyEvent(key, down)

  if(self.InBindMode and down and key ~= InputKey.MouseX and key ~= InputKey.MouseY) then
    self.Parent.Parent:SetKeybind(self.Data[1], key)
    self:ExitBindingMode()

    GetGUIManager():ClearFocus()
    
    return true
  end
end

function KeybindListEntry:OnClick(button, down, x, y)
  
  if(down and button == InputKey.MouseButton0 and not self.Data.Keybinds) then
    
    if(x < 300) then
      return false
    end
    
    if(self.LastClicked and (Client.GetTime()-self.LastClicked) < GUIManager.DblClickSpeed) then
       self.InBindMode = true
       self.BindModeOverlay:SetColor(Color(0.8666, 0.3843, 0, 1))
       self.BindModeOverlay:SetIsVisible(true)
       
       GetGUIManager():SetFocus(self)
      return true
    end
    
    self.LastClicked = Client.GetTime()
  end

  //return false so the listview will select our entry
  return false
end

function KeybindListEntry:ExitBindingMode()
	self.BindModeOverlay:SetIsVisible(false)
	self.InBindMode = false
	
	local keyname = KeyBindInfo:GetBoundKey(self.Data[1]) or ""
	self.BoundKey:SetText(FriendlyNames[keyname] or keyname )
end

function KeybindListEntry:SetData(data)
  if(self.Hidden) then
    self.Background:SetIsVisible(true)
    self.Hidden = nil
  end

  self.Data = data

  self.BindModeOverlay:SetIsVisible(false)

  if(not data.Keybinds) then
    self.KeybindName:SetText(data[2])
   
    local keyname = KeyBindInfo:GetBoundKey(data[1]) or ""
    self.BoundKey:SetText(FriendlyNames[keyname] or keyname )
    
    if(KeyBindInfo.BindConflicts[data[1]]) then
      self.BindModeOverlay:SetColor(Color(1, 0, 0, 1))
      self.BindModeOverlay:SetIsVisible(true)
    end
    
    self.GroupLabel:SetText("")
  else
    self.BoundKey:SetText("")
    self.KeybindName:SetText("")
    self.BindModeOverlay:SetIsVisible(false)
    
    self.GroupLabel:SetText(data.Name)
  end

end

class'KeybindPage'(BasePage)

function KeybindPage:__init()
  BasePage.__init(self, 600, 500, "Keybinds")
  BaseControl.Hide(self)

  assert(KeyBindInfo, "Keybinds mod is not loaded")

  KeyBindInfo:Init(true)

  local keybindList = ListView(500, 400, KeybindListEntry, 20, 4)
    keybindList:SetPoint("Center", 0, -40, "Center")
    keybindList.RootFrame:SetColor(Color(0, 0, 0, 1))
    keybindList:SetDataList(KeyBindInfo:GetBindingDialogTable())
    keybindList:SetScrollBarWidth(23)
    
    self:AddChild(keybindList)
  self.KeybindList = keybindList


  local clearButton = MainMenuPageButton("Clear Key")
    clearButton:SetPoint("BottomLeft", 120, -15, "BottomLeft")
    clearButton.ClickAction = {self.ClearBind, self}
  self:AddChild(clearButton)

/*
  local resetGroupButton = MainMenuPageButton("Reset Group")
    resetGroupButton:SetPoint("BottomLeft", 230, -15, "BottomLeft")
    resetGroupButton.ClickAction = {self.ResetSelectedGroup, self}
  self:AddChild(resetGroupButton)
*/  
  local resetButton = MainMenuPageButton("Reset Keybinds")
    resetButton:SetPoint("BottomLeft", 450, -15, "BottomLeft")
    resetButton.ClickAction = {self.ResetKeybinds, self}
  self:AddChild(resetButton)

  local warningString = GUIManager:CreateTextItem()
   warningString:SetColor(Color(0.3, 0, 0, 1))
   warningString:SetFontSize(25)
   warningString:SetTextAlignmentX(GUIItem.Align_Center)
   warningString:SetPosition(Vector(0, -80, 0))
   warningString:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
   self:AddGUIItemChild(warningString)
  self.WarningString = warningString
end

function KeybindPage:EnterBindMode(item, bindname)
  self.ItemBinding = item
  GetGUIManager():SettingKeybindHook(self.SetKeybind, self)
end

function KeybindPage:SetKeybind(BindName, key)

  if(key ~= InputKey.Escape) then
    key = InputKeyHelper:ConvertToKeyName(key)
    
    local old, isConsoleCmd = KeyBindInfo:GetKeyInfo(key)
    
    if(not KeyBindInfo:IsBindOverrider(BindName) and old and old ~= BindName) then
      self.WarningString:SetText(string.format("%s was unbound", old))
    else
      self.WarningString:SetText("")
    end
    
    KeyBindInfo:SetKeybind(key, BindName, true)
    
    self.KeybindList:ListDataModifed()
  else
    self.WarningString:SetText("")
  end
end

function KeybindPage:ClearBind()
  local bindinfo = self.KeybindList:GetSelectedIndexData()
   
  if(bindinfo and not bindinfo.Keybinds) then
    KeyBindInfo:ClearBind(bindinfo[1])
    
    self.KeybindList:ListDataModifed()
  end
end

function KeybindPage:ResetSelectedGroup()
  
  local bindinfo = self.KeybindList:GetSelectedIndexData()
  
  local OverrideGroup
  
  if(bindinfo) then
    if(bindinfo.Keybinds) then
      OverrideGroup = bindinfo.OverrideGroup and bindinfo.Name
    else
      local key, group, isOverride = KeyBindInfo:GetBindinfo(bindinfo[1])
      
      OverrideGroup = isOverride and group
    end
    
    if(OverrideGroup) then
      KeyBindInfo:ResetOverrideGroup(OverrideGroup)
      self.KeybindList:ListDataModifed()
    else
      self.WarningString:SetText(bindinfo.Name.." is not an override group")
    end
  end
end

function KeybindPage:ResetKeybinds()
  KeyBindInfo:ResetKeybinds()
  
  self.KeybindList:ListDataModifed()
end

function KeybindPage:Show()
  BaseControl.Show(self)
  KeyBindInfo:OnBindingsUIEntered()
end

function KeybindPage:Hide()
  BaseControl.Hide(self)
  
  KeyBindInfo:OnBindingsUIExited()
  
  Client.ReloadKeyOptions()
end

if(HotReload) then
  GUIMenuManager:RecreatePage("Keybinds")
end