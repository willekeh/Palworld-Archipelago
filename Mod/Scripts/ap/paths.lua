local paths = {}
-- Get paths for different folders
function paths.folderFromSource(source)
    if type(source) == "string" and source:sub(1, 1) == "@" then
        local scriptPath = (source:sub(2):gsub("\\", "/"))
        local modFolder = scriptPath:match("^(.*)/Scripts/ap/paths%.lua$")
        if modFolder then
            return modFolder .. "/"
        end
    end
end

local modFolder = paths.folderFromSource(debug.getinfo(1, "S").source)

paths.dllFolder = modFolder .. "Scripts/library/"
paths.logFile = modFolder .. "logs/ap.log"
paths.cacheFolder = modFolder .. "cached/"

return paths
