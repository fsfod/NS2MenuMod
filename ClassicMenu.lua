
local HotReload = MenuButton2



ControlClass('MenuButton2', BaseControl)
ButtonMixin:Mixin(MenuButton2)

MenuButton2.PaddingX = 13
MenuButton2.PaddingY = 2
MenuButton2.TextOffsetVec = Vector(MenuButton2.PaddingX, MenuButton2.PaddingY, 0)
MenuButton2.FontSize = 21

MenuButton2.BGColor = Color(1, 0, 0, 0)
//MenuEntryFont:SetCenterAlignAndAnchor()
//MenuEntryFont:SetColour(0, 1, 1, 1)

function MenuButton2:Initialize(height, label, action, fontSize)
  
  BaseControl.Initialize(self, 80, height-1)
  
  self:SetColor(self.BGColor)

  local text = self:CreateFontString(MenuButton2.FontSize)
   text:SetPosition(self.TextOffsetVec)
  self.Label = text

  if(label) then
    self.Label:SetText(label)
    self.ClickAction = action 
    
    self:SetSize(self.Label:GetTextWidth(label) + (2*self.PaddingX), self.Size.y)
    
    if(fontSize) then
      text:SetFontSize(fontSize)
    end
  end
end

function MenuButton2:SetData(data)
  self.InfoTable = data

  if(type(data[1]) == "string") then
    self.Label:SetText(data[1])
  else
    self.Label:SetText(data[1](data, self))
  end

  self.ClickAction = data[2]

  self:SetSize(self.Label:GetTextWidth(data[1]) + (2*self.PaddingX), self.Size.y)
end

function MenuButton2:OnEnter()
	self.Label:SetColor(Color(0.8666, 0.3843, 0, 1))
	PlayerUI_PlayButtonEnterSound()
end

function MenuButton2:OnLeave()
	self.Label:SetColor(Color(1, 1, 1, 1))
end

ControlClass('MenuEntry', BaseControl)

MenuEntry.EntryHeight = MenuButton2.FontSize+(2*MenuButton2.PaddingY)

MenuEntry.EntrySpacing = 6
MenuEntry.BGColor = Color(0, 1, 0, 0)

function MenuEntry:Initialize(owner, width, height)
  BaseControl.Initialize(self, width, height)
  self:SetColor(self.BGColor)

  local button = self:CreateControl("MenuButton2", height)
    button:SetPosition(10, 0)
  self:AddChild(button)
  
  self.Button = button
end

function MenuEntry:SetData(data)
  
  if(self.Hidden) then
    self:Show()
  end
  
  if(not data or not data[1] or data == "") then
    self.Button:Hide()
   return
  end
    
  if(self.Button.Hidden) then
    self.Button:Show()
  end
  
  self.Button:SetData(data)
  
end

MainMenuConnectedLinks = {
  {"Return to game", function()
    if(Client.GetIsConnected()) then 
		  MainMenu_ReturnToGame()
		end 
  end},

  {"Disconnect", function()  Shared.ConsoleCommand("disconnect") end},
}

MainMenuLinks = {
  {"Server Browser", function() GUIMenuManager:ShowPage("ServerBrowser") end},

  {"Create Listen Server", function() GUIMenuManager:ShowPage("CreateServer") end},

  {"Options", function() GUIMenuManager:ShowPage("MainOptions") end},
  
  {"Keybinds", function() GUIMenuManager:ShowPage("Keybinds") end},

  {"Mods", function() GUIMenuManager:ShowPage("Mods") end},
  
  {"Exit", function() Client.Exit() end},
}

ControlClass('ClassicMenu', BaseControl)

PageFactory:Mixin(ClassicMenu)

ClassicMenu.ListSetup = {
  Type = "ListView",
  Width = 300,
  MaxVisibleItems = -1, //filled in later
  ItemClass = "MenuEntry",
  ItemHeight = MenuEntry.EntryHeight,
  ItemSpacing = MenuEntry.EntrySpacing,
  ItemsSelectable = false,
}

