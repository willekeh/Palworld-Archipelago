local techView = {}
local logger = require("ap.log")

-- after blocked tech, refreshes button
function techView.refresh()
    local techScreens = FindAllOf("WBP_MainMenu_Technology_00_C")
    if not techScreens then
        return
    end
    for _, techScreen in ipairs(techScreens) do
        if techScreen:IsValid() then
            local refreshSucceeded, errorMessage = pcall(function()
                techScreen:UpdateAllTechnologyButton()
            end)
            if not refreshSucceeded then
                logger.write("tech UI refresh failed: " .. tostring(errorMessage))
            end
        end
    end
end

return techView