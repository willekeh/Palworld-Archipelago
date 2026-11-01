local chatView = require("view.chat_view")

local maximumQueuedMessages = 100
local messagesPerTick = 5

local messagesQueue = {}
local pendingMessages = {}

-- messages queue to not get spammed. 
function messagesQueue.say(messageText)
    table.insert(pendingMessages, messageText)
    if #pendingMessages > maximumQueuedMessages then
        table.remove(pendingMessages, 1)
    end
end

LoopInGameThreadWithDelay(1000, function()
    local messagesSentThisTick = 0
    while #pendingMessages > 0 and messagesSentThisTick < messagesPerTick do
        if not chatView.say(pendingMessages[1]) then
            break 
        end
        table.remove(pendingMessages, 1)
        messagesSentThisTick = messagesSentThisTick + 1
    end
    return false
end)

return messagesQueue