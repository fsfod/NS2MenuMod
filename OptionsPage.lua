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

OptionsPage.ControlSetup = {
    NickName = {
      Type = "TextBox",
      Width = 100,
      Height = 24,
      Position = {"Top", -76, 40, "Top"},
      Label = "Nickname",
      ConfigDatabind = {ConfigPath = "kNicknameOptionsKey", DefaultValue = "NsPlayer"},
      kNicknameOptionsKey, "NsPlayer"
    },
     
    SoundVolume = {
      Type = "Slider",
      Width = 250,
      Height = 20,
      Position = {"Top", 30, 80, "Top"},
      Label = "Sound Volume",
      MinValue = 0,
      MaxValue = 100,
      ValueChanged = function(value, stillDragging) 
        Client.SetSoundVolume(value/100)
        PlayerUI_PlayButtonClickSound()
      end,
      ConfigDatabind = {ConfigPath = kSoundVolumeOptionsKey, DefaultValue = 90}
    },
    
    MusicVolume = {
      Type = "Slider",
      Width = 250,
      Height = 20,
      Position = {"Top", 30, 120, "Top"},
      Label = "Music Volume",
      MinValue = 0,
      MaxValue = 100,
      ValueChanged = function(value) 
        Client.SetMusicVolume(value/100)
      end,
      ConfigDatabind = {ConfigPath = kMusicVolumeOptionsKey, DefaultValue = 90}
    },
    
    VoiceVolume = {
      Type = "Slider",
      Width = 250,
      Height = 20,
      Position = {"Top", 30, 155, "Top"},
      Label = "Voice Volume",
      MinValue = 0,
      MaxValue = 100,
      ValueChanged = function(value, stillDragging) 
        Client.SetVoiceVolume(value/100)
      end,
      ConfigDatabind = {ConfigPath = kVoiceVolumeOptionsKey, DefaultValue = 90}
    },
    
    MouseSensitivity = {
      Type = "Slider",
      Width = 250,
      Height = 20,
      Position = {"Top", 30, 190, "Top"},
      Label = "Mouse Sensitivity",
      MinValue = 0,
      MaxValue = 2,
      StepSize = 0.01,
      ValueChanged = function(value, stillDragging, self) 
        self.Parent.SensitivityValue:SetText(string.format("%.5f", value))
      end,
      ConfigDatabind = {
        //We have to wrap these function in our own functions because they won't be loaded into Client libary at this early stage
        ValueGetter = function() return Client.GetMouseSensitivity() end, 
        ValueSetter = function(value) Client.SetMouseSensitivity(value) end, 
        DefaultValue = 1
      }
    },
    
    SensitivityValue = {
      Type = "TextBox",
      Width = 80,
      Height = 20,
      Position = {"Top", 200, 190, "Top"},
      ValueChanged = function(value, self) 
       self:SetText(string.format("%.5f", value))
      end
    },
    
    InvertMouse = {
      Type = "CheckBox",
      Position = {"Top", -90, 225, "Top"},
      Label = "Invert Mouse", 
      Checked = false, 
      LabelOnLeft = true,
      ConfigDatabind = {ConfigPath = kInvertedMouseOptionsKey, DefaultValue = false}
    },
    
    RawInput = {
      Type = "CheckBox",
      Position = {"Top", 80, 225, "Top"},
      Label = "Raw Mouse Input", 
      Checked = true,
      LabelOnLeft = true,
      ConfigDatabind = {ConfigPath = "input/mouse/rawinput",  DefaultValue = true},
      CheckChanged = function(checked)
        Shared.ConsoleCommand("i_rawinput "..tostring(checked))
      end
    },
    
    SkulkViewTilt = {
      Type = "CheckBox",
      Position = {"Top", -90, 260, "Top"},
      Label = "Disable Skulk View Tilt", 
      Checked = false,
      LabelOnLeft = true,
      ConfigDatabind = {ConfigPath = "DisableSkulkViewTilt", DefaultValue = false},
      CheckChanged = function(checked)
        if(OnCommandSkulkViewTilt) then
          OnCommandSkulkViewTilt(checked and "false") 
        end
      end,
    },
    
    Bloom = {
      Type = "CheckBox",
      Position = {"Top", 0, 300, "Top"},
      Label = "Bloom",
      LabelOnLeft = true,
      Checked = true,
      ConfigDatabind = {ConfigPath = "graphics/display/bloom", DefaultValue = true},
      CheckChanged = function(checked)
        Shared.ConsoleCommand("r_bloom "..tostring(checked))
      end
    },
    
    Antialiasing = {
      Type = "CheckBox",
      Position = {"Top", 140, 300, "Top"},
      Label = "Anti-aliasing",
      LabelOnLeft = true,
      Checked = true,
      ConfigDatabind = {ConfigPath = "graphics/display/antialiasing", DefaultValue = true},
      CheckChanged = function(checked)
        Shared.ConsoleCommand("r_aa "..tostring(checked))
      end
    },
    
    AtmosphericLights = {
      Type = "CheckBox",
      Position = {"Top", -90, 300, "Top"},
      Label = "Atmospheric Lights",
      LabelOnLeft = true,
      Checked = true,
      ConfigDatabind = {ConfigPath = "graphics/display/atmospherics", DefaultValue = true},
      CheckChanged = function(checked)
        Shared.ConsoleCommand("r_atmospherics "..tostring(checked))
      end
    },

    WindowMode = {
      Type = "ComboBox",
      Width = 185, 
      Height = 20, 
      Position = {"Top", -80, 340, "TopLeft"},
      ItemList = {"Fullscreen", "Windowed", "Windowed Fullscreen"},
      Label = "Display Mode",
    },
    
    ScreenRes = {
      Type = "ComboBox",
      Width = 180,
      Height = 20,
      Position = {"Top", -80, 375, "TopLeft"},
      LabelCreator = "ResToString",
      Label = "Resolution",
      ItemList = {},
    },
    
    VisualDetail = {
      Type = "ComboBox",
      Width = 200, 
      Height = 20,
      Position = {"Top", -80, 410, "TopLeft"}, 
      ItemList = "OptionsDialogUI_GetVisualDetailSettings",
      Label = "Visual Detail",
    },
    
    ApplyGFX = {
      Type = "UIButton",
      Width = 150, 
      Position = {"Top", 0, 450, "Top"}, 
      Label = "Apply Gfx Changes",
      ClickAction = "ApplyGFXChanges",
      
      ConfigDataBind = {
        ConfigPath = kDisplayQualityOptionsKey,
        DefaultValue = 0,
        DataType = "integer",
        DelaySave = true,
        ValueConverter = function(value, index)
          if(index) then
            return index-1
          else
            return value+1
          end
        end,
      }
    },
}


