
class 'GUIFeedback2' (BaseControl)

GUIFeedback2.buildString = Locale.ResolveString("BETA_MAINMENU") .. tostring(Shared.GetBuildNumber())
GUIFeedback2.feedbackString = Locale.ResolveString("FEEDBACK_MAINMENU")

local instance = nil

function GUIFeedback2:__init()

  BaseControl.Initialize(self)

  local buildText = GUIManager:CreateTextItem()
    buildText:SetFontSize(GUIFeedback.kFontSize)
    buildText:SetFontName(GUIFeedback.kTextFontName)
    buildText:SetAnchor(GUIItem.Left, GUIItem.Top)
    buildText:SetTextAlignmentX(GUIItem.Align_Min)
    buildText:SetTextAlignmentY(GUIItem.Align_Center)
    buildText:SetPosition(GUIFeedback.kTextOffset)
    buildText:SetColor(GUIFeedback.kTextColor)
    buildText:SetFontIsBold(true)
    buildText:SetText(buildString)
  self.buildText = buildText

  self:SetRootFrame(buildText)

  local feedbackText = GUIManager:CreateTextItem()
    feedbackText:SetFontSize(GUIFeedback.kFontSize)
    feedbackText:SetFontName(GUIFeedback.kTextFontName)
    feedbackText:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    feedbackText:SetTextAlignmentX(GUIItem.Align_Min)
    feedbackText:SetTextAlignmentY(GUIItem.Align_Min)
    feedbackText:SetColor(GUIFeedback.kTextColor)
    feedbackText:SetFontIsBold(true)
  buildText:AddChild(self.feedbackText)

  self:KeybindUpdated()
  
  instance = self
end

function GUIFeedback2:Uninitialize()

  BaseControl.Uninitialize(self)

  if(instance == self) then
    instance = nil
  end
end

function GUIFeedback2:KeybindUpdated()
  local key

  if(KeybindMapper) then
    key = KeyBindInfo:GetBoundKey("OpenFeedback")

	  self.feedbackText:SetText(KeyBindInfo_FillInBindKeys(string.gsub(self.feedbackString, "F1", "@OpenFeedback@")))
	  self.OpenFeedbackKey = (key and InputKey[key]) or InputKey.F1

	else
	  self.feedbackText:SetText(self.feedbackString)
  end
end

function GUIFeedback2.SetbuildText(buildString)

  if(instance) then
    instance.buildText:SetText(buildString)
  end
  
  GUIFeedback2.buildString = buildString
end

function GUIFeedback2.SetFeedbackString(feedbackString)

  assert(type(feedbackString) == "string")

  if(instance) then
    instance:KeybindUpdated()
  end
  
  GUIFeedback2.feedbackString = feedbackString
end

function GUIFeedback2:SendKeyEvent(key, down, isRepeat)

  if down and key == self.OpenFeedbackKey and not isRepeat then
  	ShowFeedbackPage()
   return true
  end

  return false
end

function GUIFeedback2:OnKeybindsChanged(keyChanges)

  if(keyChanges["OpenFeedback"]) then
    self:KeybindUpdated()
  end
end