function ClassicMenu:Initialize(height, width)
  BaseControl.Initialize(self, height, width)
  PageFactory.Initialize(self)

  GUIMenuManager.WindowedModeActive = true

  self:SetColor(0,0,0,0)

  local logo = self:CreateControl("BaseControl", 1024, 301)
    logo:SetTexture("ui/menu/logo.dds")
    logo:SetPoint("Top", 0, 80, "Top")
  self:AddChild(logo)

  self.Logo = logo

  local list = MainMenuLinks
  
  local MenuLinksSetup = self.ListSetup
  MenuLinksSetup.MaxVisibleItems = #list

  local menuEntrys = self:CreateControlFromTable(MenuLinksSetup)
   menuEntrys:SetPoint("BottomLeft", 0, -60, "BottomLeft")
   menuEntrys:SetDataList(list)
   menuEntrys:SetColor(Color(0,0,0,0))
  self.MenuEntrys = menuEntrys
  
  MenuLinksSetup.MaxVisibleItems = #MainMenuConnectedLinks

  local connectedMenu = self:CreateControlFromTable(MenuLinksSetup)
    connectedMenu:SetDataList(MainMenuConnectedLinks)
    connectedMenu:SetPoint("TopLeft", 0, menuEntrys:GetTop()-30, "BottomLeft")
    connectedMenu:SetColor(Color(0,0,0,0))
    if(not Client.GetIsConnected()) then
      connectedMenu:Hide()
    end
    connectedMenu.ParentSizeChanged = function(controlSelf)
      ListView.ParentSizeChanged(controlSelf)
      connectedMenu:SetPoint("TopLeft", 0, menuEntrys:GetTop()-20, "BottomLeft")
    end
  self.ConnectedMenu = connectedMenu

  local switchButton = self:CreateControl("MenuButton2", 30, "Switch To Paged Menu", 
    function()
      GUIMenuManager:SwitchMainMenu("PagedMainMenu")
      GUIMenuManager.WindowedModeActive = false
    end, 14)                                               
   switchButton:SetPoint("BottomLeft", 20, -20)
  self:AddChild(switchButton)
end

function ClassicMenu:OnClientConnected()
  self.ConnectedMenu:Show()
end

function ClassicMenu:OnClientDisconnected()
  self.ConnectedMenu:Hide()
end

function ClassicMenu:OnResolutionChanged(oldX, oldY, width, height)

  self:SetSize(width, height)

  for k,page in pairs(self.Pages) do
    page:OnResolutionChanged()
  end

end

function ClassicMenu:OnPageCreated(name, page)
  page:SetDraggable()
  page:AddFlag(ControlFlags.IsWindow)
  
  page:Show()
  page:SetPoint("Center", 0, 0, "Center")

  page.TraverseChildFirst = true

  GUIMenuManager:AddFrame(page)
end

function ClassicMenu:OnPageDestroy(name, page)
  GUIMenuManager:RemoveFrame(page)
end

function ClassicMenu:SendKeyEvent(key, down, isRepeat)

  if not self.Hidden and down and key == InputKey.Escape and not isRepeat and not GUIMenuManager:IsFocusedSet() then

    if(Client.GetIsConnected()) then
      MainMenu_ReturnToGame()
    else
      GUIMenuManager:TryCloseTopMostWindow()
    end
   return true
  end
  
  return false
end

function ClassicMenu:ShowPage(name)

  local page = self:GetOrCreatePage(name)
  
  if(not page) then
    return
  end

  if(page.Hidden) then
    page:Show()
    page:SetPoint("Center", 0, 0, "Center")
    
    GUIMenuManager:BringWindowToFront(page)
  end

  if(GUIMenuManager:IsOptionPage(name)) then    
    if(self.CurrentOptionPage and self.CurrentOptionPage ~= page)  then
      self.CurrentOptionPage:Hide()
    end

    self.CurrentOptionPage = page
  end
end

function ClassicMenu:DoRecreatePages()
  
  if(self.RecreatePageList) then
    for i,name in ipairs(self.RecreatePageList) do
      GUIMenuManager:ShowPage(name)
    end
    
    self.RecreatePageList = nil
  end
end


if(HotReload) then
  //ClassicMenuMod:SetHooks()
  ClassicMenu.RecreatePageList = GUIMenuManager:GetMenu() and GUIMenuManager:GetMenu():GetActivePages()
  
  GUIMenuManager:RecreateMenu()
  
else
  GUIMenuManager.RegisterCallback(ClassicMenu, "MenuCreated", "DoRecreatePages")
end