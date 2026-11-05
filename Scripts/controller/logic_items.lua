local itemApplier = require("ap.ap_apply_items")

for _, itemKind in ipairs({ "area", "level", "filler" }) do
    itemApplier.register(itemKind, function() end)
end
