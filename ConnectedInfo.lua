//
//   Created by:   fsfod
//

ConnectedInfo = {
  ConnectedAddress = "",
}

local serverInfoFields = {
  "Address",
  "Name",
}

function ConnectedInfo:OnClientLoadComplete()

  ClassHooker:HookFunction("Client", "Connect", self, "Connecting", InstantHookFlag)

  if(StartupLoader.IsMainVM) then
    return
  end

  local time = Shared.GetSystemTime()
  
  local timestamp = Client.GetOptionInteger("menumod/ConnectedInfo/TimeStamp", 0)
  
  if(timestamp ~= 0 and (time-timestamp) < 240) then
    
    local serverInfo = {
      QueryPort = Client.GetOptionInteger("menumod/ConnectedInfo/QueryPort", 27016),
      Passworded = Client.GetOptionBoolean("menumod/ConnectedInfo/Passworded", false),
    }
    
    for i,fieldName in ipairs(serverInfoFields) do
      serverInfo[fieldName] = Client.GetOptionString("menumod/ConnectedInfo/"..fieldName, "")
    end
    
    self.ServerInfo = serverInfo
    
    self.ConnectedAddress = serverInfo.Address
  end
  
  GameGUIManager:CreateFrame("ScoreboardServerInfo")
end

function ConnectedInfo:SetServerInfo(serverInfo) 

  assert(serverInfo and type(serverInfo) == "table")

  self.ServerInfo = table.duplicate(serverInfo)
  
  for i,fieldName in ipairs(serverInfoFields) do
    Client.SetOptionString("menumod/ConnectedInfo/"..fieldName, tostring(self.ServerInfo[fieldName] or ""))
  end
  
  Client.SetOptionInteger("menumod/ConnectedInfo/QueryPort", self.ServerInfo.QueryPort or 27016)
  Client.SetOptionBoolean("menumod/ConnectedInfo/Passworded", self.ServerInfo.Passworded )
  
  Client.SetOptionInteger("menumod/ConnectedInfo/TimeStamp", Shared.GetSystemTime())
end

function ConnectedInfo:ConnectToServer(serverInfo, password)

  if(serverInfo.Passworded and not password) then
    GUIMenuManager:CreateWindow("ServerPasswordPrompt", serverInfo, self)
   return
  end

  self:SetServerInfo(serverInfo)

  self.ServerInfo = table.duplicate(serverInfo)

  //MapList:CheckMountMap(serverInfo.Map)

  MainMenu_SBJoinServer(serverInfo.Address, password)
end

function ConnectedInfo:GetConnectedServerName()

  if(self:HasServerName()) then
    return self.ServerInfo.Name
  end

  return self.ConnectedAddress
end

function ConnectedInfo:HasServerName()
  return self.ServerInfo and self.ConnectedAddress == self.ServerInfo.Address
end

function ConnectedInfo:GetConnectedAddress()
  return self.ConnectedAddress
end

function ConnectedInfo:Connecting(address)

  if(not address or type(address) ~= "string") then
    return
  end

  self.ConnectedAddress = address
end

function ConnectedInfo:Connected()
  
end

function ConnectedInfo.Disconnected()
  
end

Event.Hook("ClientDisconnected", ConnectedInfo.Disconnected)
Event.Hook("ClientConnected", ConnectedInfo.Connected)

ControlClass("ScoreboardServerInfo", BaseControl)

function ScoreboardServerInfo:Initialize()
  BaseControl.Initialize(self, 100, 20)
  
  self:SetupHitRec()
  
  self:SetPoint("Top", 100, 35, "Top")
  
  self:SetColor(Color(0, 0, 0, 0))

  local text = string.format("Server: %s", ConnectedInfo:GetConnectedServerName())

  local info = self:CreateFontString(20, "Center")
   info:SetText(text)
   info:SetIsVisible(false)
   info:SetTextAlignmentX(GUIItem.Align_Center)
   info:SetTextAlignmentX(GUIItem.Align_Center)
  self.Info = info
  
  self.InfoShown = false
end

function ScoreboardServerInfo:Update()
  local showInfo = ScoreboardUI_GetVisible()
  
  if(showInfo and not self.InfoShown) then
    self.Info:SetIsVisible(true)
    self.InfoShown = true
  elseif(not showInfo and self.InfoShown) then
    self.Info:SetIsVisible(false)
    self.InfoShown = false
  end
end