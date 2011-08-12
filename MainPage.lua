
class 'MainMenuButton'(BorderedSquare)

Draggable:Mixin(MainMenuButton)
ButtonMixin:Mixin(MainMenuButton)

MainMenuButton.FontSize = 20
MainMenuButton.DefaultHeight = 134
MainMenuButton.WidthRatio = 110/132
MainMenuButton.InnerSquareRatio = 100/132
MainMenuButton.InnerOffset = 5/132
MainMenuButton.LabelSquareRatio = 0.8

function MainMenuButton:__init(mode)
  if(mode) then
    self:Initialize(mode)
  end
end

function MainMenuButton:Initialize(mode)
  Draggable.__init(self)
  ButtonMixin.__init(self)
  
  local width = MainMenuButton.DefaultHeight*self.WidthRatio
  BorderedSquare.__init(self, width, MainMenuButton.DefaultHeight, 2)
  
  self:SetBackgroundColor(Color(0.06,0.06,0.06, 0.8))
  local innerSize = self.InnerSquareRatio*width
  
  local innerSquare = BorderedSquare(innerSize, innerSize, 1)
   self:AddChild(innerSquare)
   innerSquare:SetPoint("Top", 1, 5, "Top")
   innerSquare:SetBackgroundColor(Color(1,1,1,1))
  self.InnerSquare = innerSquare

	local labelBG = BaseControl(innerSize, 20)
    labelBG:SetPoint("Bottom", 0, -4, "Bottom")
    labelBG.RootFrame:SetColor(Color(0, 0, 0, 0))
    self:AddChild(labelBG)
	self.LabelBG = labelBG
	
	local label = labelBG:CreateFontString(17, "Center", 0, 0)
   label:SetColor(Color(1,1,1,1))
	 label:SetFontIsBold(true)
	 label:SetTextAlignmentX(GUIItem.Align_Center)
	 label:SetTextAlignmentY(GUIItem.Align_Center)
	self.Label = label
	
	self:SetHeight(130)
	self.DragButton = InputKey.MouseButton1
	
	if(mode) then
	  self:SetMode(mode)
	else
	  innerSquare.RootFrame:SetTexture("ui/join.dds")
	  self.Label:SetText("SomeText")
	end
	//innerSquare.RootFrame:SetTextureCoordinates(0, 0, 1, 1)
end

function MainMenuButton:SetMode(mode)
  self.Mode = mode
	self.ClickAction = mode[1]
	self.Label:SetText(mode[2])
	self.InnerSquare.RootFrame:SetTexture(mode[3])
end

function MainMenuButton:SetHeight(height)

	local width = height*self.WidthRatio
  BorderedSquare.SetSize(self, width, height)

  local innerSize = self.InnerSquareRatio*height
  self.InnerSquare:SetPoint("Top", 1, height*self.InnerOffset, "Top")
	self.InnerSquare:SetSize(innerSize, innerSize)
	
	local labelheight = innerSize*0.2
	self.LabelBG:SetSize(innerSize, labelheight, true)
	
	self.LabelBG:SetPoint("Bottom", 1, -(innerSize*0.03), "Bottom")
	//self.Label:SetText(string.format("%f %f",height,-(innerSize*0.04)))
end

function MainMenuButton:OnClick(button, down, x, y)
	if(not Draggable.OnClick(self, button, down, x, y)) then
	  ButtonMixin.OnClick(self, button, down)
	end
end

function MainMenuButton:OnEnter()
  self.InnerSquare:SetBorderColour(ControlHighlightColor)
  
  self.LabelBG:SetTexture("ui/ButtonBg.dds")
  self.LabelBG.RootFrame:SetColor(Color(1, 1, 1, 1))
  PlayerUI_PlayButtonEnterSound()
end

function MainMenuButton:OnLeave()
	self.InnerSquare:SetBorderColour(Color(0.8666, 0.3843, 0, 0))
	self.LabelBG:SetTexture("")
	self.LabelBG.RootFrame:SetColor(Color(0.8666, 0.3843, 0, 0))
end

class'MenuMainPage'(BaseControl)

Draggable:Mixin(MenuMainPage)

MenuMainPage.ButtonSpacing = 15

local ButtonList ={
  ServerBrowser = {
    function() GUIMenuManager:ShowPage("ServerBrowser") end,
	  "Join",
	  "ui/join.dds",
	},
	CreateServer = {
		function() GUIMenuManager:ShowPage("CreateServer") end,
		"Create",
		"ui/createserver.dds",
	},
	Options = {
		function() GUIMenuManager:ShowPage("MainOptions") end,
		"Options",
		"ui/options.dds",
	},
	ExitGame = {
		"MainMenu_Quit",
		"Exit",
		"ui/exitgame.dds",
	},
	Disconnect = {
		function()
		  //Client.Disconnect()// seems to break the menu cinematic
      Client.ConsoleCommand("disconnect") 
		end,
		"Disconnect",
		"ui/exitgame.dds",
	},
	ReturnToGame = {
		function() 
		  if(Client.GetIsConnected()) then 
		    MainMenu_ReturnToGame()
		  end
		end,
		"Return",
		"ui/returntogame.dds",
	},
}

function MenuMainPage:__init()
  
  local buttonHeight = MainMenuButton.DefaultHeight
  local buttonOffset = 108+self.ButtonSpacing
 
  self.DragButton = InputKey.MouseButton1
 
  BaseControl.Initialize(self, buttonOffset*4, (buttonHeight*2)+20)
  Draggable.__init(self)
 
  self.TraverseChildFirst = true
 
  self:SetColor(Color(1,1,1, 0))
  
  self.Buttons = {}
  
  local logo = BaseControl(717, 158)
    logo:SetTexture("ui/logo.dds")
    logo:SetPoint("Top", 0, -30, "Bottom")
  self:AddChild(logo)
  
  for i, name in ipairs({"ServerBrowser", "CreateServer", "Options", "ExitGame"}) do
   local button = MainMenuButton(ButtonList[name])
    self:AddChild(button)
    button:SetPosition((i-1)*buttonOffset, 0)
    
    self.Buttons[name] = button
  end
  
  local returnToGame = MainMenuButton(ButtonList.ReturnToGame)
    self:AddChild(returnToGame)
    returnToGame:SetPoint("Bottom", 30, -15, "BottomLeft")
  self.ReturnToGame = returnToGame
  self.Buttons.ReturnToGame = returnToGame

  local disconnect = MainMenuButton(ButtonList.Disconnect)
    self:AddChild(disconnect)
    disconnect:SetPoint("Bottom", -30, -15, "BottomRight")
  self.Disconnect = disconnect
  self.Buttons.Disconnect = disconnect
  
  self:UpdateButtons()
end

function MenuMainPage:Show()
  BaseControl.Show(self)
  
  self:UpdateButtons()
end

function MenuMainPage:OnResolutionChanged(oldX, oldY, width, height)
  
  local buttonHeight = height*0.2
end

function MenuMainPage:UpdateButtons()

  if(Client.GetIsConnected()) then
    self.ReturnToGame:Show()
    self.Disconnect:Show()
  else
    self.ReturnToGame:Hide()
    self.Disconnect:Hide()
  end
end

function MenuMainPage:OnClick(button, down, x, y)
	return Draggable.OnClick(self, button, down, x, y)
end

