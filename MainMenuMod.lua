
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
    Script.Load("Mods/Keybinds/InputKeyHelper.lua")
  end
  
  Event.Hook("Console_flashmenu", function() self:SwitchToFlash() end)
  Event.Hook("Console_newmenu", function() self:DisableFlashMenu() end)
  
  Event.Hook("Console_showmenu", function() self:ShowMenu() end)
  Event.Hook("Console_hidemenu", function() self:CloseMenu() end)
end

function MainMenuMod:SetHooks()
  self:RemoveAllHooks()
  
  self:HookLibraryFunction(HookType.Replace, "MenuManager", "SetMenu")
  //uncomment to disable menu cinematic
  //self:HookLibraryFunction(HookType.Raw, "MenuManager", "SetMenuCinematic")
  self:HookFunction("LeaveMenu")
  self:ReplaceFunction("ShowInGameMenu")
  self:ReplaceFunction("MainMenu_SetAlertMessage")
  
  self:HookLibraryFunction(HookType.Replace, "MenuManager", "GetMenu", function() return (GUIMenuManager:IsMenuOpen() and "") or nil end)
  
  //self:HookLibraryFunction(HookType.Replace, "MenuManager", "PlayMusic", function() end)
end

function MainMenuMod:OnClientLuaFinished()
  self:RegisterDefaultPages()
  
  GUIMenuManager:ShowMenu()
  MainMenu_Loaded() 
  //self:SwitchToPage("ServerBrowser")
end

function MainMenuMod:RegisterDefaultPages()

  for pageName, className in pairs(self.DefaultPages) do
    GUIMenuManager:RegisterPage(pageName, nil, className)
  end
  
  GUIMenuManager:RegisterOptionPage("MainOptions", "Options", "OptionsPage")
  GUIMenuManager:RegisterOptionPage("Keybinds", "Keybinds", "KeybindPage")
  GUIMenuManager:RegisterOptionPage("Mods", "Mods", "ModsPage")
end


function MainMenuMod:SetMenuCinematic(cinematic)
  
  if(self.DisableMenuCinematic) then
    return nil
  end
  
  return cinematic
end

function MainMenuMod:MainMenu_SetAlertMessage(msg)
  GUIMenuManager:ShowMenu(msg)
  MouseStateTracker:ClearStack()

  //self.MainMenu.MainPage:UpdateButtons()
  //self.MainMenu:ShowMessage(msg)

  MainMenu_Loaded()
end

function MainMenuMod:ShowInGameMenu()
  if not Shared.GetIsRunningPrediction() then
    GUIMenuManager:ShowMenu()
  end
end

function MainMenuMod:CloseMenu()
  if(Client.GetIsConnected()) then
    MainMenu_ReturnToGame()
  else
    LeaveMenu()
  end
end

function MainMenuMod:LeaveMenu() 
  GUIMenuManager:CloseMenu()
end

function MainMenuMod:SetMenu(filename)
  if(filename) then
    //GetGUIManager and the local value it returns is not yet created just have to wait for client.lua to finish
  end
end

function MainMenuMod:ShowMenu()
  GUIMenuManager:ShowMenu()
end

function MainMenuMod:DisableFlashMenu()

  MenuManager.SetMenu(nil)

  self:SetHooks()
  self:ShowMenu()
  
  //GUIMenuManager:ReturnToMainPage()
  
  self.Flashmenu = false
end

function MainMenuMod:SwitchToFlash()
  GUIMenuManager:CloseMenu()
  self:RemoveAllHooks()
  
  self:HookLibraryFunction(HookType.Replace, "MenuManager", "PlayMusic", function() end)
  
  MenuManager.SetMenu(kMainMenuFlash)
  self.Flashmenu = true
end


if(HotReload) then
  MainMenuMod:SetHooks()
end