MainMenuMod = {
  DisableMenuCinematic = true
}

ClassHooker:Mixin("MainMenuMod")

function MainMenuMod:OnLoad()
  ClassHooker:SetClassCreatedIn("MenuManager")
  self:SetHooks()
  
  self.PageCreators = {
   ServerBrowser = ServerBrowserPage,
   Main = MenuMainPage,
  }
  
  Event.Hook("Console_flashmenu", function() self:SwitchToFlash() end)
  Event.Hook("Console_newmenu", function() self:DisableFlashMenu() end)
end

function MainMenuMod:SetHooks()
  self:RemoveAllHooks()
  
  self:HookLibraryFunction(HookType.Replace, "MenuManager", "SetMenu")
  //uncomment to disable menu cinematic
  //self:HookLibraryFunction(HookType.Raw, "MenuManager", "SetMenuCinematic")
  self:HookFunction("LeaveMenu")
  self:ReplaceFunction("ShowInGameMenu")
  self:ReplaceFunction("MainMenu_SetAlertMessage")
  
  //self:HookLibraryFunction(HookType.Replace, "MenuManager", "PlayMusic", function() end)
end

function MainMenuMod:OnClientLuaFinished()

  //local arch = NS2_IO.OpenArchive("Mods/GUIMainMenu/Textures.rar")

  //NS2_IO.MountArchiveFile(arch, "options.dds", "ui/options.dds")
  //NS2_IO.MountArchiveFile(arch, "join.dds", "ui/join.dds")
  //NS2_IO.MountArchiveFile(arch, "exitgame.dds", "ui/exitgame.dds")
  //NS2_IO.MountArchiveFile(arch, "createserver.dds", "ui/createserver.dds")
  
  self.MainMenu = GetGUIManager():CreateGUIScript("GUIMainMenu")
  MainMenu_Loaded()
  
  //self:SwitchToPage("ServerBrowser")
end

function MainMenuMod:SetMenuCinematic(cinematic)
  
  if(self.DisableMenuCinematic) then
    return nil
  end
  
  return cinematic
end

function MainMenuMod:MainMenu_SetAlertMessage(msg)
  self:ShowMenu()
  
  self.MainMenu.MainPage:UpdateButtons()
  self.MainMenu:ShowMessage(msg)
  
  MainMenu_Loaded()
end

function MainMenuMod:ShowInGameMenu()

  if not Shared.GetIsRunningPrediction() then
    Client.SetCursor("ui/Cursor_MenuDefault.dds")
    Client.SetMouseVisible(true)
    Client.SetMouseCaptured(false)
    
    self:ShowMenu()
  end
end

function MainMenuMod:LeaveMenu()
  self.MainMenu:Hide()
end

function MainMenuMod:SetMenu(filename)
  if(filename) then
    //GetGUIManager and the local value it returns is not yet created just have to wait for client.lua to finish
  end
end

function MainMenuMod:IsMenuOpen()
  return not self.MainMenu.Hidden
end

function MainMenuMod:ShowMenu()
  if(not self:IsMenuOpen()) then
    self.MainMenu:Show()
  end
end

function MainMenuMod:DisableFlashMenu()

  MenuManager.SetMenu(nil)

  self:SetHooks()
  self:ShowMenu()
  
  self.MainMenu:ReturnToMainPage()
  
  self.Flashmenu = false
  
  Client.SetCursor("ui/Cursor_MenuDefault.dds")
  Client.SetMouseVisible(true)
  Client.SetMouseCaptured(false)
end

function MainMenuMod:SwitchToFlash()
  self.MainMenu:Hide()
  self:RemoveAllHooks()
  
  self:HookLibraryFunction(HookType.Replace, "MenuManager", "PlayMusic", function() end)
  
  MenuManager.SetMenu(kMainMenuFlash)
  self.Flashmenu = true
  
  Client.SetCursor("ui/Cursor_MenuDefault.dds")
  Client.SetMouseVisible(true)
  Client.SetMouseCaptured(false)
end

function MainMenuMod:Disconnected()
  
end

function MainMenuMod:SwitchToPage(page)
  self.MainMenu:SwitchToPage(page)
end