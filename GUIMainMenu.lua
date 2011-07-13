class'GUIMainMenu'(BaseControl)

GUIMainMenu.MenuLayer = 20

//just overrride since we don't want the BaseControl:Initialize() being called twice
function GUIMainMenu:Initialize()
  
end

function GUIMainMenu:__init(height, width)
  BaseControl.Initialize(self, height, width)
  Draggable.__init(self)


	self.Pages = {}

  self:SetColor(Color(0,0,0, 0))
 
  self:SetLayer(self.MenuLayer)
 
  self.MainPage = self:GetPage("Main")
  self.CurrentPageName = "Main"
  self.CurrentPage = self.MainPage
  
  msgBox = MenuMessageBox()
    msgBox:SetPoint("Center", 0, 0, "Center")
    msgBox:Hide()
  self:AddChild(msgBox)
  self.MsgBox = msgBox
  
  self.DefaultMsgBox = msgBox
  
  local optionsMenu = OptionsPageSelector()
    //optionsMenu:Hide()
    self:AddChild(optionsMenu)
  self.OptionsMenu = optionsMenu
  
  self.MainPage:Show()
end

function GUIMainMenu:RecreatePage(pageName)
  local page = self.Pages[pageName]
  
  if(page) then
		RawPrint("GUIMainMenu RecreatingPage "..pageName)
		
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
    RawPrint("GUIMainMenu:RecreatePage Could not find a pageinfo for page"..pageName)
  end
end

function GUIMainMenu:GetPage(name)
  
  if(self.Pages[name]) then
    return self.Pages[name]
  end

  local info = GUIMenuManager:GetPageInfo(name)
  
  if(not info) then
    RawPrint("GUIMainMenu:CreatePage unknown page " .. (name or "nil"))
   return nil
  end

  local creator = _G[info.ClassName]

  if(not creator) then
    RawPrint("GUIMainMenu:CreatePage could not get page creator for " .. (name or "nil"))
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

function GUIMainMenu:ShowMessageBox(msgBox)
  self:CheckCloseMsgBox()
  
  if(msgBox.Parent ~= self) then
    GetGUIManager():ParentToMainMenu(msgBox)
  end
  msgBox:SetPoint("Center", 0, 0, "Center")

  self.MsgBox = msgBox
  msgBox:Show()
end

function GUIMainMenu:MsgBoxClosed()
  assert(self.MsgBox.Hidden)
  self.MsgBox = nil
end

function GUIMainMenu:CheckCloseMsgBox()
  if(self.MsgBox) then
    self.MsgBox:Close()
    self.MsgBox = nil
  end
end

function GUIMainMenu:SwitchToPage(page)
 
  self:CheckCloseMsgBox()
  
  if(not page or page == "Main" or page == "") then
    self:ReturnToMainPage()
   return
  end
  
  local PageFrame = self:GetPage(page)

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

function GUIMainMenu:LeaveMainPage()
  self.MainPage:Hide()
end

function GUIMainMenu:ReturnToMainPage()

  if(self.CurrentPage) then
    self.CurrentPage:Hide()
  end

  self.OptionsMenu:Hide()
  
  self:CheckCloseMsgBox()

  self.CurrentPage = self.MainPage
  self.CurrentPageName = "Main"
  self.MainPage:UpdateButtons()
  self.MainPage:Show()
end


function GUIMainMenu:Show(Message)
  --clear focus incase a frame like chat has focus
  GUIMenuManager:ClearFocus()

  local hidden = self.Hidden
  
  BaseControl.Show(self)
  
  self:ReturnToMainPage()
  
  if(Message) then
    self:ShowMessage(Message)
  end
end


function GUIMainMenu:ShowMessage(Message, ...)  
  local msgString = Message
  
  if(select('#', ...) ~= 0) then
    msgString = string.format(Message, ...)
  end

  self.MsgBox = self.DefaultMsgBox
  self.MsgBox:Open("SimpleMsg", msgString)
end

function GUIMainMenu:OnResolutionChanged(oldX, oldY, width, height)

  self:SetSize(width, height)
  
  for k,page in pairs(self.Pages) do
    page:UpdatePosition()
    page:OnResolutionChanged(oldX, oldY, width, height)
  end
  
  if(not self.OptionsMenu.Hidden) then
    self.OptionsMenu:SetPoint("Left", self.CurrentPage:GetLeft()-2, 0, "Right")
  end
end

function GUIMainMenu:Update(...)  
  local page = self.CurrentPage
  
  if(page and page.Update) then
    page:Update(...)
  end
end

function GUIMainMenu:SendKeyEvent(key, down, isRepeat)

  if not self.Hidden and down and key == InputKey.Escape and not isRepeat and not GUIMenuManager:IsFocusedSet() then
    if(self.CurrentPageName == "Main") then
      if(Client.GetIsConnected()) then
        GUIMenuManager:CloseMenu()
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

function GUIMainMenu:GetFrameList()
  
  if(self.MsgBox and not self.MsgBox.Hidden) then
	  return {self.MsgBox}
	else
	  return self.ChildControls
	end
end

class'MenuMessageBox'(BorderedSquare)

function MenuMessageBox:__init()
  BorderedSquare.__init(self, 600, 100, 4)

  self:SetLayer(GUIMainMenu.MenuLayer+1)

  local msgString = self:CreateFontString(19, "Top", 0, 20)
    msgString:SetTextAlignmentX(GUIItem.Align_Center)
    msgString:SetText("some long really long error message no longer and longer still not long enough")
  self.MsgString = msgString
  
  self.CloseAction = {self.Close, self}
  
  local okButton = MainMenuPageButton("OK")
   okButton:SetPoint("Bottom", 0, -10, "Bottom")
   okButton.ClickAction = self.CloseAction
  self:AddChild(okButton)
  self.OKButton = okButton
  
  local cancelButton = MainMenuPageButton("Cancel")
   cancelButton:SetPoint("Bottom", -100, -10, "Bottom")
   cancelButton.ClickAction = self.CloseAction
   cancelButton:Hide()
  self:AddChild(okButton)
  self.CancelBtn = cancelButton
  
  
  local textBox = TextBox(150, 20, 19)
    textBox:SetPoint("Right", -30, 0, "Right")
    textBox:Hide()
  self:AddChild(textBox)
  self.TextBox = textBox
  
  
  self.Mode = "SimpleMsg"  
end

function MenuMessageBox:Open(mode, modeData)
  self:SetMode(mode, modeData)
  self:Show()
end

function MenuMessageBox:SetMode(mode, modeData)

  if(mode == "SimpleMsg") then
    self.MsgString:SetIsVisible(true)
    self.CancelBtn:Hide()
    self.TextBox:Hide()
    
    self.MsgString:SetText(modeData)
    
    self.OKButton.ClickAction = self.CloseAction
  else
    self.MsgString:SetIsVisible(false)
    self.CancelBtn:Show()
    self.TextBox:Show()
  end

end

function MenuMessageBox:Close()
  if(not self.Hidden) then
   self:Hide() 
   self.Parent:MsgBoxClosed()
  end
end

