local logger = require("ap.log")
local paths = require("ap.paths")

local pollIntervalMilliseconds = 50
local initialSyncWindowSeconds = 5
local itemsHandlingAll = 7
local goalStatusCode = 30
local clientTags = {"AP", "Palworld"}
local clientVersion = {0, 5, 0}

local archipelagoClient = {
    defaultPort = 38281,
    isInitialized = false,
    isLoopStarted = false,
    isAuthenticated = false,
    isClientCreationPending = false,
    isInitialItemSync = false,
    isGoalPending = false,
    slotConnectedClock = 0,
    slotNumber = nil,
    connectionKey = nil,
    authenticatedConnectionKey = nil,
    nativeLibrary = nil,
    nativeClient = nil,
    lastPollError = nil,
    callbacks = {},
    slotConnectedCallbacks = {},
    slotRefusedCallbacks = {},
    queuedLocationChecks = {},
    connection = {
        host = nil,
        port = nil,
        slotName = nil,
        password = "",
        gameName = "Palworld",
        uuid = "",
    },
}

function archipelagoClient:initialize()
    package.cpath = paths.dllFolder .. "?.dll;" .. package.cpath

    local libraryPath, searchedPaths = package.searchpath("lua-apclientpp", package.cpath)
    if not libraryPath then
        logger.write("DLL not found. Searched:\n" .. tostring(searchedPaths))
        return false
    end
    logger.write("loading " .. libraryPath)

    local loadSucceeded, loadedLibrary = pcall(require, "lua-apclientpp")
    if not loadSucceeded then
        logger.write("could not load lua-apclientpp: " .. tostring(loadedLibrary))
        return false
    end

    self.nativeLibrary = loadedLibrary
    self.isInitialized = true
    logger.write("lua-apclientpp loaded")
    return true
end

function archipelagoClient:connect(host, port, slotName, password)
    if not self.isInitialized then
        logger.write("cannot connect: lua-apclientpp is not loaded")
        return false
    end

    local newConnectionKey = host .. ":" .. tostring(port) .. " " .. slotName
    if self.nativeClient or self.isClientCreationPending then
        self:disconnect()
    end
    if self.authenticatedConnectionKey ~= nil and self.authenticatedConnectionKey ~= newConnectionKey then
        self.queuedLocationChecks = {}
        self.isGoalPending = false
    end

    self.connectionKey = newConnectionKey
    self.connection.host = host
    self.connection.port = port
    self.connection.slotName = slotName
    self.connection.password = password or ""
    self.isClientCreationPending = true  
    logger.write("connecting to " .. newConnectionKey)
    return true
end

function archipelagoClient:disconnect()
    local clientToClose = self.nativeClient
    self.nativeClient = nil
    self.isClientCreationPending = false
    self.isAuthenticated = false
    self.isInitialItemSync = false
    self.slotNumber = nil
    if clientToClose then
        pcall(function()
            if clientToClose.reset then
                clientToClose:reset()
            end
        end)
        clientToClose = nil
        collectgarbage("collect")
    end
    logger.write("disconnected")
end

function archipelagoClient:_createClient()
    self.isClientCreationPending = false
    local serverAddress = string.format("%s:%d", self.connection.host, self.connection.port)
    logger.write(string.format("creating client (game=%s, server=%s)", self.connection.gameName, serverAddress))

    local creationSucceeded, createdClient = pcall(
        self.nativeLibrary, self.connection.uuid, self.connection.gameName, serverAddress)
    if not creationSucceeded or not createdClient then
        logger.write("could not create client: " .. tostring(createdClient))
        return
    end

    self.nativeClient = createdClient
    logger.write("client created")
    self:setupEventHandlers()
    logger.write("handlers registered")
end

