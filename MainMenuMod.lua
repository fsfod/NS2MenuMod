
local HotReload = MainMenuMod

if(not MainMenuMod) then
  
MainMenuMod = {
  DisableMenuCinematic = true,
  PageInfos = {},
  OptionPageList = {},
  
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
  
  if(not NS2_IO) then
    Script.Load("lua/KeyBindInfo.lua")
    Script.Load("lua/InputKeyHelper.lua")
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
  
  self:HookLibraryFunction(HookType.Replace, "MenuManager", "GetMenu", function() return (self:IsMenuOpen() and "") or nil end)
  
  //self:HookLibraryFunction(HookType.Replace, "MenuManager", "PlayMusic", function() end)
end

function MainMenuMod:OnClientLuaFinished()
  self:RegisterDefaultPages()
  
  self.MainMenu = GetGUIManager():CreateGUIScript("GUIMainMenu")
  MainMenu_Loaded() 
  //self:SwitchToPage("ServerBrowser")
end

function MainMenuMod:GetPageInfo(name)
  return self.PageInfos[name]
end

function MainMenuMod:RegisterDefaultPages()

  for pageName, className in pairs(self.DefaultPages) do
    if(not self.PageInfos[pageName]) then
      self.PageInfos[pageName] = {Name = pageName, ClassName = className, OptionPage = false}
    end
  end
  
  self:RegisterOptionPage("MainOptions", "Options", "OptionsPage")
  self:RegisterOptionPage("Keybinds", "Keybinds", "KeybindPage")
  self:RegisterOptionPage("Mods", "Mods", "ModsPage")
end

function MainMenuMod:RegisterOptionPage(name, label, className)

  if(self.PageInfos[name]) then
    error("RegisterOptionPage: error a page named "..name.." already exists")
  end

  if(not className) then
    className = name
  end

  if(not label) then
    label = name
  end

  local entry = {Name = name, Label = label, ClassName = className, OptionPage = true}
  
  self.PageInfos[name] = entry
  
  self.OptionPageList[#self.OptionPageList+1] = name
end

function MainMenuMod:SetMenuCinematic(cinematic)
  
  if(self.DisableMenuCinematic) then
    return nil
  end
  
  return cinematic
end

function MainMenuMod:MainMenu_SetAlertMessage(msg)
  self:ShowMenu() 
  MouseStateTracker:ClearStack()
  
  self.MainMenu.MainPage:UpdateButtons()
  self.MainMenu:ShowMessage(msg)
  
  MainMenu_Loaded()
end

function MainMenuMod:ShowInGameMenu()
  if not Shared.GetIsRunningPrediction() then
    self:ShowMenu()
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
  self.MainMenu:Hide()
  MouseStateTracker:ClearMainMenuState()
end

function MainMenuMod:SetMenu(filename)
  if(filename) then
    //GetGUIManager and the local value it returns is not yet created just have to wait for client.lua to finish
  end
end

function MainMenuMod:IsMenuOpen()
  return not self.MainMenu.Hidden
end

function MainMenuMod:ShowMessageBox(msgBox)
  self.MainMenu:ShowMessageBox(msgBox)
end

function MainMenuMod:ShowMenu()
  if(not self:IsMenuOpen()) then
    self.MainMenu:Show()
    
    MouseStateTracker:SetMainMenuState()
  end
end

function MainMenuMod:DisableFlashMenu()

  MenuManager.SetMenu(nil)

  self:SetHooks()
  self:ShowMenu()
  
  self.MainMenu:ReturnToMainPage()
  
  self.Flashmenu = false
end

function MainMenuMod:SwitchToFlash()
  self.MainMenu:Hide()
  self:RemoveAllHooks()
  
  self:HookLibraryFunction(HookType.Replace, "MenuManager", "PlayMusic", function() end)
  
  MenuManager.SetMenu(kMainMenuFlash)
  self.Flashmenu = true
end

function MainMenuMod:Disconnected()
  
end

function MainMenuMod:ReturnToMainPage()
  self.MainMenu:ReturnToMainPage()
end

function MainMenuMod:SwitchToPage(page)
  self.MainMenu:SwitchToPage(page)
end

function MainMenuMod:RecreatePage(pageName)
  self.MainMenu:RecreatePage(pageName)
end

if(HotReload) then
  MainMenuMod:SetHooks()
else
  Event.Hook("Console_menulayer", function()
    MainMenuMod.MainMenu.RootFrame:SetLayer(GUIMainMenu.MenuLayer)
  end)
end