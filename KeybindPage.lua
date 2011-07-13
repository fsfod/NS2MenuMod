
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

class 'KeybindListEntry'(BaseControl)

KeybindListEntry.FontSize = 20
KeybindListEntry.KeyNameOffset = 300

function KeybindListEntry:__init(owner)
  BaseControl.Initialize(self, 200, 20)

  self.Parent = owner

  self:SetColor(1,1,1,0)

  local name = GUIManager:CreateTextItem()
   name:SetFontSize(self.FontSize)
   name:SetPosition(Vector(30, 0, 0))
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
   groupLabel:SetPosition(Vector(0, 0, 0))
   groupLabel:SetFontSize(self.FontSize)
   groupLabel:SetColor(Color(0.8666, 0.3843, 0, 1))
   groupLabel:SetTextAlignmentX(GUIItem.Align_Min)
   groupLabel:SetTextAlignmentY(GUIItem.Align_Min)
  self.GroupLabel = groupLabel

  self.RootFrame:AddChild(name)
  self.RootFrame:AddChild(bindModeOverlay)
  self.RootFrame:AddChild(boundKey)
  self.RootFrame:AddChild(groupLabel)
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

function KeybindListEntry:SetPos(x,y)
  self:SetPosition(x,y)
end

function KeybindListEntry:GetRoot()
  return self.RootFrame
end

function KeybindListEntry:SetWidth(width)
  self:SetSize(width, self:GetHeight())
end

//self.SelectBG:SetIsVisible(true)

function KeybindListEntry:OnClick(button, down, x, y)
  
  if(down and button == InputKey.MouseButton0 and not self.Data.Keybinds) then
    
    if(x < 300) then
      return
    end
    
    if(self.LastClicked and (Client.GetTime()-self.LastClicked) < MouseTracker.DblClickSpeed) then
       self.BindModeOverlay:SetColor(Color(0.8666, 0.3843, 0, 1))
       self.BindModeOverlay:SetIsVisible(true)
       
       self.Parent.Parent:EnterBindMode(self, self.Data[1])
    end
    
    self.LastClicked = Client.GetTime()
  end
end

function KeybindListEntry:ExitBindingMode()
	self.BindModeOverlay:SetIsVisible(false)
	
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

class'KeybindPage'(BaseControl)

function KeybindPage:__init()

  BaseControl.Initialize(self, 540, 500)

  self.RootFrame:SetColor(Color(0.1, 0.1, 0.1,0.3))

  KeyBindInfo:Init(true)

  local keybindList = ListView(500, 350, KeybindListEntry, 20, 4)
    keybindList:SetPosition(20, 60)
    keybindList.RootFrame:SetColor(Color(0, 0, 0, 1))
    keybindList:SetDataList(KeyBindInfo:GetBindingDialogTable())
    keybindList:SetScrollBarWidth(23)
    
    self:AddChild(keybindList)
  self.KeybindList = keybindList

  local backButton = MainMenuPageButton("Back to menu")
    backButton:SetPoint("BottomLeft", 20, -15, "BottomLeft")
    backButton.ClickAction = function() self.Parent:ReturnToMainPage() end
  self:AddChild(backButton)
  
  local resetButton = MainMenuPageButton("Reset Keybinds")
    resetButton:SetPoint("BottomLeft", 200, -15, "BottomLeft")
    resetButton.ClickAction = {self.ResetKeybinds, self}
  self:AddChild(resetButton)
  
  local clearButton = MainMenuPageButton("Clear Key")
    clearButton:SetPoint("BottomLeft", 350, -15, "BottomLeft")
    clearButton.ClickAction = {self.ClearBind, self}
  self:AddChild(clearButton)
  
  local warningString = GUIManager:CreateTextItem()
   warningString:SetColor(Color(0.3, 0, 0, 1))
   warningString:SetFontSize(25)
   //warningString:SetText("bind % that was set to key % was unbound")
   warningString:SetTextAlignmentX(GUIItem.Align_Center)
   warningString:SetPosition(Vector(0, -80, 0))
   warningString:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
   self.RootFrame:AddChild(warningString)
  self.WarningString = warningString
end

function KeybindPage:EnterBindMode(item, bindname)
  self.ItemBinding = item
  MouseTracker:SettingKeybindHook(self.SetKeybind, self)
end

function KeybindPage:SetKeybind(key)

  if(key ~= InputKey.Escape) then
    local BindName = self.ItemBinding.Data[1]
    key = InputKeyHelper:ConvertToKeyName(key)
    
    local old, isConsoleCmd = KeyBindInfo:GetKeyInfo(key)
    
    if(old and old ~= BindName) then
      self.WarningString:SetText(string.format("%s was unbound", old))
    else
      self.WarningString:SetText("")
    end
    
    KeyBindInfo:SetKeybind(key, self.ItemBinding.Data[1], true)
    
    self.KeybindList:ListDataModifed()
  else
    self.WarningString:SetText("")
  end

  self.ItemBinding:ExitBindingMode()

  self.ItemBinding = nil
end

function KeybindPage:ClearBind()
  local bindinfo = self.KeybindList:GetSelectedIndexData()
   
  if(bindinfo and not bindinfo.Keybinds) then
    KeyBindInfo:ClearBind(bindinfo[1])
    
    self.KeybindList:ListDataModifed()
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
  
  //Client.ReloadKeyOptions()
end
