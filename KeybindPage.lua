
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

local ModifierKeys ={
  [InputKey.LeftControl] = true,
  [InputKey.RightControl] = true,
  [InputKey.LeftShift] = true,
  [InputKey.RightShift] = true,
} 
  
HotReload = KeybindListEntry

ControlClass("KeybindButton", BaseControl)

KeybindButton.NonActiveColor = Color(0.15,0.15, 0, 0.8)
KeybindButton.BindModeColor = Color(0.8666, 0.3843, 0, 1)
KeybindButton.FontSize = 20

function KeybindButton:Initialize(width, height, keyIndex)
  BaseControl.Initialize(self, width, height)

	self:SetColor(self.NonActiveColor)

  self.KeyIndex = keyIndex

	local boundKey = self:CreateFontString(self.FontSize)
   boundKey:SetPosition(Vector(10, 0, 0))
   boundKey:SetAnchor(GUIItem.Left, GUIItem.Center)
   boundKey:SetTextAlignmentX(GUIItem.Align_Min)
   boundKey:SetTextAlignmentY(GUIItem.Align_Center)
  self.BoundKey = boundKey
end

function KeybindButton:DataSet(data)

  self.Selected = false

  if(data.Keybinds) then
    self:Hide()
   return
  else
    self:Show()
    self:SetColor(self.NonActiveColor)
  end

  GUIMenuManager:ClearFocusIfFrame(self)

  self.BindName = data[1]

  local keyname = KeyBindInfo:GetBoundKey(self.BindName, self.KeyIndex) or ""
  self.BoundKey:SetText(FriendlyNames[keyname] or keyname)
  
  if(KeyBindInfo.BindConflicts[self.BindName] and self.KeyIndex == 1) then
    self:SetColor(Color(1, 0, 0, 1))
  end
end

function KeybindButton:ExitBindingMode()
	self:SetColor(self.NonActiveColor)
	self.InBindMode = false
	self.LastModifer = nil
	
	local keyname = KeyBindInfo:GetBoundKey(self.BindName, self.KeyIndex) or ""
	self.BoundKey:SetText(FriendlyNames[keyname] or keyname )
end


function KeybindButton:OnFocusLost()
  if(self.InBindMode) then
    self:ExitBindingMode()
  end
  
  self.Selected = false
  
  self:SetColor(self.NonActiveColor)
end

local lastModifer

function KeybindButton:SendKeyEvent(key, down, isRepeat)
  
  if(not self.InBindMode or key == InputKey.MouseX or key == InputKey.MouseY or isRepeat) then
    return
  end
  
  if(ModifierKeys[key]) then
    if(down) then
      //cant really bind using 2 modifers
      if(self.LastModifer) then
        self:ExitBindingMode()
      end
      
      self.LastModifer = key
     return
     
    else
      //we set the bind for modifier keys on the up event incase there doing a modifer+key keybind
      down = true
    end
  end
  
  if(not down and key ~= InputKey.MouseZ) then
    return
  end

  if(self.LastModifer and key ~= self.LastModifer) then
    self:SetBind(key, down, self.LastModifer)
  else
    self:SetBind(key, down)
  end

  return true
end

function KeybindButton:SetBind(key, down, modifer)
  
  self.Parent.Parent.Parent:SetKeybind(self.BindName, key, down, self.KeyIndex, modifer)
   
  self:ExitBindingMode()
   
  self:GetGUIManager():ClearFocus()
end

function KeybindButton:OnClick(button, down, x, y)

  if(self.InBindMode and down) then
    self:SetBind(button)
    
    return true
  end

  if(down and button == InputKey.MouseButton0 and not self.Parent.Data.Keybinds) then
    
    if(self.LastClicked and (Client.GetTime()-self.LastClicked) < GUIMenuManager.DblClickSpeed) then
       self.InBindMode = true
       self:SetColor(Color(0.8666, 0.3843, 0, 1))
       
       GUIMenuManager:SetFocus(self)
      return true
    else
      self.Parent.Parent.Parent:SetSelectedButton(self)
    end
    
    self.LastClicked = Client.GetTime()
  end

  //return false so the listview will select our entry
  return false
end

function KeybindButton:SetSelected()
  self.Selected = true
  self:SetColor(ControlGrey2) 
end

function KeybindButton:ClearSelected()
  self.Selected = false
  self:SetColor(self.NonActiveColor)  
end

ControlClass('KeybindListEntry', BaseControl)

KeybindListEntry.FontSize = 24
KeybindListEntry.KeyNameOffset = 300

function KeybindListEntry:Initialize(owner, width, height)
  BaseControl.Initialize(self, width, height)

  self.Parent = owner

  self:SetColor(1,1,1,0)

  local name = self:CreateFontString(self.FontSize)
   name:SetPosition(Vector(28, 0, 0))
   //name:SetAnchor(GUIItem.Left, GUIItem.Center)
   name:SetTextAlignmentX(GUIItem.Align_Min)
   name:SetTextAlignmentY(GUIItem.Align_Min)
  self.KeybindName = name

  local key1 = self:CreateControl("KeybindButton", 190, height, 1)
    key1:SetPosition(Vector(self.KeyNameOffset-10, 0, 0))
    self:AddChild(key1)
  self.Key1 = key1
  
  local key2 = self:CreateControl("KeybindButton", 190, height, 2)
    key2:SetPosition(Vector(self.KeyNameOffset+200, 0, 0))
    self:AddChild(key2)
  self.Key2 = key2

  local groupLabel = self:CreateFontString(self.FontSize)
   groupLabel:SetPosition(Vector(10, 0, 0))
   groupLabel:SetColor(Color(0.8666, 0.3843, 0, 1))
   groupLabel:SetTextAlignmentX(GUIItem.Align_Min)
   groupLabel:SetTextAlignmentY(GUIItem.Align_Min)
  self.GroupLabel = groupLabel
