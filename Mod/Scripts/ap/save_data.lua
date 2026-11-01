local archipelagoClient = require("ap.ap_client")
local paths = require("ap.paths")
local logger = require("ap.log")


local saveData = {}

local announcedPals = {}
local currentSaveId = nil

-- This was writen by AI
local function sanitize(text)
    return (tostring(text):gsub("[^%w_%-]", "_"))
end

local function getSaveFilePath(saveId)
    return paths.cacheFolder .. saveId .. ".data"
end

local function readSaveFile(saveId)
    local loadedPals = {}
    local saveFile = io.open(getSaveFilePath(saveId), "r")
    if saveFile then
        for line in saveFile:lines() do
            local palName = line:gsub("\r", ""):match("^pal (.+)$")
            if palName then
                loadedPals[palName] = true
            end
        end
        saveFile:close()
    end
    return loadedPals
end

local function appendToSaveFile(saveId, palName)
    local saveFile = io.open(getSaveFilePath(saveId), "a")
    if not saveFile then
        logger.write("could not write " .. getSaveFilePath(saveId))
        return
    end
    saveFile:write("pal " .. palName .. "\n")
    saveFile:close()
end

local function buildSaveId()
    local seedText = nil
    for _, getterName in ipairs({ "get_seed", "get_seed_name" }) do
        local lookupSucceeded, seed = pcall(function()
            return archipelagoClient.nativeClient[getterName](archipelagoClient.nativeClient)
        end)
        if lookupSucceeded and seed and tostring(seed) ~= "" then
            seedText = tostring(seed)
            break
        end
    end
    local slotText = tostring(archipelagoClient.connection.slotName)
    if seedText then
        return sanitize(seedText) .. "_" .. sanitize(slotText)
    end
    logger.write("no seed name available, saving per connection instead")
    return sanitize(archipelagoClient.connectionKey)
end

saveData.buildSaveId = buildSaveId
saveData.getFilePath = getSaveFilePath

function saveData.isAnnounced(palName)
    return announcedPals[palName] == true
end

function saveData.markAnnounced(palName)
    if announcedPals[palName] then
        return
    end
    announcedPals[palName] = true
    if currentSaveId then
        appendToSaveFile(currentSaveId, palName)
    end
end

archipelagoClient:onSlotConnected(function()
    local newSaveId = buildSaveId()
    local loadedPals = readSaveFile(newSaveId)

    if currentSaveId == nil then
        for palName in pairs(announcedPals) do
            if not loadedPals[palName] then
                loadedPals[palName] = true
                appendToSaveFile(newSaveId, palName)
            end
        end
    end

    announcedPals = loadedPals
    currentSaveId = newSaveId
    logger.write("pal announcements loaded for " .. newSaveId)
end)

return saveData
