ControlClass('PagedMainMenu', BaseControl)

PageFactory:Mixin(PagedMainMenu)

function PagedMainMenu:Initialize(height, width)
  BaseControl.Initialize(self, height, width)
  PageFactory.Initialize(self)

  self:SetColor(Color(0,0,0, 0))
 
  self.MainPage = self:GetOrCreatePage("Main")
  self.CurrentPageName = "Main"
  self.CurrentPage = self.MainPage

  local optionsMenu = self:CreateControl("OptionsPageSelector")
    //optionsMenu:Hide()
    self:AddChild(optionsMenu)
  self.OptionsMenu = optionsMenu
  
  self.MainPage:Show()

  local switchButton =  self:CreateControl("MenuButton2", 15, "Switch to classic menu", function() GUIMenuManager:SwitchMainMenu("ClassicMenu") end, 14)                                               
   switchButton:SetPoint("BottomLeft", 20, -20)
   self:AddChild(switchButton)
end

function PagedMainMenu:OnClientConnected()
  self.MainPage:UpdateButtons()
end

function PagedMainMenu:OnClientDisconnected()
  self.MainPage:UpdateButtons()
end

function PagedMainMenu:OnPageCreated(name, page)

  if(not page) then
    self:ReturnToMainPage()
   return
  end

  self:AddChild(page)
  
  page:Show()
  page:SetPoint("Center", 0, 0, "Center")
end

function PagedMainMenu:OnPageDestroy(name, page)
  self:RemoveChild(page)
end

function PagedMainMenu:ShowPage(page)

  if(not page or page == "Main" or page == "") then
    self:ReturnToMainPage()
   return
  end

  local PageFrame = self:GetOrCreatePage(page)

  if(not PageFrame) then
   --GetPage will have placed error in the console so we have nothing todo
    return
  end
       
  if(self.CurrentPage == self.MainPage) then
    self:LeaveMainPage()
  else
    self.CurrentPage:Hide()
  end
  
  self.CurrentPage = PageFrame
  self.CurrentPageName = page
  
  PageFrame:Show()

  if(GUIMenuManager:GetPageInfo(page).OptionPage) then
    self.OptionsMenu:Show()
    self.OptionsMenu:SetPageButtonActive(page)
    
    self.OptionsMenu:SetPoint("Left", PageFrame:GetLeft()-2, 0, "Right")
  else
    self.OptionsMenu:Hide()
  end
end

function PagedMainMenu:LeaveMainPage()
  self.MainPage:Hide()
end

function PagedMainMenu:ReturnToMainPage()

  if(self.CurrentPage) then
    self.CurrentPage:Hide()
  end

  self.OptionsMenu:Hide()
  
  //self:CheckCloseMsgBox()

  self.CurrentPage = self.MainPage
  self.CurrentPageName = "Main"
  self.MainPage:UpdateButtons()
  self.MainPage:Show()
end

function PagedMainMenu:Show()
  --clear focus incase a frame like chat has focus
  GUIMenuManager:ClearFocus()

  local hidden = self.Hidden
  
  BaseControl.Show(self)
  
  self:ReturnToMainPage()
end

function PagedMainMenu:OnResolutionChanged(oldX, oldY, width, height)

  self:SetSize(width, height)
 
  for k,page in pairs(self.Pages) do
    page:OnResolutionChanged(oldX, oldY, width, height)
  end
  
  if(not self.OptionsMenu.Hidden) then
    self.OptionsMenu:SetPoint("Left", self.CurrentPage:GetLeft()-2, 0, "Right")
  end
end

function PagedMainMenu:Update(...)  
  local page = self.CurrentPage
  
  if(page and page.Update) then
    page:Update(...)
  end
end

function PagedMainMenu:SendKeyEvent(key, down, isRepeat)

  if not self.Hidden and down and key == InputKey.Escape and not isRepeat and not GUIMenuManager:IsFocusedSet() then
    
    if(GUIMenuManager:TryCloseTopMostWindow()) then
    elseif(self.CurrentPageName == "Main") then
      if(Client.GetIsConnected()) then
        MainMenu_ReturnToGame()
      else
        return false
      end
    else
      self:ReturnToMainPage()
    end
    
   return true
  end
  
  return false
end

