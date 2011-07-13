class'GUIMainMenu'(BaseControl)

function GUIMainMenu:__init()
  BaseControl.Initialize(self, Client.GetScreenWidth(), Client.GetScreenHeight())
  Draggable.__init(self)

	self.Pages = {}

  self.RootFrame:SetColor(Color(0,0,0, 0))
 
  self.MainPage = self:GetPage("Main")
  self.CurrentPage = self.MainPage
  
  msgBox = MenuMessageBox()
    msgBox:SetPoint("Center", 0, 0, "Center")
    self:AddChild(msgBox)
  self.MsgBox = msgBox
  
  self.MsgBox:Hide()
  
  local optionsMenu = OptionsPageSelector()
    //optionsMenu:Hide()
    self:AddChild(optionsMenu)
  self.OptionsMenu = optionsMenu
  
  self.MainPage:Show()
end

function GUIMainMenu:RecreatePage(pageName)
  local page = self.Pages[pageName]
  
  if(page) then
		Print("GUIMainMenu RecreatingPage "..pageName)
		
    pcall(function()
      page:Hide()
      page:Uninitialize()
      self:RemoveChild(page)
    end)

    self.Pages[pageName] = nil

    if(self.CurrentPage == page) then
      local NewPage = self:GetPage(pageName)
      
      //check to make sure we were able to recreate the page if we didn't just go back to the main page
      if(not NewPage) then
        self.Pages[pageName] = nil
        self:ReturnToMainPage()
      else
        self.Pages[pageName] = NewPage
        self.CurrentPage = NewPage
        NewPage:Show()
      end
    end
	else
    Print("GUIMainMenu:RecreatePage Could not find a pageinfo for page"..pageName)
  end
end

function GUIMainMenu:GetPage(name)
  
  if(self.Pages[name]) then
    return self.Pages[name]
  end

  local info = MainMenuMod:GetPageInfo(name)
  
  if(not info) then
    Print("GUIMainMenu:CreatePage unknown page " .. (name or "nil"))
   return nil
  end

  local creator = _G[info.ClassName]

  if(not creator) then
    Print("GUIMainMenu:CreatePage could not get page creator for " .. (name or "nil"))
   return nil
  end

  local success,page = pcall(creator)

  if(not success) then
    self:ShowMessage("Error while creating page %s: %s", name, page)
   return nil
  end

  page:Hide()
 
  self:AddChild(page)
  page:SetPoint("Center", 0, 0, "Center")
  
  self.Pages[name] = page
  
  return page
end

function GUIMainMenu:MsgBoxClosed()
  
end

function GUIMainMenu:SwitchToPage(page)
  
  self.MsgBox:Hide()
  
  local PageFrame 

  if(not page or page == "Main" or page == "") then
    self:ReturnToMainPage()
  else
    PageFrame = self:GetPage(page)
  end

  if(PageFrame) then   
    if(self.CurrentPage == self.MainPage) then
      self:LeaveMainPage()
    else
      self.CurrentPage:Hide()
    end
    
    self.CurrentPage = PageFrame
    
    PageFrame:Show()
    
    if(MainMenuMod:GetPageInfo(page).OptionPage) then
      self.OptionsMenu:Show()
      self.OptionsMenu:SetPageButtonActive(page)
      
      self.OptionsMenu:SetPoint("Left", PageFrame:GetLeft()-2, 0, "Right")
    else
      self.OptionsMenu:Hide()
    end
  end
end

function GUIMainMenu:LeaveMainPage()
  self.MainPage:Hide()
end

function GUIMainMenu:ReturnToMainPage()

  if(self.CurrentPage) then
    self.CurrentPage:Hide()
  end

  self.OptionsMenu:Hide()
  
  self.MsgBox:Hide()

  self.CurrentPage = self.MainPage
  self.MainPage:UpdateButtons()
  self.MainPage:Show()
end

function GUIMainMenu:Show(Message)

  local hidden = self.Hidden
  
  BaseControl.Show(self)
  
  self:ReturnToMainPage()
  
  if(Message) then
    self:ShowMessage(Message)
  end
end

function GUIMainMenu:OnScreenSizeChanged(width, height)
  self:SetSize(width, height)
  
  for k,page in pairs(self.Pages) do
    page:UpdatePosition()
  end
  
end

function GUIMainMenu:ShowMessage(Message, ...)
  
  if(select('#', ...) == 0) then
    self.MsgBox:SetMsg(Message)
  else
    self.MsgBox:SetMsg(string.format(Message, ...))
  end
  
  self.MsgBox:Show()
end

function GUIMainMenu:Update(...)  
  local page = self.CurrentPage
  
  if(page and page.Update) then
    page:Update(...)
  end
end

function GUIMainMenu:OnEnter(x, y)
	
	local ControlList = {} 
	
	if(not self.MsgBox.Hidden) then
	  ControlList[1] = self.MsgBox
	else
	  ControlList[1] = self.OptionsMenu
	  ControlList[2] = self.CurrentPage
	end

	return self:ContainerOnEnter(x, y, ControlList) or false
end

function GUIMainMenu:OnClick(button, down, x, y)
	
	local ControlList = {} 
	
	if(not self.MsgBox.Hidden) then
	  ControlList[1] = self.MsgBox
	else
	  ControlList[1] = self.OptionsMenu
	  ControlList[2] = self.CurrentPage
	end
	
	return self:ContainerOnClick(button, down, x, y, ControlList) or self
end

class'MenuMessageBox'(BorderedSquare)

function MenuMessageBox:__init()
  BorderedSquare.__init(self, 600, 100, 4)

  local msgString = self:CreateFontString(19, "Top", 0, 20)
    msgString:SetTextAlignmentX(GUIItem.Align_Center)
    msgString:SetText("some long really long error message no longer and longer still not long enough")
  self.MsgString = msgString
  
  local okButton = MainMenuPageButton("OK")
   okButton:SetPoint("Bottom", 0, -10, "Bottom")
   okButton.ClickAction = function() 
    self:Hide() 
    self.Parent:MsgBoxClosed()
   end
  self:AddChild(okButton)
end

function MenuMessageBox:SetMsg(msg)
  self.MsgString:SetText(msg)
end