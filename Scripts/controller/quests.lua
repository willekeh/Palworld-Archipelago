local archipelagoClient = require("ap.ap_client")
local chatView = require("view.chat_view")
local locationReporter = require("controller.location_reporter")
local questData = require("data.quests")

-- On complete quest if not ignored or unknown quests send location
RegisterHook("/Script/Pal.PalQuestManager:OnCompletedQuest_ServerInternal",
    function(context, completedQuestParameter)
        local completedQuest = completedQuestParameter:get()
        if not (completedQuest and completedQuest:IsValid()) then
            return
        end

        local questId = completedQuest:GetQuestId():ToString()
        if questData.ignored[questId] then
            return
        end

        local nameLookupSucceeded, nameLookupResult = pcall(function()
            local outputParameters = {}
            completedQuest:GetQuestNameText(outputParameters)
            return outputParameters
        end)
        local questDisplayName = questId
        if nameLookupSucceeded and nameLookupResult.OutText then
            questDisplayName = nameLookupResult.OutText:ToString()
        end

        local locationName = questData.locationNames[questId]
        if not locationName then
            logger.writeToFile("add to quest_ids.txt: " .. questId .. " | " .. questDisplayName)
            -- end
            -- Dev checks
            -- if not reportedUnknownQuests[questId] then
            --     reportedUnknownQuests[questId] = true
            --     logger.write("add to quest_ids.txt: " .. questId .. " | " .. questDisplayName)
            -- end
            return
        end

        if locationReporter.report(locationName) then
            chatView.say("Quest completed: " .. questDisplayName)
        end
        if questId == questData.goalQuestId then
            archipelagoClient:sendGoalComplete()
        end
    end)