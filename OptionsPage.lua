
local HotReload = OptionsPage


local ResHelper = {}

function ResHelper:Init()

  local modes = { }
  local numModes = Client.GetNumDisplayModes()
    
  for modeIndex = 1, numModes do
    modes[modeIndex] = Client.GetDisplayMode(modeIndex)
  end

  local mode = Client.GetStartupDisplayMode()
  local nativeAspect = mode.xResolution / mode.yResolution
 
  self.NativeAspectRatio = nativeAspect  
  self.DisplayModes = modes
end

function ResHelper:IsNativeAspectRatio(mode)
  return self.NativeAspectRatio == (mode.xResolution / mode.yResolution)
end

function ResHelper:IndexOfRes(x, y)
  
  for modeIndex, mode in ipairs(self.DisplayModes) do       
    if(x == mode.xResolution and y == mode.yResolution) then
      return modeIndex
    end
  end
end

class'OptionsPage'(BasePage)

OptionsPage.PageName = "MainOptions"

function OptionsPage:__init()
  BasePage.__init(self, 600, 500, self.PageName, "Options")
  BaseControl.Hide(self)
 
  ResHelper:Init()

  local topSpaceing = 35
  
  local nickName = TextBox(100, 20)
    nickName:SetPoint("Top", -76, 40, "Top")
    nickName:SetLabel("Nickname")
    nickName:SetConfigBinding(kNicknameOptionsKey, "NsPlayer")
  self:AddChild(nickName)
  
  local soundVolume = Slider(250, 20, 0, 100)
    soundVolume:SetPoint("Top", 0, 80, "Top")
    soundVolume:SetLabel("Sound Volume")
    soundVolume.NoValueChangedWhileDraging = true
    soundVolume:SetConfigBinding(kSoundVolumeOptionsKey, 90)
    soundVolume.ValueChanged = function(value, stillDragging) 
      Client.SetSoundVolume(value/100)
      PlayerUI_PlayButtonClickSound()
    end
  self:AddChild(soundVolume)
  
  local musicVolume = Slider(250, 20, 0, 100)
    musicVolume:SetLabel("Music Volume")
    musicVolume:SetPoint("Top", 0, 120, "Top")
    musicVolume:SetConfigBinding(kMusicVolumeOptionsKey, 90)
    musicVolume.ValueChanged = function(value) Client.SetMusicVolume(value/100) end
  self:AddChild(musicVolume)

  local voiceVolume = Slider(250, 20, 0, 100)
    voiceVolume:SetPoint("Top", 0, 155, "Top")
    voiceVolume:SetLabel("Voice Volume")
    voiceVolume.NoValueChangedWhileDraging = true
    voiceVolume:SetConfigBinding(kVoiceVolumeOptionsKey or "voiceVolume", 90)
    voiceVolume.ValueChanged = function(value, stillDragging) 
      if(Client.SetVoiceVolume) then
        Client.SetVoiceVolume(value/100)
      end
    end
  self:AddChild(voiceVolume)
 
  local mouseSensitivity = Slider(250, 20, 0.01, 2)
    mouseSensitivity:SetPoint("Top", 0, 190, "Top")
    mouseSensitivity:SetConfigBinding(Client.GetMouseSensitivity, Client.SetMouseSensitivity)
    mouseSensitivity:SetStepSize(0.05)
    mouseSensitivity.NoValueChangedWhileDraging = true
    mouseSensitivity:SetLabel("Mouse Sensitivity")
  self:AddChild(mouseSensitivity)

  local invertMouse = CheckBox("Invert Mouse", false, true)
    invertMouse:SetPoint("Top", -85, 225, "Top")
    invertMouse:SetConfigBinding(kInvertedMouseOptionsKey, false)
  self:AddChild(invertMouse)

  local skulkViewTilt = CheckBox("Disable Skulk View Tilt", false, true)
    skulkViewTilt:SetPoint("Top", -53, 260, "Top")
    skulkViewTilt:SetConfigBinding("DisableSkulkViewTilt", false)
    skulkViewTilt.CheckChanged = function(checked)
      if(OnCommandSkulkViewTilt) then
        OnCommandSkulkViewTilt(checked and "false") 
      end     
    end
  self:AddChild(skulkViewTilt)

  local GfxOptionBindings = {}

  local screenRes = ComboBox(140, 20, ResHelper.DisplayModes, self.ResToString)
   screenRes:SetPoint("Top", -60, 300, "Top")
   screenRes:SetLabel("Resolution")
   GfxOptionBindings[1] = screenRes:SetConfigBinding({{kGraphicsXResolutionOptionsKey, 1280, "integer"},
                                                      {kGraphicsYResolutionOptionsKey, 800, "integer"}}, self.ResConfigConverter):SetDelaySave(true)
  self:AddChild(screenRes)
 
  local windowed = CheckBox("Run Windowed")
    windowed:SetPoint("Top", 80, 300, "Top")
    GfxOptionBindings[2] = windowed:SetConfigBinding(kFullscreenOptionsKey, false, nil, function(value) return not value end):SetDelaySave(true)
  self:AddChild(windowed)
  
  local visualDetail = ComboBox(140, 20, OptionsDialogUI_GetVisualDetailSettings())
    visualDetail:SetPoint("Top", -60, 345, "Top")
    visualDetail:SetLabel("Visual Detail")
    GfxOptionBindings[3] = visualDetail:SetConfigBinding(kDisplayQualityOptionsKey, 0, "integer",
     function(value, index)
       if(index) then
         return index-1
       else
         return value+1
       end
    end):SetDelaySave(true)
    
    //visualDetail.ItemPicked = function() Client.ReloadGraphicsOptions() end
  self:AddChild(visualDetail)

   local applyGFXsButton = UIButton("Apply Gfx Changes", 150)
    applyGFXsButton:SetPoint("Top", -10, 395, "Top")
    applyGFXsButton.ClickAction = function() 
      //visualDetail
      for i,binding in ipairs(GfxOptionBindings) do
        binding:SaveStoredValue()
      end
      Client.ReloadGraphicsOptions() 
    end
  self:AddChild(applyGFXsButton)
end

function OptionsPage.ResToString(entry)
  local width, height = entry.xResolution, entry.yResolution
  
  if(ResHelper:IsNativeAspectRatio(entry)) then
    return string.format("*%dx%d", width, height)
  else
    return string.format("%dx%d", width, height)
  end
end

function OptionsPage.ResConfigConverter(modeOrXRes, yRes)
  if(type(modeOrXRes) == "number") then
    return ResHelper:IndexOfRes(modeOrXRes, yRes)
  else
    return modeOrXRes.xResolution, modeOrXRes.yResolution
  end
end
 

if(HotReload) then
  GUIMenuManager:RecreatePage(OptionsPage.PageName)
end

