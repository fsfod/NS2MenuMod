MapList = {}

function MapList:Init()
  if(not self.Maps) then
    self:RefreshMapList()
  end
end

function MapList:RefreshMapList()
  
  local maps = {}
 
  if(NS2_IO) then
    local SupportedArchives = NS2_IO.GetSupportedArchiveFormats()

    for MapName,_ in pairs(NS2_IO.FindFiles("/maps/", "*.level*")) do
      local ext = GetExtension(MapName)
      local name, ArchiveExt

      if(ext ~= "level") then
        local dot = string.find(MapName, ".level")
        name = string.sub(MapName, 0, dot-1)
        
        ArchiveExt = string.sub(MapName, dot+6)
        
        if(not SupportedArchives[ArchiveExt]) then
					name = nil
        end
      else
        name = string.sub(MapName, 0, #MapName-6)
      end
      
	  	if(name and MapName ~= "menu.level") then
	  		maps[#maps+1] = { ["name"] = name, fileName = MapName, archiveType = ArchiveExt }
	  	end
    end
  else
    local matchingFiles = {}
    
    Shared.GetMatchingFileNames("maps/*.level", false, matchingFiles)

    for _, mapFile in pairs(matchingFiles) do
      local _, _, mapname = string.find(mapFile, "maps/(.*).level")
      
      if mapname ~= "menu" and mapname ~= "cinematic_tutorial" then
        table.insert(maps, {["name"] = mapname, fileName = mapname..".level"})
      end
    end
  end
  
  self.Maps = maps
end

function MapList:GetFileEntryIndex(name)
  
  for i,entry in ipairs(self.Maps) do
    if(entry.fileName == name) then
      return i
    end
  end
  
  return nil
end
  
function MapList:CheckMountMap(name)
  
  local entry = self:GetMapEntry(name)
  
  if(entry and entry.archiveType) then
   local archive = NS2_IO.OpenArchive("maps/"..fileName)
   
    if(not archive:FileExists("maps/"..fileName)) then
      error("could not find matching map with the same name as the archive")
    end
   
    NS2_IO.MountMapArchive(archive)

    self.MapArchive = archive
  end
end