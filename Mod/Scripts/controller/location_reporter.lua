local archipelagoClient = require("ap.ap_client")
local logger = require("ap.log")
local locationIds = require("data.locations")

local locationReporter = {}
local reportedLocationNames = {}
local reportedConnectionKey = nil

--This was made partly with AI, I made the original locationReporter. But i coudnt figure out how to connect it with AP.
archipelagoClient:onSlotConnected(function()
    if archipelagoClient.connectionKey ~= reportedConnectionKey then
        if reportedConnectionKey ~= nil then
            reportedLocationNames = {}
        end
        reportedConnectionKey = archipelagoClient.connectionKey
    end
end)

function locationReporter.report(locationName)
    if reportedLocationNames[locationName] then
        return false
    end
    reportedLocationNames[locationName] = true

    local locationId = locationIds[locationName]
    if locationId then
        archipelagoClient:checkLocation(locationId)
    else
        logger.writeToFile("no location id for '" .. locationName .. "' yet")
    end
    return true
end

return locationReporter