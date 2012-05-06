//
//   Created by:   fsfod
//

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

ControlClass('OptionsPage', BasePage)

OptionsPage.PageName = "MainOptions"


function OptionsPage:Initialize()
  BasePage.Initialize(self, 600, 500, self.PageName, "Options")
  BaseControl.Hide(self)
 
  ResHelper:Init()

  local topSpaceing = 35
  
  local nickName = self:CreateControl("TextBox", 100, 24)
    nickName:SetPoint("Top", -76, 40, "Top")
    nickName:SetLabel("Nickname")
    nickName:SetConfigBinding(kNicknameOptionsKey, "NsPlayer")
  self:AddChild(nickName)
  
  local soundVolume = self:CreateControl("Slider", 250, 20, 0, 100)
    soundVolume:SetPoint("Top", 30, 80, "Top")
    soundVolume:SetLabel("Sound Volume")
    soundVolume.NoValueChangedWhileDraging = true
    soundVolume:SetConfigBinding(kSoundVolumeOptionsKey, 90)
    soundVolume.ValueChanged = function(value, stillDragging) 
      Client.SetSoundVolume(value/100)
      PlayerUI_PlayButtonClickSound()
    end
  self:AddChild(soundVolume)
  
  local musicVolume = self:CreateControl("Slider", 250, 20, 0, 100)
    musicVolume:SetLabel("Music Volume")
    musicVolume:SetPoint("Top", 30, 120, "Top")
    musicVolume:SetConfigBinding(kMusicVolumeOptionsKey, 90)
    musicVolume.ValueChanged = function(value) Client.SetMusicVolume(value/100) end
  self:AddChild(musicVolume)

  local voiceVolume = self:CreateControl("Slider", 250, 20, 0, 100)
    voiceVolume:SetPoint("Top", 30, 155, "Top")
    voiceVolume:SetLabel("Voice Volume")
    voiceVolume.NoValueChangedWhileDraging = true
    voiceVolume:SetConfigBinding(kVoiceVolumeOptionsKey or "voiceVolume", 90)
    voiceVolume.ValueChanged = function(value, stillDragging) 
      if(Client.SetVoiceVolume) then
        Client.SetVoiceVolume(value/100)
      end
    end
  self:AddChild(voiceVolume)
  
  local sensitivityValue = self:CreateControl("TextBox", 80, 20)
 
  local mouseSensitivity = self:CreateControl("Slider", 250, 20, 0.01, 2)
    mouseSensitivity:SetPoint("Top", 30, 190, "Top")
    mouseSensitivity.ValueChanged = function(value) 
      sensitivityValue:SetText(string.format("%.5f", value))
    end
    mouseSensitivity:SetConfigBinding(Client.GetMouseSensitivity, Client.SetMouseSensitivity)
    mouseSensitivity:SetStepSize(0.05)
    //mouseSensitivity.NoValueChangedWhileDraging = true
    mouseSensitivity:SetLabel("Mouse Sensitivity")
  self:AddChild(mouseSensitivity)

    sensitivityValue:SetPoint("Top", 200, 190, "Top")
    sensitivityValue:SetText(string.format("%.5f", Client.GetMouseSensitivity()))
    sensitivityValue.OnFocusLost = function() 
      local value = sensitivityValue:TryParseNumber(mouseSensitivity:GetValue(), 0.01, 2)

      if(value) then
        mouseSensitivity:SetValueAndTiggerEvent(value)
      end
      
      TextBox.OnFocusLost(sensitivityValue)
    end

  self:AddChild(sensitivityValue)

  local invertMouse = self:CreateControl("CheckBox", "Invert Mouse", false, true)
    invertMouse:SetPoint("Top", -90, 225, "Top")
    invertMouse:SetConfigBinding(kInvertedMouseOptionsKey, false)
  self:AddChild(invertMouse)
/*
  local mouseAccel = self:CreateControl("CheckBox", "Mouse Acceleration", false, true)
    mouseAccel:SetPoint("Top", 100, 225, "Top")
    mouseAccel:SetConfigBinding("input/mouse/acceleration", false) 
    mouseAccel.CheckChanged = function(checked)
      Shared.ConsoleCommand("i_accel "..tostring(checked))
    end
  self:AddChild(mouseAccel)
*/
  local rawinput = self:CreateControl("CheckBox", "Raw Mouse Input", true, true)
    rawinput:SetPoint("Top", 80, 225, "Top")
    rawinput:SetConfigBinding("input/mouse/rawinput", true)
    rawinput.CheckChanged = function(checked)
      Shared.ConsoleCommand("i_rawinput "..tostring(checked))
    end
  self:AddChild(rawinput)

  local skulkViewTilt = self:CreateControl("CheckBox", "Disable Skulk View Tilt", false, true)
    skulkViewTilt:SetPoint("Top", -90, 260, "Top")
    skulkViewTilt:SetConfigBinding("DisableSkulkViewTilt", false)
    skulkViewTilt.CheckChanged = function(checked)
      if(OnCommandSkulkViewTilt) then
        OnCommandSkulkViewTilt(checked and "false") 
      end     
    end
  self:AddChild(skulkViewTilt)
 
  local bloom = self:CreateControl("CheckBox", "Bloom", true, true)
    bloom:SetPoint("Top", 0, 300, "Top")
    bloom:SetConfigBinding("graphics/display/bloom", true)
    bloom.CheckChanged = function(checked)
      Shared.ConsoleCommand("r_bloom "..tostring(checked))
    end    
  self:AddChild(bloom)
 
  local antialiasing = self:CreateControl("CheckBox", "Anti-aliasing", true, true)
    antialiasing:SetPoint("Top", 140, 300, "Top")
    antialiasing:SetConfigBinding("graphics/display/antialiasing", true)
    antialiasing.CheckChanged = function(checked)
      Shared.ConsoleCommand("r_aa "..tostring(checked))
    end
  self:AddChild(antialiasing)

  local atmosphericLights = self:CreateControl("CheckBox", "Atmospheric Lights", true, true)
    atmosphericLights:SetPoint("Top", -90, 300, "Top")
    atmosphericLights:SetConfigBinding("graphics/display/atmospherics", true)
    atmosphericLights.CheckChanged = function(checked)
      Shared.ConsoleCommand("r_atmospherics "..tostring(checked))
    end
  self:AddChild(atmosphericLights)


