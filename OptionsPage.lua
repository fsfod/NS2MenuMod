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

local kLoopingMenuSound = "sound/NS2.fev/common/menu_loop"
local kWindowOpenSound = "sound/NS2.fev/common/open"

OptionsPage.ControlSetup = {
    NickName = {
      Type = "TextBox",
      Width = 100,
      Height = 24,
      Position = {"Top", -76, 40, "Top"},
      Label = "Nickname",
      ConfigDataBind = {ConfigPath = kNicknameOptionsKey, DefaultValue = "NsPlayer"},
      kNicknameOptionsKey, "NsPlayer"
    },
    
    Hints = {
      Type = "CheckBox",
      Position = {"Top", 100, 40, "Top"},
      Label = "Show Hints", 
      Checked = true,
      LabelOnLeft = true,
      ConfigDataBind = {ConfigPath = "showHints", DefaultValue = true}
    },
    
    Hints = {
      Type = "CheckBox",
      Position = {"Top", 100, 60, "Top"},
      Label = "Disable Menu Ambient Sound", 
      Checked = false,
      LabelOnLeft = true,
      CheckChanged = function(checked)
        if(checked) then
          Shared.StopSound(nil, kLoopingMenuSound)
        else
          Shared.PlaySound(nil, kLoopingMenuSound)
        end
      end,
      ConfigDataBind = {
        TableKey = "DisableMenuAmbientSound", 
        Table = MainMenuMod,
        DefaultValue = false,
      }
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
      ConfigDataBind = {ConfigPath = kSoundVolumeOptionsKey, DefaultValue = 90}
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
      ConfigDataBind = {ConfigPath = kMusicVolumeOptionsKey, DefaultValue = 90}
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
      ConfigDataBind = {ConfigPath = kVoiceVolumeOptionsKey, DefaultValue = 90}
    },
    
    MouseSensitivity = {
      Type = "Slider",
      Width = 250,
      Height = 20,
      Position = {"Top", 30, 190, "Top"},
      Label = "Mouse Sensitivity",
      MinValue = 1,
      MaxValue = 20,
      StepSize = 0.1,
      ValueChanged = function(value, stillDragging, self) 
        self.Parent.SensitivityValue:SetText(string.format("%.5f", value))
      end,
      ConfigDataBind = {
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
       
    MouseAcceleration = {
      Type = "Slider",
      Width = 250,
      Height = 20,
      Position = {"Top", 30, 225, "Top"},
      Label = "Mouse Acceleration",
      MinValue = 1,
      MaxValue = 1.4,
      StepSize = function() return 0.4/100 end,
      ValueChanged = function(value, stillDragging, self)
        
        local accelerationValue = self.Parent.AccelerationValue
        
        //Shared.ConsoleCommand("i_accel "..tostring(checked))
        
        if(value <= 1) then
          accelerationValue:SetText("OFF")
          Client.SetOptionBoolean("input/mouse/acceleration", false)
        else
          Client.SetOptionBoolean("input/mouse/acceleration", true)
          accelerationValue:SetText(string.format("%.5f", value))
        end
      end,
      
      ConfigDataBind = {ConfigPath = "input/mouse/acceleration-amount", DefaultValue = 1},
    },
    
    AccelerationValue = {
      Type = "TextBox",
      Width = 80,
      Height = 20,
      Position = {"Top", 200, 225, "Top"},
      ValueChanged = function(value, self) 
        self:SetText(string.format("%.5f", value))
      end
    },
    
    InvertMouse = {
      Type = "CheckBox",
      Position = {"Top", -90, 260, "Top"},
      Label = "Invert Mouse", 
      Checked = false, 
      LabelOnLeft = true,
      ConfigDataBind = {ConfigPath = kInvertedMouseOptionsKey, DefaultValue = false}
    },
    
    RawInput = {
      Type = "CheckBox",
      Position = {"Top", 80, 260, "Top"},
      Label = "Raw Mouse Input", 
      Checked = true,
      LabelOnLeft = true,
      ConfigDataBind = {ConfigPath = "input/mouse/rawinput",  DefaultValue = true},
      CheckChanged = function(checked)
        Shared.ConsoleCommand("i_rawinput "..tostring(checked))
      end
    },
    
    SkulkViewTilt = {
      Type = "CheckBox",
      Position = {"Top", -90, 295, "Top"},
      Label = "Disable Skulk View Tilt", 
      Checked = false,
      LabelOnLeft = true,
      ConfigDataBind = {ConfigPath = "DisableSkulkViewTilt", DefaultValue = false},
      CheckChanged = function(checked)
        if(OnCommandSkulkViewTilt) then
          OnCommandSkulkViewTilt(checked and "false") 
        end
      end,
    },
    
    Bloom = {
      Type = "CheckBox",
      Position = {"Top", 0, 325, "Top"},
      Label = "Bloom",
      LabelOnLeft = true,
      Checked = true,
      ConfigDataBind = {ConfigPath = "graphics/display/bloom", DefaultValue = true},
      CheckChanged = function(checked)
        Render_SyncRenderOptions()
      end
    },
    
    Antialiasing = {
      Type = "CheckBox",
      Position = {"Top", 140, 325, "Top"},
      Label = "Anti-aliasing",
      LabelOnLeft = true,
      Checked = true,
      ConfigDataBind = {ConfigPath = "graphics/display/anti-aliasing", DefaultValue = true},
      CheckChanged = function(checked)
        Render_SyncRenderOptions()
      end
    },
    
    AtmosphericLights = {
      Type = "CheckBox",
      Position = {"Top", -90, 325, "Top"},
      Label = "Atmospheric Lights",
      LabelOnLeft = true,
      Checked = true,
      ConfigDataBind = {ConfigPath = "graphics/display/atmospherics", DefaultValue = true},
      CheckChanged = function(checked)
        Render_SyncRenderOptions()
      end
    },
    
    Shadows = {
      Type = "CheckBox",
      Position = {"Top", -90, 360, "Top"},
      Label = "Shadows",
      LabelOnLeft = true,
      Checked = true,
      ConfigDataBind = {ConfigPath = "graphics/display/shadows", DefaultValue = true},
      CheckChanged = function(checked)
        Render_SyncRenderOptions()
      end
    },
    
    Anisotropic = {
      Type = "CheckBox",
      Position = {"Top", 190, 360, "Top"},
      Label = "Anisotropic Filtering",
      LabelOnLeft = true,
      Checked = true,
      ConfigDataBind = {ConfigPath = "graphics/display/anisotropic-filtering", DefaultValue = true},
      CheckChanged = function(checked)
        Shared.ConsoleCommand("r_anisotropic "..tostring(checked))
      end
    },
    
    MulticoreRendering = {
      Type = "CheckBox",
      Position = {"Top", 190, 400, "Top"},
      Label = "Multicore Rendering",
      LabelOnLeft = true,
      Checked = true,
      ConfigDataBind = {ConfigPath = "graphics/multithreaded", DefaultValue = true},
      CheckChanged = function(checked)
        Shared.ConsoleCommand("r_mt "..tostring(checked))
      end
    },  

   Reflections = {
      Type = "CheckBox",
      Position = {"Top", 190, 435, "Top"},
      Label = "Reflections",
      LabelOnLeft = true,
      Checked = true,
      ConfigDataBind = {ConfigPath = "graphics/display/reflections", DefaultValue = true},
      CheckChanged = function(checked)
        Shared.ConsoleCommand("r_reflect "..tostring(checked))
      end
    },
    
    AmbientOcclusion = {
      Type = "ComboBox",
      Width = 100, 
      Height = 20,
      Position = {"Top", 230, 470, "Top"}, 
      ItemList = {"on", "medium", "high"},
      ItemLabels = {"Off", "Medium", "High"},
      Label = "Ambient Occlusion",

      ConfigDataBind = {ConfigPath = "graphics/display/ambient-occlusion", DefaultValue = "off"},
      
      ItemPicked = function(item, index)
        Render_SyncRenderOptions()
      end
    },
 
    TextureStreaming = {
      Type = "CheckBox",
      Position = {"Top", 190, 505, "Top"},
      Label = "Texture Streaming",
      LabelOnLeft = true,
      Checked = false,
      ConfigDataBind = {ConfigPath = "graphics/texture-streaming", DefaultValue = false},
    },

    WindowMode = {
      Type = "ComboBox",
      Width = 185, 
      Height = 20, 
      Position = {"Top", -180, 480, "TopLeft"},
      ItemLabels = {"Windowed", "Windowed(Fullscreen)", "Fullscreen"},
      ItemList = {"windowed", "fullscreen-windowed", "fullscreen"},
      Label = "Display Mode",
    },
    
    ScreenRes = {
      Type = "ComboBox",
      Width = 180,
      Height = 20,
      Position = {"Top", -180, 520, "TopLeft"},
      LabelCreator = "ResToString",
      Label = "Resolution",
      ItemList = {},
    },
    
    VisualDetail = {
      Type = "ComboBox",
      Width = 200, 
      Height = 20,
      Position = {"Top", -180, 560, "TopLeft"}, 
      ItemList = "OptionsDialogUI_GetVisualDetailSettings",
      Label = "Visual Detail",

      ConfigDataBind = {
        ConfigPath = kDisplayQualityOptionsKey,
        DefaultValue = 0,
        DataType = "integer",
        DelaySave = true,
        ItemLabels = {"Low", "Medium", "High"},
        ValueConverter = function(value, index)
          if(index) then
            return index-1
          else
            return value+1
          end
        end,
      }
    },
    
    ApplyGFX = {
      Type = "UIButton",
      Width = 150, 
      Position = {"Top", -100, 600, "Top"}, 
      Label = "Apply Gfx Changes",
      ClickAction = "ApplyGFXChanges",
    },
}


function OptionsPage:Initialize()
  BasePage.Initialize(self, 600, 700, self.PageName, "Options")
  BaseControl.Hide(self)
 
  ResHelper:Init()

  self:CreatChildControlsFromTable(self.ControlSetup)

  local topSpaceing = 35
  local sensitivityValue = self.SensitivityValue

  sensitivityValue:SetText(string.format("%.5f", Client.GetMouseSensitivity()))

  sensitivityValue.OnFocusLost = function() 
    local value = sensitivityValue:TryParseNumber(self.MouseSensitivity:GetValue(), 0, 20)
    
    if(value) then
      self.MouseSensitivity:SetValueAndTiggerEvent(value)
    end
    
    TextBox.OnFocusLost(sensitivityValue)
  end
  
  local accelerationValue = self.AccelerationValue
  
  accelerationValue.OnFocusLost = function() 
    local value = accelerationValue:TryParseNumber(1, 1, 1.4)
    
    if(value) then
      self.MouseAcceleration:SetValueAndTiggerEvent(value)
    end
    
    TextBox.OnFocusLost(accelerationValue)
  end

  self.MouseAcceleration:ReloadConfigValue()

  self.ScreenRes:SetItemList(ResHelper.DisplayModes)

  self.GFXOptionBindings = {}

  self.GFXOptionBindings[1] = self.WindowMode:SetConfigBinding(kWindowModeOptionsKey, "windowed"):SetDelaySave(true)

  self.GFXOptionBindings[2] = self.ScreenRes:SetConfigBinding({{kGraphicsXResolutionOptionsKey, 1280, "integer"},
                                                              {kGraphicsYResolutionOptionsKey, 800,  "integer"}}, self.ResConfigConverter):SetDelaySave(true)

  self.GFXOptionBindings[3] = self.VisualDetail.ConfigBinding

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

  Client.ReloadGraphicsOptions()

  if(GetIsBorderless) then
    UIHelper:ReSetBorderless()
  end

  //ChangeUIScale()
end

local windowedModes = {
  "windowed", 
  "fullscreen", 
  "fullscreen-windowed",
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

