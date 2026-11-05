local chatView = require("view.chat_view")
local logger = require("ap.log")
local palNames = require("data.pal_names")
local locationReporter = require("controller.location_reporter")
local saveData = require("ap.save_data")

local reportedUnknownPals = {}

--On succes capture send item and message
RegisterHook("/Script/Pal.PalUtility:PalCaptureSuccess",
    function(context, attackerPlayer, capturedMonster)
        local capturedPal = capturedMonster:get()
        if not (capturedPal and capturedPal:IsValid()) then
            return
        end

        local characterParameterComponent = capturedPal:GetCharacterParameterComponent()
        if not (characterParameterComponent and characterParameterComponent:IsValid()) then
            return
        end

        local individualParameter = characterParameterComponent:GetIndividualParameter()
        if not (individualParameter and individualParameter:IsValid()) then
            return
        end

        local characterId = individualParameter:GetCharacterID():ToString()
        if not palNames.isKnown(characterId) then
            if not reportedUnknownPals[characterId] then
                reportedUnknownPals[characterId] = true
                logger.writeToFile("pal not in data/pal_names.lua: " .. characterId)
            end
            return
        end

        local displayName = palNames.getDisplayName(characterId)
        locationReporter.report("Pal: " .. displayName)
        if not saveData.isAnnounced(displayName) then
            saveData.markAnnounced(displayName)
            chatView.say("Captured " .. displayName)
        end
    end)