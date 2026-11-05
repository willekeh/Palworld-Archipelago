local archipelagoClient = require("ap.ap_client")
local paths = require("ap.paths")
local logger = require("ap.log")
local saveData = require("ap.save_data")


local itemCache = {
    highestIndexAtConnect = -1,
    hadCacheAtConnect = false,
}

local currentSaveId = nil
local highestIndex = -1
local warnedAboutMissingIndex = false

local function getCacheFilePath(saveId)
    return saveData.getFilePath(saveId)
end

-- one line per item
local function readCache(saveId)
    local cachedItems = {}
    local cacheFile = io.open(getCacheFilePath(saveId), "r")
    if cacheFile then
        for line in cacheFile:lines() do
            local index, item, player, location, flags = line:match("^item (%-?%d+) (%-?%d+) (%-?%d+) (%-?%d+) (%-?%d+)")
            if index then
                table.insert(cachedItems, {
                    index = tonumber(index), item = tonumber(item), player = tonumber(player),
                    location = tonumber(location), flags = tonumber(flags),
                })
            end
        end
        cacheFile:close()
    end
    table.sort(cachedItems, function(first, second) return first.index < second.index end)
    return cachedItems
end

local function highestIndexOf(cachedItems)
    local highest = -1
    for _, cachedItem in ipairs(cachedItems) do
        if cachedItem.index > highest then
            highest = cachedItem.index
        end
    end
    return highest
end

function itemCache.record(itemDefinition, itemData)
    if not currentSaveId then
        return
    end
    local itemIndex = tonumber(itemData.index)
    if not itemIndex then
        if not warnedAboutMissingIndex then
            warnedAboutMissingIndex = true
            logger.write("received items carry no index, cannot cache them")
        end
        return
    end
    if itemIndex <= highestIndex then
        return 
    end
    highestIndex = itemIndex

    local cacheFile = io.open(getCacheFilePath(currentSaveId), "a")
    if not cacheFile then
        logger.write("could not write " .. getCacheFilePath(currentSaveId) .. " (does the folder " .. paths.cacheFolder .. " exist?)")
        return
    end
    cacheFile:write(string.format("item %d %d %d %d %d\n", itemIndex, tonumber(itemData.item) or -1,
        tonumber(itemData.player) or -1, tonumber(itemData.location) or -1, tonumber(itemData.flags) or 0))
    cacheFile:close()
end

-- Item caching for recived and send items. 
archipelagoClient:onSlotConnected(function()
    currentSaveId = saveData.buildSaveId()
    local cachedItems = readCache(currentSaveId)
    highestIndex = highestIndexOf(cachedItems)
    itemCache.highestIndexAtConnect = highestIndex
    itemCache.hadCacheAtConnect = #cachedItems > 0

    logger.write("item cache: " .. #cachedItems .. " items known for " .. currentSaveId)
end)

return itemCache
