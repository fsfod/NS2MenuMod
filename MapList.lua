
if(not MapList) then
  MapList = {}
end

function MapList:Init()
  if(not self.Maps) then
    self:RefreshMapList()
  end
end

function MapList:RefreshMapList()
  
  local maps = {}
 
  if(NS2_IO) then
    local SupportedArchives = NS2_IO.GetSupportedArchiveFormats()

    for MapName,_ in pairs(NS2_IO.FindFiles("/maps/", "*")) do
      
      local fileExtension = GetExtension(MapName)
      local name = GetFileNameWithoutExt(MapName)

      if(fileExtension ~= ".level") then
        
        if(not SupportedArchives[fileExtension]) then
					name = nil
        end
        
      else
        name = string.sub(MapName, 0, #MapName-6)
        fileExtension = nil
      end
      
	  	if(name and MapName ~= "menu.level") then
	  		maps[#maps+1] = { ["name"] = name, fileName = MapName, archiveType = fileExtension }
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
  
  self:AddModMaps(maps)
  
  table.sort(maps, function(map1, map2) 
    return map1.name > map2.name
  end)
  
  self.Maps = maps
end

function MapList:AddModMaps(mapList)
  
  local numMods = Client.GetNumMods()
  for i = 1, numMods do
  
      local state = Client.GetModState(i)
      local name  = Client.GetModTitle(i)
      local kind  = Client.GetModKind(i)
      
      if kind == Client.ModKind_Level and state == Client.ModVersionState_UpToDate then
        table.insert(mapList, {modId = i, displayName = "Mod: "..name,  ["name"] = name, fileName = name..".level"})       
      end
  
  end
  
end

function MapList:GetFileEntryIndex(name)
  
  for i,entry in ipairs(self.Maps) do
    if(entry.fileName == name) then
      return i
    end
  end
  
  return nil
end

function MapList:GetEntry(name)
  
  for i,entry in ipairs(self.Maps) do
    if(entry.name == name) then
      return entry
    end
  end
  
  return nil
end

function MapList:CheckMountMap(name)
  
  self:RefreshMapList()
  
  local entry = self:GetEntry(name)
  
  if(not entry) then
    error("there is no map named named "..name)
  end
    
  if(entry and entry.archiveType) then
   local archive = NS2_IO.OpenArchive("maps/"..entry.fileName)
   
    if(archive:FileExists("ns2/maps/"..name..".level")) then
      archive:MountFiles("ns2/", "")
    else
      
      local folders = archive:FindDirectorys("", "*")
      local mapsPath = "/maps/"
      
      if(#folders == 1) then
        
        if(archive:FileExists(string.format("%s/%s.level", folders[1], name))) then
          mapsPath = folders[1].."/"
        else
          if(archive:DirectoryExists(folders[1].."/maps")) then
            mapsPath = folders[1].."/maps/"
          elseif(archive:DirectoryExists(folders[1].."ns2/maps")) then
            mapsPath = folders[1].."/ns2/maps/"
          end
        end

        if(not archive:FileExists(mapsPath..name..".level")) then
          error("could not find matching map with the same name as the archive")
        end
          
        archive:MountFiles(mapsPath, "/maps")
      else
      
        if(not archive:FileExists(mapsPath..name..".level")) then
          error("could not find matching map with the same name as the archive")
        end
      
        NS2_IO.MountMapArchive(archive)
      end
    end

    self.MapArchive = archive
  end
end