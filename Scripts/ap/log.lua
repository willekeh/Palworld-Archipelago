local paths = require("ap.paths")

local logger = {}
local sessionTimestamp = os.date("%Y%m%d_%H%M%S")
local sessionLogFile = paths.logFile:gsub("(%.[^%.]+)$", "_" .. sessionTimestamp .. "%1")

-- file only 
function logger.writeToFile(message)
    local logFile = io.open(sessionLogFile, "a")
    if logFile then
        logFile:write(tostring(message) .. "\n")
        logFile:close()
    end
end

-- console
function logger.write(message)
    local messageText = tostring(message)
    print("[AP] " .. messageText)
    logger.writeToFile(messageText)
end

return logger
