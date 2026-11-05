local archipelagoClient = require("ap.ap_client")
local chatView = require("view.chat_view")
local logger = require("ap.log")
local questData = require("data.quests")

--Goal on defeating the first boss, needs to be rewriten later for more goal options
local hasReportedBossGoal = false

RegisterHook("/Script/Pal.PalBossTower:WriteBossDefeatRecord_ServerInternal",
    function(context, targetPlayer)
        local bossTower = context:get()
        if not (bossTower and bossTower:IsValid()) then
            return
        end

        local lookupSucceeded, rowName = pcall(function()
            return bossTower:GetBossBattleRowName():ToString()
        end)
        -- Dev check: shows the internal name of every boss defeat
        -- logger.write("boss defeated: " .. tostring(rowName))
        if not lookupSucceeded then
            logger.writeToFile("boss defeated, could not read the row name: " .. tostring(rowName))
            return
        end

        if not questData.goalBossRowNames[rowName] then
            return
        end
        if hasReportedBossGoal then
            return
        end

        hasReportedBossGoal = true
        chatView.say("Goal boss defeated")
        archipelagoClient:sendGoalComplete()
    end)
