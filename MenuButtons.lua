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
	self.RootFrame:AddChild(center)
	
	local label = self:CreateFontString(FontSize)
	 label:SetFontIsBold(true)
	 label:SetAnchor(GUIItem.Center, GUIItem.Middle)
	 label:SetTextAlignmentX(GUIItem.Align_Center)
	 label:SetTextAlignmentY(GUIItem.Align_Center)
	 label:SetText(labelText or "some text")  
	center:AddChild(self.Label)
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

/*
function MainMenuPageButton:OnClick(button, down, x, y)
	if(down and button == InputKey.MouseButton0) then
		PlayerUI_PlayButtonClickSound()
		
		local ClickAction = self.ClickAction
		
		if(ClickAction) then
			if(type(ClickAction) == "table") then
			  ClickAction[1](unpack(ClickAction, 2))
			else
			  if(type(ClickAction) == "string") then
				  ClickAction = _G[ClickAction]
				end
			  ClickAction()
			end
		end
	end

	return Draggable.OnClick(self, button, down, x, y)
end
*/

function MainMenuPageButton:SetLabel(label)
  self.Label:SetText(label)
end

function MainMenuPageButton:OnEnter()
  self.CenterSquare:SetTexture("ui/MainMenuButtonBg.dds")
	self.CenterSquare:SetColor(Color(1, 1, 1, 1))
	PlayerUI_PlayButtonEnterSound()
 return self
end

function MainMenuPageButton:OnLeave()
	self.CenterSquare:SetColor(self.CenterColor)
	self.CenterSquare:SetTexture("")
end