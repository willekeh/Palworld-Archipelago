local archipelagoClient = require("ap.ap_client")
local messagesQueue = require("controller.chat.send_messages_queue")

archipelagoClient:onSlotConnected(function()
    messagesQueue.say("Connected to Archipelago")
end)