function archipelagoClient:setupEventHandlers()
    self.nativeClient:set_socket_connected_handler(function()
        logger.write("socket connected")
    end)

    self.nativeClient:set_room_info_handler(function()
        logger.write("room info received, authenticating")
        self.nativeClient:ConnectSlot(
            self.connection.slotName, self.connection.password,
            itemsHandlingAll, clientTags, clientVersion)
    end)

    self.nativeClient:set_socket_disconnected_handler(function()
        logger.write("socket disconnected")
        self.isAuthenticated = false
    end)

    self.nativeClient:set_socket_error_handler(function(errorMessage)
        logger.write("socket error: " .. tostring(errorMessage))
    end)

    self.nativeClient:set_slot_connected_handler(function()
        logger.write("slot connected")
        self.isAuthenticated = true
        self.authenticatedConnectionKey = self.connectionKey
        self.isInitialItemSync = true
        self.slotConnectedClock = os.clock()
        local lookupSucceeded, lookedUpSlotNumber = pcall(function()
            return self.nativeClient:get_player_number()
        end)
        if lookupSucceeded then
            self.slotNumber = lookedUpSlotNumber
        end
        for _, slotConnectedCallback in ipairs(self.slotConnectedCallbacks) do
            local callSucceeded, errorMessage = pcall(slotConnectedCallback)
            if not callSucceeded then
                logger.write("onSlotConnected error: " .. tostring(errorMessage))
            end
        end
        self:flushQueue()
    end)

    self.nativeClient:set_slot_refused_handler(function(refusalReasons)
        local reasonText = tostring(refusalReasons)
        if type(refusalReasons) == "table" then
            reasonText = table.concat(refusalReasons, ", ")
        end
        logger.write("slot refused: " .. reasonText)
        self.isAuthenticated = false
        for _, slotRefusedCallback in ipairs(self.slotRefusedCallbacks) do
            local callSucceeded, errorMessage = pcall(slotRefusedCallback, reasonText)
            if not callSucceeded then
                logger.write("onSlotRefused error: " .. tostring(errorMessage))
            end
        end
    end)

    self.nativeClient:set_items_received_handler(function(receivedItems)
        local isInitialSync = self.isInitialItemSync
        self.isInitialItemSync = false
        for _, itemData in ipairs(receivedItems) do
            logger.write("item received: " .. tostring(itemData.item))
            if self.callbacks.onItemReceived then
                local callSucceeded, errorMessage = pcall(self.callbacks.onItemReceived, itemData, isInitialSync)
                if not callSucceeded then
                    logger.write("onItemReceived error: " .. tostring(errorMessage))
                end
            end
        end
    end)

    self.nativeClient:set_print_handler(function(serverMessage)
        logger.write("[server] " .. tostring(serverMessage))
    end)
end

function archipelagoClient:poll()
    local pollSucceeded, errorMessage = pcall(function() self.nativeClient:poll() end)
    if not pollSucceeded and errorMessage ~= self.lastPollError then
        self.lastPollError = errorMessage
        logger.write("poll failed: " .. tostring(errorMessage))
    end
end

function archipelagoClient:tick()
    if self.isClientCreationPending then
        self:_createClient()
    end
    if self.nativeClient then
        self:poll()
    end
    if self.isInitialItemSync and os.clock() - self.slotConnectedClock > initialSyncWindowSeconds then
        self.isInitialItemSync = false 
    end
end

function archipelagoClient:checkLocation(locationId)
    if not (self.nativeClient and self.isAuthenticated) then
        table.insert(self.queuedLocationChecks, locationId)
        logger.write("queued location check " .. tostring(locationId) .. " (not connected yet)")
        return
    end
    logger.write("sending location check " .. tostring(locationId))
    local sendSucceeded, errorMessage = pcall(function()
        self.nativeClient:LocationChecks({locationId})
    end)
    if not sendSucceeded then
        logger.write("failed to send check: " .. tostring(errorMessage))
    end
end

function archipelagoClient:sendGoalComplete()
    self.isGoalPending = true
    self:flushQueue()
end

function archipelagoClient:flushQueue()
    if not (self.nativeClient and self.isAuthenticated) then
        return
    end
    if #self.queuedLocationChecks > 0 then
        local locationIdsToSend = self.queuedLocationChecks
        self.queuedLocationChecks = {}
        logger.write("sending " .. #locationIdsToSend .. " queued location checks")
        local sendSucceeded, errorMessage = pcall(function()
            self.nativeClient:LocationChecks(locationIdsToSend)
        end)
        if not sendSucceeded then
            logger.write("failed to flush checks: " .. tostring(errorMessage))
        end
    end
    if self.isGoalPending then
        self.isGoalPending = false
        local statusSucceeded, errorMessage = pcall(function()
            self.nativeClient:StatusUpdate(goalStatusCode)
        end)
        logger.write(statusSucceeded and "goal reported" or ("failed to report the goal: " .. tostring(errorMessage)))
    end
end

function archipelagoClient:getPlayerAlias(slotNumber)
    if not self.nativeClient then
        return nil
    end
    local lookupSucceeded, alias = pcall(function()
        return self.nativeClient:get_player_alias(slotNumber)
    end)
    if lookupSucceeded and alias and alias ~= "" then
        return alias
    end
    return nil
end

function archipelagoClient:onItemReceived(callback)
    self.callbacks.onItemReceived = callback
end

function archipelagoClient:onSlotConnected(callback)
    table.insert(self.slotConnectedCallbacks, callback)
end

function archipelagoClient:onSlotRefused(callback)
    table.insert(self.slotRefusedCallbacks, callback)
end

function archipelagoClient:start()
    if not self:initialize() then
        return false
    end
    if not self.isLoopStarted then
        self.isLoopStarted = true
        local lastLoggedTickError = nil
        LoopInGameThreadWithDelay(pollIntervalMilliseconds, function()
            local tickSucceeded, errorMessage = pcall(function() self:tick() end)
            if not tickSucceeded and errorMessage ~= lastLoggedTickError then
                lastLoggedTickError = errorMessage
                logger.write("tick error: " .. tostring(errorMessage))
            end
            return false
        end)
    end
    return true
end

return archipelagoClient