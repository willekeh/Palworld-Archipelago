local logger = require("ap.log")
local itemDefinitions = require("data.items")

local itemApplier = { handlersByKind = {}, observers = {} }

function itemApplier.register(itemKind, handlerFunction)
    itemApplier.handlersByKind[itemKind] = handlerFunction
end

function itemApplier.observe(observerFunction)
    table.insert(itemApplier.observers, observerFunction)
end

--This itemApplier was made by AI 
function itemApplier.apply(itemData, isInitialSync)
    local itemDefinition = itemDefinitions[itemData.item]
    if not itemDefinition then
        logger.write("unknown item id " .. tostring(itemData.item))
    else
        local handlerFunction = itemApplier.handlersByKind[itemDefinition.kind]
        if not handlerFunction then
            logger.write("no handler for kind '" .. tostring(itemDefinition.kind) .. "'")
        else
            local handlerSucceeded, errorMessage = pcall(handlerFunction, itemDefinition, itemData)
            if not handlerSucceeded then
                logger.write("handler error for item " .. tostring(itemData.item) .. ": " .. tostring(errorMessage))
            end
        end
    end

    for _, observerFunction in ipairs(itemApplier.observers) do
        local observerSucceeded, errorMessage = pcall(observerFunction, itemDefinition, itemData, isInitialSync)
        if not observerSucceeded then
            logger.write("item observer error: " .. tostring(errorMessage))
        end
    end
end

return itemApplier