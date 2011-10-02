
local HotReload = MenuButton



class'MenuButton'(BaseControl)
ButtonMixin:Mixin(MenuButton)

MenuButton.PaddingX = 13
MenuButton.PaddingY = 1
MenuButton.TextOffsetVec = Vector(MenuButton.PaddingX, MenuButton.PaddingY, 0)
MenuButton.FontSize = 21


local MenuEntryFont = FontTemplate(MenuButton.FontSize)
//MenuEntryFont:SetCenterAlignAndAnchor()
//MenuEntryFont:SetColour(0, 1, 1, 1)

function MenuButton:__init(height, label, action, fontSize)
  
  BaseControl.__init(self, 80, height-1)
  
  self:SetColor(Color(0,1, 0, 0))
  
  local text = MenuEntryFont:CreateFontString()
   text:SetPosition(self.TextOffsetVec)
   self:AddGUIItemChild(text)
  self.Label = text

  if(label) then
    self.Label:SetText(label)
    self.ClickAction = action 
    
    self:SetWidth(self.Label:GetTextWidth(label) + (2*self.PaddingX))
    
    if(fontSize) then
      text:SetFontSize(fontSize)
    end
  end
end

function MenuButton:SetData(data)
  self.InfoTable = data

  self.Label:SetText(data[1])
  self.ClickAction = data[2]

  self:SetWidth(self.Label:GetTextWidth(data[1]) + (2*self.PaddingX))
end

function MenuButton:OnEnter()
	self.Label:SetColor(Color(0.8666, 0.3843, 0, 1))
	Shared.PlaySound(nil, "sound/ns2.fev/common/button_enter")
end

function MenuButton:OnLeave()
	self.Label:SetColor(Color(1, 1, 1, 1))
end

class'MenuEntry'(BaseControl)

MenuEntry.EntryHeight = MenuButton.FontSize+(2*MenuButton.PaddingY)

MenuEntry.EntrySpacing = 6

function MenuEntry:__init(owner, width, height)
  BaseControl.__init(self, width, height)
  self:SetColor(Color(0, 0, 0, 0))

  local button = MenuButton(height)
    button:SetPoint("Left", 10, 0, "Left")
  self:AddChild(button)
  
  self.Button = button
end

function MenuEntry:SetData(data)
  
  if(self.Hidden) then
    self:Show()
  end
  
  self.Button:SetData(data)
end

function MenuEntry:OnHide()
  self:Hide()
end

function MenuEntry:OnShow()
  self:Show()
end

class'MenuLinkList'(BaseControl)

MenuLinkList.ItemHeight = MenuButton.FontSize+(MenuButton.PaddingY*2)
MenuLinkList.ItemSpacing = 8

function MenuLinkList:__init(menuEntrys)
 
  local itemSpacing = self.ItemSpacing+self.ItemHeight

  BaseControl.Initialize(self, 300, #menuEntrys*itemSpacing)
  
  self.Buttons = {}
  self.NameToButton = {}

  self:SetColor(1, 0, 0, 0)

  local newWidth = 0

  for i,entry in ipairs(menuEntrys) do
    local button = MenuEntry(entry)
      button:SetPosition(0, (i-1)*itemSpacing)      
     self:AddChild(button)

    local width = button:GetWidth()

    if(width > newWidth) then
      newWidth = width
    end
      
    self.Buttons[#self.Buttons+1] = button
  end

  self:SetWidth(newWidth)
end

MainMenuConnectedLinks = {
  {"Return to game", function()
    if(Client.GetIsConnected()) then 
		  MainMenu_ReturnToGame()
		end 
  end},

  {"Disconnect", function()  Client.ConsoleCommand("disconnect") end},
}

MainMenuLinks = {
  {"Server Browser", function() GUIMenuManager:ShowPage("ServerBrowser") end},

  {"Create Listen Server", function() GUIMenuManager:ShowPage("CreateServer") end},

  {"Options", function() GUIMenuManager:ShowPage("MainOptions") end},
  
  {"Keybinds", function() GUIMenuManager:ShowPage("Keybinds") end},

  {"Mods", function() GUIMenuManager:ShowPage("Mods") end},
   
  //{"Recreate Menu", function() GUIMenuManager:RecreateMenu() end},
  
  /*{"Switch To Paged Menu", 
    function()
      GUIMenuManager:SwitchMainMenu("PagedMainMenu")
      GUIMenuManager.WindowedModeActive = false
    end
  },*/
  
  {"Exit", function() Client.Exit() end},
}

class'ClassicMenu'(BaseControl)

PageFactory:Mixin(ClassicMenu)

function ClassicMenu:__init(height, width)
  BaseControl.Initialize(self, height, width)
  PageFactory.__init(self)

  GUIMenuManager.WindowedModeActive = true

  self:SetColor(0,0,0,0)

  local logo = BaseControl(717, 158)
    logo:SetTexture("ui/logo.dds")
    logo:SetPoint("Top", 0, 80, "Top")
  self:AddChild(logo)

  self.Logo = logo

  local optionsMenu = OptionsPageSelector()
    //optionsMenu:Hide()
    self:AddChild(optionsMenu)
  self.OptionsMenu = optionsMenu

  local list = MainMenuLinks
  
  local entryClass = MenuEntry

  local menuEntrys = ListView(300, #list*(MenuEntry.EntryHeight+MenuEntry.EntrySpacing), MenuEntry, MenuEntry.EntryHeight, MenuEntry.EntrySpacing)//MenuLinkList(list)
   menuEntrys:SetPoint("BottomLeft", 0, -60, "BottomLeft")
   menuEntrys:SetDataList(list)
   menuEntrys:SetColor(Color(0,0,0,0))
   menuEntrys.ItemsSelectable = false
   self:AddChild(menuEntrys)
  self.MenuEntrys = menuEntrys

  local connectedMenu = ListView(300, #MainMenuConnectedLinks*(MenuEntry.EntryHeight+MenuEntry.EntrySpacing), MenuEntry, MenuEntry.EntryHeight, MenuEntry.EntrySpacing)
    connectedMenu:SetDataList(MainMenuConnectedLinks)
    connectedMenu:SetPoint("TopLeft", 0, menuEntrys:GetTop()-50, "BottomLeft")
    connectedMenu:SetColor(Color(0,0,0,0))
    connectedMenu.ItemsSelectable = false
    if(not Client.GetIsConnected()) then
      connectedMenu:Hide()
    end
  self:AddChild(connectedMenu)
  self.ConnectedMenu = connectedMenu
  
  local switchButton = MenuButton(15, "Switch To Paged Menu", 
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
    page:UpdatePosition()
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
    
    if(not GUIMenuManager:TryCloseTopMostWindow() and Client.GetIsConnected()) then
      MainMenu_ReturnToGame()
    end
   return true
  end
  
  return false
end

function ClassicMenu:CloseTopPage()
  
  local highest, windowZ = nil, 0
  
  for k, page in pairs(self.Pages) do   
    if(not page.Hidden and page.WindowZ > windowZ) then
      highest = page
      windowZ = page.WindowZ
    end
  end

  if(highest) then
    SafeCall(highest.Close, highest)
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

if(HotReload) then
  //ClassicMenuMod:SetHooks()
  GUIMenuManager:RecreateMenu()
end