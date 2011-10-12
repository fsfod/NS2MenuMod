
ControlClass('OptionsPageButton', BaseControl)
ButtonMixin:Mixin(OptionsPageButton)

OptionsPageButton.FontSize = 16
OptionsPageButton.StartingColor = Color(0.15, 0.15, 0.15, 1)


ControlClass('OptionsPageSelector', BorderedSquare)

function OptionsPageSelector:Initialize()
  self.ButtonHeight = 40
  self.ButtonWidth = 130

  local borderSize = 4
  local pageList = GUIMenuManager.OptionPageList

  BorderedSquare.Initialize(self, self.ButtonWidth+borderSize, (self.ButtonHeight*(#pageList+1))+borderSize, borderSize)
  self:Hide()
  self:SetupHitRec()

  self:SetColor(0.1, 0.1, 0.1, 1)

  self.Buttons = {}
  self.NameToButton = {}

  for i,name in ipairs(pageList) do
    local button =  self:CreateControl("OptionsPageButton", name, self.ButtonWidth, self.ButtonHeight)
      button:SetPosition(borderSize, ((i-1)*self.ButtonHeight)+borderSize)
      self:AddChild(button)
      
    self.Buttons[#self.Buttons+1] = button
  end

  local returnButton =  self:CreateControl("OptionsPageButton", "return", self.ButtonWidth, self.ButtonHeight)
    returnButton:SetPoint("BottomLeft", borderSize, 0, "BottomLeft")
  self:AddChild(returnButton)

  self:SetPoint("Left", 0, 0, "Left")
end

function OptionsPageSelector:SetPageButtonActive(pageName)
  
  if(self.ActiveButton and self.ActiveButton ~= button) then
    self.ActiveButton:ClearActive()
  end
  
  for i,button in ipairs(self.Buttons) do
    if(button.PageName == pageName) then
      button:SetActive()
      self.ActiveButton = button
     return
    end
  end
  
  RawPrint("OptionsPageSelector:SetPageButtonActive could not find a button for page "..pageName)
end

function OptionsPageSelector:ButtonClicked(button)

  if(button.ReturnButton) then
    GUIMenuManager:ReturnToMainPage()
   return
  end

  GUIMenuManager:ShowPage(button.PageName)
end

function OptionsPageButton:Initialize(pageName, width, height)
  width = width or 128
  height = height or 64

  BaseControl.Initialize(self, width, height)
  ButtonMixin.Initialize(self)

  self:SetTexture("ui/CurvedGradient.dds")
  self:SetColor(self.StartingColor)

	local label = self:CreateFontString(self.FontSize)
	 label:SetFontIsBold(true)
	 label:SetAnchor(GUIItem.Center, GUIItem.Middle)
	 label:SetTextAlignmentX(GUIItem.Align_Center)
	 label:SetTextAlignmentY(GUIItem.Align_Center)
	self:AddGUIItemChild(label)
	self.Label = label
	
	self:SetupHitRec()
	
	self:UpdatePage(pageName)
end

function OptionsPageButton:UpdatePage(pageName)
  local labelText

  if(pageName == "return") then
    labelText = "Back"
    self.ReturnButton = true
    
    self.RootFrame:SetTexturePixelCoordinates(0, 0, 2, 122)
  else
    labelText = GUIMenuManager:GetPageInfo(pageName).Label
    self.PageName = pageName
  end

  self.Label:SetText(labelText)
end

function OptionsPageButton:ClearActive()
  self.Active = false
  self:SetColor(0.2, 0.2, 0.2, 1)
end

function OptionsPageButton:SetActive()
  self.Active = true
  self:SetColor(0.8666, 0.3843, 0, 1)
end

function OptionsPageButton:Clicked(down)

  if(down) then
    self.Parent:ButtonClicked(self)
    self.Label:SetPosition(Vector(0, 2 ,0))
  else
     self.Label:SetPosition(Vector(0, 0 ,0))
  end
end

function OptionsPageButton:OnEnter()

  if(not self.Active) then
    self:SetColor(0.8666, 0.3843, 0, 0.7)
  end
end

function OptionsPageButton:OnLeave()
  
  if(not self.Active) then
    self:SetColor(0.2, 0.2, 0.2, 1)
  end
end


