local archipelagoClient = require("ap.ap_client")
local itemApplier = require("ap.ap_apply_items")
local itemCache = require("ap.item_cache")
local messagesQueue = require("controller.chat.send_messages_queue")

-- items recieved to message queue, Partly made by me, then changed with AI for itemCache, to not send Messages all over again.
itemApplier.observe(function(itemDefinition, itemData, isInitialSync)
    local itemIndex = tonumber(itemData.index)
    if itemIndex and itemIndex <= itemCache.highestIndexAtConnect then
        return
    end
    if isInitialSync and not itemCache.hadCacheAtConnect then
        return
    end

    local itemName = itemDefinition and itemDefinition.name or ("item " .. tostring(itemData.item))
    local senderSlot = tonumber(itemData.player)
    local senderAlias = nil

    if senderSlot and senderSlot ~= archipelagoClient.slotNumber then
        senderAlias = archipelagoClient:getPlayerAlias(senderSlot)
    end

    if senderAlias then
        messagesQueue.say("Received " .. itemName .. " from " .. senderAlias)
    else
        messagesQueue.say("Received " .. itemName)
    end
end)
