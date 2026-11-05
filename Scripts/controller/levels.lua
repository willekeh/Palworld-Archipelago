local chatView = require("view.chat_view")
local locationReporter = require("controller.location_reporter")

local pollIntervalMilliseconds = 2000
local lastKnownLevel = nil

-- Send level ups 
LoopInGameThreadWithDelay(pollIntervalMilliseconds, function()
    local playerCharacter = FindFirstOf("PalPlayerCharacter")
    if not (playerCharacter and playerCharacter:IsValid()) then
        return false
    end

    local characterParameterComponent = playerCharacter:GetCharacterParameterComponent()
    local individualParameter = characterParameterComponent and characterParameterComponent:IsValid() and characterParameterComponent:GetIndividualParameter()

    if not (individualParameter and individualParameter:IsValid()) then
        return false
    end

    local currentLevel = individualParameter:GetLevel()

    if lastKnownLevel == nil or currentLevel < lastKnownLevel then
        lastKnownLevel = currentLevel 
        return false
    end

    for reachedLevel = lastKnownLevel + 1, currentLevel do
        -- TDO: Remove this later
        if reachedLevel > 10 then
            locationReporter.report("Reach Level " .. reachedLevel)
            break
        end
        if locationReporter.report("Reach Level " .. reachedLevel) then
            chatView.say("Reached level " .. reachedLevel)
        end
    end
    lastKnownLevel = currentLevel
    return false
end)