end


function KeybindListEntry:GetRoot()
  return self.RootFrame
end

function KeybindListEntry:SetWidth(width)
  self:SetSize(width, self:GetHeight())
end

function KeybindListEntry:SetData(data)
  if(self.Hidden) then
    self.Background:SetIsVisible(true)
    self.Hidden = nil
  end

  self.Data = data 

  self.Key1:DataSet(data)
  self.Key2:DataSet(data)

  if(not data.Keybinds) then
    self.KeybindName:SetText(data[2])
    self.GroupLabel:SetText("")
  else
    self.KeybindName:SetText("")
    self.GroupLabel:SetText(data.Label or data.Name)
  end

end


ControlClass('KeybindPage', BasePage)

KeybindPage.ListSetup = {
  Width = 750,
  Height = 500,
  ItemHeight = 26,
  ItemSpacing = 4,
  ItemClass = "KeybindListEntry",
  ScrollBarWidth = 23,
  ItemsSelectable = false,
}

function KeybindPage:Initialize()
  BasePage.Initialize(self, 800, 600, "Keybinds")
  BaseControl.Hide(self)

  assert(KeyBindInfo, "Keybinds mod is not loaded")


  KeyBindInfo:Init(true)

  local keybindList = self:CreateControl("ListView", self.ListSetup)
    keybindList:SetPoint("Top", 0, 30, "Top")
    keybindList.RootFrame:SetColor(Color(0, 0, 0, 1))
    keybindList:SetDataList(KeyBindInfo:GetBindingDialogTable())    
    self:AddChild(keybindList)
  self.KeybindList = keybindList

  local clearButton = self:CreateControl("UIButton", "Clear Key")
    clearButton:SetPoint("BottomLeft", 120, -15, "BottomLeft")
    clearButton.ClickAction = {self.ClearBind, self}
    self.ClearButton = clearButton
  self:AddChild(clearButton)

/*
  local resetGroupButton = UIButton("Reset Group")
    resetGroupButton:SetPoint("BottomLeft", 230, -15, "BottomLeft")
    resetGroupButton.ClickAction = {self.ResetSelectedGroup, self}
  self:AddChild(resetGroupButton)
*/
  local resetButton = self:CreateControl("UIButton", "Reset Keybinds")
    resetButton:SetPoint("BottomLeft", 450, -15, "BottomLeft")
    resetButton.ClickAction = {self.ResetKeybinds, self}
  self:AddChild(resetButton)

  local warningString = GUIManager:CreateTextItem()
    warningString:SetFontName("arial")
   warningString:SetColor(Color(0.3, 0, 0, 1))
   warningString:SetFontSize(25)
   warningString:SetTextAlignmentX(GUIItem.Align_Center)
   warningString:SetPosition(Vector(0, -70, 0))
   warningString:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
   self:AddGUIItemChild(warningString)
  self.WarningString = warningString
end

local ModiferKeys = {
  [InputKey.LeftAlt] = "LeftAlt",
  [InputKey.RightAlt] = "RightAlt",
        
  [InputKey.LeftShift] = "LeftShift",
  [InputKey.RightShift] = "RightShift",
        
  [InputKey.LeftControl] = "LeftControl",
  [InputKey.RightControl] = "RightControl",
}

function KeybindPage:SetKeybind(BindName, key, down, keyIndex, modifer)

  local keyNum = key

  if(key ~= InputKey.Escape) then
    key = InputKeyHelper:ConvertToKeyName(key, down)
    
    if(modifer) then
      modifer = InputKeyHelper:ConvertToKeyName(modifer)
    end
    
    local old
    
    if(modifer) then 
      old = KeyBindInfo:SetKeybindWithModifier(key, modifer, BindName, keyIndex)
    else
      old = KeyBindInfo:SetKeybind(key, BindName, keyIndex)
    end
    
    if(old and old ~= BindName) then
      self.WarningString:SetText(string.format("%s was unbound", old))
    else
      self.WarningString:SetText("")
    end
    
    if(KeyBindInfo.EngineProcessed[BindName]) then
      Client.SetOptionString("input/"..BindName, ModiferKeys[keyNum] or key)
    end
    
    self:SetKeybindsChanged()

  end
end

function KeybindPage:SetSelectedButton(button)
  
  if(self.SelectedButton) then
    
    //don't try to selctect a button that
    if(button == self.SelectedButton and button.Selected) then
      return
    end
    
    self.SelectedButton:ClearSelected()
  end
  
  self.SelectedButton = button
  button:SetSelected()
end

function KeybindPage:ClearBind()

  if(self.SelectedButton and self.SelectedButton.Selected) then  
    KeyBindInfo:ClearBind(self.SelectedButton.BindName, self.SelectedButton.KeyIndex)
    self:SetKeybindsChanged()
  end
end

function KeybindPage:SetKeybindsChanged()

  self.KeybindList:ListDataModifed()

  //if(not KeybindMapper) then
    Client.ReloadKeyOptions()
  //end
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

  self:SetKeybindsChanged()
end

function KeybindPage:Show()
  BaseControl.Show(self)
  //KeyBindInfo:OnBindingsUIEntered()
end

function KeybindPage:Hide()
  BaseControl.Hide(self)
  
  //KeyBindInfo:OnBindingsUIExited()
end

if(HotReload) then
  GUIMenuManager:RecreatePage("Keybinds")
end