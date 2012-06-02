EngineBuild = 208
ValidVM = "main_client"
ModTableName = "MainMenuMod"
MountSource = true

MainScript = "GUIMainMenu.lua"

ScriptList = {
  "MainMenuMod.lua",
  "GUIMainMenu.lua",
  "MainPage.lua",
  "ConnectedInfo.lua",
  "ServerBrowserPage.lua",
  "ServerInfoWindow.lua",
  "KeybindPage.lua",
  "OptionsPage.lua",
  "MapList.lua",
  "CreateServerPage.lua",
  "OptionsPageSelector.lua",
  "ModsPage.lua",
  "ClassicMenu.lua"
}

Dependencies = {
  "BaseUIControls",
}

SavedVaribles = {
  "KnownServers",
  "ServerBrowser_Settings",
}