function OptionsPage:Initialize()
  BasePage.Initialize(self, 600, 500, self.PageName, "Options")
  BaseControl.Hide(self)
 
  ResHelper:Init()

  self:CreatChildControlsFromTable(self.ControlSetup)

  local topSpaceing = 35
  local sensitivityValue = self.SensitivityValue

  sensitivityValue:SetText(string.format("%.5f", Client.GetMouseSensitivity()))

  sensitivityValue.OnFocusLost = function() 
    local value = sensitivityValue:TryParseNumber(self.MouseSensitivity:GetValue(), 0.01, 2)
    
    if(value) then
      self.MouseSensitivity:SetValueAndTiggerEvent(value)
    end
    
    TextBox.OnFocusLost(sensitivityValue)
  end

  self.ScreenRes:SetItemList(ResHelper.DisplayModes)

  self.GFXOptionBindings = {}


   self.GFXOptionBindings[1] = self.WindowMode:SetConfigBinding({{kFullscreenOptionsKey, true},
                                                             {"borderless_window", false}}, self.WindowConfigConverter):SetDelaySave(true)


   self.GFXOptionBindings[2] = self.ScreenRes:SetConfigBinding({{kGraphicsXResolutionOptionsKey, 1280, "integer"},
                                                                {kGraphicsYResolutionOptionsKey, 800,  "integer"}}, self.ResConfigConverter):SetDelaySave(true)

/*
    self.GFXOptionBindings[3] = visualDetail:SetConfigBinding(kDisplayQualityOptionsKey, 0, "integer",
     function(value, index)
       if(index) then
         return index-1
       else
         return value+1
       end
    end):SetDelaySave(true)
*/    
  
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

function OptionsPage:ResToString(entry)
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

