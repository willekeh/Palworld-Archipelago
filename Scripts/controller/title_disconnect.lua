local UEHelpers = require("UEHelpers")
local archipelagoClient = require("ap.ap_client")
local logger = require("ap.log")

--Only this function was writen by AI
local function onReturnToTitle(source)
    if archipelagoClient.nativeClient or archipelagoClient.isClientCreationPending then
        logger.writeToFile("returned to the title screen (" .. source .. ")")
        archipelagoClient:disconnect()
    end
end

local titleFunctions = {
    "/Script/Pal.PalGameModeLogin:GoToTitle",       -- multiplayer, idk if this works. Coudnt test it
    "/Script/Pal.PalGameInstance:GoToDefaultMap",   -- Found by looking at Quick Connect Manager
}

-- Found by looking at Quick Connect Manager
local TITLE_MAP = "/Game/Pal/Maps/Title/PL_Title"
local POLL_MS = 1000

local lastWorldName = nil

local function getWorldName()
    local lookupSucceeded, worldName = pcall(function()
        local world = UEHelpers.GetWorld()
        if not (world and world:IsValid()) then
            return nil
        end
        return tostring(world:GetFullName())
    end)
    if lookupSucceeded then
        return worldName
    end
    return nil
end

local function checkTitleMap()
    local worldName = getWorldName()
    if worldName ~= lastWorldName then
        lastWorldName = worldName
        logger.writeToFile("world changed: " .. tostring(worldName))
    end
    if worldName and worldName:find(TITLE_MAP, 1, true) then
        onReturnToTitle("title map loaded")
    end
end

-- had to loop it otherwise would break after 1 time disconnecting and reconnecting
local lastLoggedCheckError = nil
LoopInGameThreadWithDelay(POLL_MS, function()
    local checkSucceeded, checkError = pcall(checkTitleMap)
    if not checkSucceeded and checkError ~= lastLoggedCheckError then
        lastLoggedCheckError = checkError
        logger.writeToFile("title map check failed: " .. tostring(checkError))
    end
    return false
end)

for _, functionPath in ipairs(titleFunctions) do
    local hookSucceeded, errorMessage = pcall(RegisterHook, functionPath, function()
        onReturnToTitle(functionPath)
    end)
    if not hookSucceeded then
        logger.writeToFile("could not hook " .. functionPath .. ": " .. tostring(errorMessage))
    end
end
