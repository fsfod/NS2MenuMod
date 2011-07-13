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
  
  self.MainPage:Show()
end

function GUIMainMenu:GetPage(name)
  
  if(self.Pages[name]) then
    return self.Pages[name]
  end

  local creator = MainMenuMod.PageCreators[name]

  if(not creator) then
    error("GUIMainMenu:CreatePage unknown page " .. (name or "nil"))
  end

  local page = creator()

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
  end
end

function GUIMainMenu:LeaveMainPage()
  self.MainPage:Hide()
end

function GUIMainMenu:ReturnToMainPage()
  self.CurrentPage:Hide()
  
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

function GUIMainMenu:ShowMessage(Message)
  self.MsgBox:SetMsg(Message)
  self.MsgBox:Show()
end

function GUIMainMenu:Update(...)  
  local page = self.CurrentPage
  
  if(page and page.Update) then
    page:Update(...)
  end
end

function GUIMainMenu:OnEnter(x, y)
	
	local ActiveFrame = (not self.MsgBox.Hidden and self.MsgBox) or self.CurrentPage
	local HitRec = ActiveFrame.HitRec
	
	if(x > HitRec[1] and y > HitRec[2] and x < HitRec[3] and y < HitRec[4]) then
	  local frame = ActiveFrame:ContainerOnEnter(x-HitRec[1],y-HitRec[2])
	
    if(frame) then
		  return frame
	  end
	end
	
	return false
end

function GUIMainMenu:OnClick(button, down, x, y)
	
	local ActiveFrame = (not self.MsgBox.Hidden and self.MsgBox) or self.CurrentPage
	local HitRec = ActiveFrame.HitRec
		
	if(down and x > HitRec[1] and y > HitRec[2] and x < HitRec[3] and y < HitRec[4]) then
	  
	  local ClickFunc = ActiveFrame.OnClick or BaseControl.ContainerOnClick
	  
	  local frame = ClickFunc(ActiveFrame, button, down, x-HitRec[1],y-HitRec[2])
	
    if(frame) then
		  return frame
	  end
	end

  return self
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