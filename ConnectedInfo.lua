
ConnectedInfo = {
  ConnectedAddress = "",
}

function ConnectedInfo:SetServerInfo(serverInfo) 

  assert(serverInfo and type(serverInfo) == "table")

  self.ServerInfo = table.duplicate(serverInfo)
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
  GameGUIManager:CreateFrame("ScoreboardServerInfo")
end

function ConnectedInfo.Disconnected()
  
end

Event.Hook("ClientDisconnected", ConnectedInfo.Disconnected)
Event.Hook("ClientConnected", ConnectedInfo.Connected)

ClassHooker:HookFunction("Client", "Connect", ConnectedInfo, "Connecting")


ControlClass("ScoreboardServerInfo", BaseControl)

function ScoreboardServerInfo:Initialize()
  BaseControl.Initialize(self, 100, 20)
  
  self:SetupHitRec()
  
  self:SetPoint("Top", 0, 35, "Top")
  
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