class 'MainMenuPageButton'(BorderedSquare)

ButtonMixin:Mixin(MainMenuPageButton)

MainMenuPageButton.InnerHeight = 24/36
MainMenuPageButton.InnerWidth = 94/100

MainMenuPageButton.CenterColor = Color(0.133, 0.149, 0.1529, 1)

local FontSize = 16

local Orange = Color(0.8666, 0.3843, 0, 1)

function MainMenuPageButton:__init(labelText, width, height)
  if(labelText) then
    self:Initialize(labelText, width, height)
  end
end

function MainMenuPageButton:Initialize(labelText, width, height)

  width = width or 110
  height = height or 36

	BorderedSquare.__init(self, width, height, 2, true)
	ButtonMixin.__init(self)
	
	self:SetBackgroundColor(Color(0.06,0.06,0.06, 0.8))
	
	local center = GUIManager:CreateGraphicItem()
	 center:SetAnchor(GUIItem.Center, GUIItem.Middle)
	 center:SetColor(self.CenterColor)
	 self.CenterSquare = center
	self:AddGUIItemChild(center)
	
	local label = PageButtonFont:CreateFontString()
	 label:SetText(labelText or "some text")  
	 center:AddChild(label)
	self.Label = label
	
  self:SetSize(width, height)
end

function MainMenuPageButton:SetSize(width, height)

  BorderedSquare.SetSize(self, width, height)

  local centerHeight = self.InnerHeight*height
  local centerWidth = (self.InnerWidth*width)-2

  self.CenterSquare:SetSize(Vector(centerWidth, centerHeight, 0))
  self.CenterSquare:SetPosition(Vector(1-(centerWidth/2), -((centerHeight/2)-1), 0))
end


function MainMenuPageButton:Clicked(down)
	if(down) then
    self.Label:SetPosition(Vector(0, 2 ,0))
  else
    self.Label:SetPosition(Vector.origin)
  end
end


function MainMenuPageButton:SetLabel(label)
  self.Label:SetText(label)
end

function MainMenuPageButton:OnEnter()
  self.CenterSquare:SetTexture("ui/MainMenuButtonBg.dds")
	self.CenterSquare:SetColor(Color(1, 1, 1, 1))
	PlayerUI_PlayButtonEnterSound()
end

function MainMenuPageButton:OnLeave()
	self.CenterSquare:SetColor(self.CenterColor)
	self.CenterSquare:SetTexture("")
end