/* 
  local windowed = self:CreateControl("CheckBox", "Windowed")
    windowed:SetPoint("Top", 70, 300, "Top")
    self.GFXOptionBindings[2] = windowed:SetConfigBinding(kFullscreenOptionsKey, false, nil, function(value) return not value end):SetDelaySave(true)
  self:AddChild(windowed)
  
 
  if(SetIsBorderless) then
    local borderless = self:CreateControl("CheckBox", "Borderless")
      borderless:SetPoint("Top", 180, 300, "Top")
      borderless:SetConfigBinding("borderless_window", false)
      borderless.CheckChanged = function(checked)
        
        if(Client.GetOptionBoolean(kFullscreenOptionsKey, true)) then
          return
        end
        
        local res = Client.GetStartupDisplayMode()

        //if screen size is the native res of the monitor reset the window to 0,0 when we make it borderless
        SetIsBorderless(checked, Client.GetScreenWidth() >= res.xResolution and Client.GetScreenHeight() >= res.yResolution)
      end
    self:AddChild(borderless)
  end
*/
  self.GFXOptionBindings = {}

  local windowMode = self:CreateControl("ComboBox", 185, 20, {"Fullscreen", "Windowed", "Windowed Fullscreen"})
    windowMode:SetPoint("Top", -80, 340, "TopLeft")
    windowMode:SetLabel("Display Mode")
    self.GFXOptionBindings[1] = windowMode:SetConfigBinding({{kFullscreenOptionsKey, true},
                                                             {"borderless_window", false}}, self.WindowConfigConverter):SetDelaySave(true)
  self:AddChild(windowMode)

  local screenRes = self:CreateControl("ComboBox", 180, 20, ResHelper.DisplayModes, self.ResToString)
   screenRes:SetPoint("Top", -80, 375, "TopLeft")
   screenRes:SetLabel("Resolution")
   self.GFXOptionBindings[2] = screenRes:SetConfigBinding({{kGraphicsXResolutionOptionsKey, 1280, "integer"},
                                                           {kGraphicsYResolutionOptionsKey, 800,  "integer"}}, self.ResConfigConverter):SetDelaySave(true)
  self:AddChild(screenRes)
  
  self.ScreenRes = screenRes

  local visualDetail = self:CreateControl("ComboBox", 200, 20, OptionsDialogUI_GetVisualDetailSettings())
    visualDetail:SetPoint("Top", -80, 410, "TopLeft")
    visualDetail:SetLabel("Visual Detail")
    self.GFXOptionBindings[3] = visualDetail:SetConfigBinding(kDisplayQualityOptionsKey, 0, "integer",
     function(value, index)
       if(index) then
         return index-1
       else
         return value+1
       end
    end):SetDelaySave(true)
    
    //visualDetail.ItemPicked = function() Client.ReloadGraphicsOptions() end
  self:AddChild(visualDetail)

   local applyGFXsButton = self:CreateControl("UIButton", "Apply Gfx Changes", 150)
    applyGFXsButton:SetPoint("Top", 0, 450, "Top")
    applyGFXsButton.ClickAction = function() self:ApplyGFXChanges() end
  self:AddChild(applyGFXsButton)
  
end

function OptionsPage:ApplyGFXChanges()
  
  //visualDetail
  for i,binding in ipairs(self.GFXOptionBindings) do
    binding:SaveStoredValue()
  end
  
  //clear borderless if its set before changing resolution so the engines values for Client.GetScreenWidth() and Client.GetScreenHeight() don't get inflated by the border size
  if(GetIsBorderless) then
    
    if(not Client.GetOptionBoolean("graphics/display/fullscreen", false) and Client.GetOptionBoolean("borderless_window", false)) then
      SetIsBorderless(false, false)
    end
  end

  Client.ReloadGraphicsOptions()

  if(GetIsBorderless) then
    UIHelper:ReSetBorderless()
  end

  //ChangeUIScale()
end

local windowedModes = {
  {true,  false}, //Fullscreen
  {false, false}, //Windowed
  {false, true}, //Fullscreen windowed
}

function OptionsPage.WindowConfigConverter(fullscreen, indexOrBorderless)

  if(type(indexOrBorderless) == "number") then
    return unpack(windowedModes[indexOrBorderless])
  else
    
    if(fullscreen == true) then
      return 1
    elseif(indexOrBorderless == true) then
      return 3
    else
      return 2
    end
  end
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

