
local HotReload = MainMenuMod

if(not MainMenuMod) then
  
MainMenuMod = {
  DisableMenuCinematic = true,
  
  DefaultPages = {
    ServerBrowser = "ServerBrowserPage",
    Main = "MenuMainPage",
    CreateServer = "CreateServerPage",
  },
}

end

ClassHooker:Mixin("MainMenuMod")


function MainMenuMod:OnLoad()
  ClassHooker:SetClassCreatedIn("MenuManager")
  self:SetHooks()
  
  if(not ModLoader:IsModEnabled("keybinds")) then
    Script.Load("Mods/Keybinds/KeyBindInfo.lua")
  end
  
  self:RegisterDefaultPages()
end

function MainMenuMod:OnClientLoadComplete(disconnectMsg)

  self:SetSkulkViewTilt()

  if not Client.GetOptionBoolean("graphics/display/bloom", true) then
    Shared.ConsoleCommand("r_bloom false")
  end 
  
  MainMenu_GetIsOpened = function()
    return GUIMenuManager:IsMenuOpen()
  end
end

function MainMenuMod:SetSkulkViewTilt()
  
  if(OnCommandSkulkViewTilt) then
    OnCommandSkulkViewTilt(Client.GetOptionBoolean("DisableSkulkViewTilt", false) and "false")
  end
end

function MainMenuMod:SetHooks()
  self:RemoveAllHooks()
/*
  self:HookLibraryFunction(HookType.Replace, "MenuManager", "SetMenu")
  

  self:ReplaceFunction("ShowInGameMenu")
  
  self:ReplaceFunction("MainMenu_SetAlertMessage")
  
  self:HookLibraryFunction(HookType.Replace, "MenuManager", "GetMenu", function() return (GUIMenuManager:IsMenuOpen() and "") or nil end)
  */
end

function MainMenuMod:RegisterDefaultPages()

  for pageName, className in pairs(self.DefaultPages) do
    GUIMenuManager:RegisterPage(pageName, nil, className)
  end
  
  GUIMenuManager:RegisterOptionPage("MainOptions", "Options", "OptionsPage")
  GUIMenuManager:RegisterOptionPage("Keybinds", "Keybinds", "KeybindPage")
  GUIMenuManager:RegisterOptionPage("Mods", "Mods", "ModsPage")
end


function MainMenuMod:MainMenu_SetAlertMessage(msg)
  GUIMenuManager:ShowMenu()
  
  GUIMenuManager:ShowMessage("Disconnected from server", msg)
  
  MouseStateTracker:ClearStack()

  //self.MainMenu.MainPage:UpdateButtons()
  //self.MainMenu:ShowMessage(msg)

  MainMenu_Loaded()
end

function MainMenuMod:ShowMenu()
  GUIMenuManager:ShowMenu()
end



if(HotReload) then
  MainMenuMod:SetHooks()
end