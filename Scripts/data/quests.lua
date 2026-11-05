-- locationNames: internal quest id -> location name
-- ignored: quests outside the scope, the mod stays silent about them, Writen down with ID for later expension.
-- goalQuestId: completing this quest completes the game
-- goalBossRowNames: defeating this boss towers also completes the game, quests or not. I put this in because i didnt want to force players to do the quests if they 
-- think they are prepared to do the bosses
return {
    locationNames = {
        ["Main_TutorialStart"] = "Quest: The First Islander",
        ["Main_UnlockFastTravel"] = "Quest: Activate Great Eagle Statue",
        ["Main_OpenSurvivalGuide"] = "Quest: Open the Survival Guide",
        ["Main_BuildWorkbench"] = "Quest: Set Up a Workbench",
        ["Main_CraftTools"] = "Quest: Crafting an Axe and a Pickaxe",
        ["Main_StatusUp"] = "Quest: Enhance Stats",
        ["Main_CatchPal"] = "Quest: Catching a Pal",
        ["Main_WorkPal"] = "Quest: Putting Pals to Work",
        ["Main_EatFood"] = "Quest: Filling Your Belly",
        ["Main_CaptureSheepBall"] = "Quest: The Weakest Pal",
        ["Main_PrepareEquipment"] = "Quest: Gearing Up",
        ["Main_SmallVillage"] = "Quest: Small Settlement",
        ["Main_CraftPalGear"] = "Quest: Crafting Pal Gear",
        ["Main_RayneSyndicate"] = "Quest: The Rayne Syndicate",
    },
    ignored = {
        ["Main_ReturnSmallVillage"] = true,
        ["Main_TalkGrassBoss"] = true,
    },
    goalQuestId = "Main_RayneSyndicate",
    goalBossRowNames = {
        ["BOSS_BATTLE_NAME_GrassBoss"] = true,
    },
}