local archipelagoClient = require("ap.ap_client")
local itemApplier = require("ap.ap_apply_items")
local logger = require("ap.log")
local techUi = require("view.tech_view")
local techPool = require("data.tech_pool")

local copiesReceivedByItemId = {}
local unlockedTechs = {}

-- If item is not unlocked relock it in tech ui
RegisterHook("/Script/Pal.PalTechnologyData:RequestUnlockRecipeTechnology",
    function(context, unlockTechnologyName)
        local techId = unlockTechnologyName:get():ToString()
        if not techPool[techId] or unlockedTechs[techId] then
            return
        end

        logger.writeToFile("tech locked: " .. techId)
        unlockTechnologyName:set(FName("None"))
        ExecuteWithDelay(150, function()
            ExecuteInGameThread(function()
                techUi.refresh()
            end)
        end)
    end)

-- This function part is AI, except techUI.refresh and the registerHook
archipelagoClient:onSlotConnected(function()
    copiesReceivedByItemId = {}
    unlockedTechs = {}
end)

itemApplier.register("tech", function(itemDefinition, itemData)
    local copyNumber = (copiesReceivedByItemId[itemData.item] or 0) + 1
    copiesReceivedByItemId[itemData.item] = copyNumber

    local techsForThisCopy = itemDefinition.tiers[copyNumber]
    if not techsForThisCopy then
        logger.writeToFile("more copies of " .. itemDefinition.name .. " than tiers: copy " .. copyNumber)
        return
    end
    for _, techId in ipairs(techsForThisCopy) do
        unlockedTechs[techId] = true
    end
    techUi.refresh()
end)