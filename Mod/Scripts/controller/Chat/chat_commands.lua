local archipelagoClient = require("ap.ap_client")
local logger = require("ap.log")
local announcements = require("controller.chat.send_messages_queue")

local logAllChatMessages = true  
local duplicateWindowSeconds = 0.5

local lastHandledText = nil
local lastHandledClock = 0

--This was made by AI
local function parseServerAddress(addressText)
    local hostName, portText = string.match(addressText, "^(.+):(%d+)$")
    if hostName then
        return hostName, tonumber(portText)
    end
    return addressText, archipelagoClient.defaultPort
end

local function handleConnectCommand(argumentText)
    local addressText, slotName, passwordText = string.match(argumentText, "^(%S+)%s+(%S+)%s*(.-)%s*$")
    if not addressText then
        announcements.say("Usage: !!connect host:port slotname [password]")
        return
    end
    local hostName, portNumber = parseServerAddress(addressText)
    announcements.say("Connecting to " .. hostName .. ":" .. portNumber .. " as " .. slotName)
    if not archipelagoClient:connect(hostName, portNumber, slotName, passwordText) then
        announcements.say("Could not connect: the Archipelago library is not loaded")
    end
end

local function handleDisconnectCommand()
    archipelagoClient:disconnect()
    announcements.say("Disconnected from Archipelago")
end

local function handleChatText(messageText)
    local commandName, argumentText = string.match(messageText, "^!!(%a+)%s*(.*)$")
    if not commandName then
        return
    end
    commandName = string.lower(commandName)
    if commandName == "connect" then
        handleConnectCommand(argumentText)
    elseif commandName == "disconnect" then
        handleDisconnectCommand()
    end
end

local function onChatMessage(chatMessageParameter)
    local readSucceeded, messageText, senderName = pcall(function()
        local chatMessage = chatMessageParameter:get()
        return chatMessage.Message:ToString(), chatMessage.Sender:ToString()
    end)
    if not readSucceeded then
        logger.writeToFile("could not read a chat message: " .. tostring(messageText))
        return
    end
    if senderName == "Archipelago" or messageText == "" then
        return
    end

    local currentClock = os.clock()
    if messageText == lastHandledText and currentClock - lastHandledClock < duplicateWindowSeconds then
        return
    end
    lastHandledText = messageText
    lastHandledClock = currentClock

    if logAllChatMessages then
        local maskedText = string.gsub(messageText, "^(!!connect%s+%S+%s+%S+).*$", "%1 ***")
        logger.writeToFile("[chat] " .. senderName .. ": " .. maskedText)
    end

    handleChatText(messageText)
end

local chatHookPaths = {
    "/Script/Pal.PalGameStateInGame:BroadcastChatMessage",
    "/Script/Pal.PalUIChat:OnReceivedChat",
}
for _, hookPath in ipairs(chatHookPaths) do
    local registrationSucceeded, errorMessage = pcall(function()
        RegisterHook(hookPath, function(context, chatMessageParameter)
            onChatMessage(chatMessageParameter)
        end)
    end)
    logger.writeToFile("chat hook " .. hookPath .. ": " .. (registrationSucceeded and "registered" or tostring(errorMessage)))
end

archipelagoClient:onSlotRefused(function(reasonText)
    announcements.say("Archipelago refused the connection: " .. reasonText)
end)