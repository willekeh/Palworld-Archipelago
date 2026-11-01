-- Palworld mostly uses IDnames when interacting with the pals including catching.
-- The reason why i hard coded the names has multiple reasons
-- 1. i coudnt find a way to get them. The DataTable responsible for this is empty when the game is not running and i currently don't know enough lua to extract this. if that is even possible
-- 2. Localization, in case someone plays something else then English. Palworld pal names are in 4 different languages and to switch the language you have to do so for your whole steam profile (1.0 Palworld)
-- because of this i decided to make a list of id names vs english names
-- Only palls till first tower
-- This was typed out by the developer as the first thing i basically did while testing my code and seeing if i actually liked developing this.
-- I typed this much as a reminder to myself, to 1 look back on this if i can actually get the names in game and find the localization functions. if those exsist
local palDisplayNamesByCharacterId = {
    Chickenpal = "Chikipi",
    Sheepball = "Lamball",
    Pinkcat = "Cattiva",
    Penguin = "Pengullet",
    Clionetwins = "Amione",
    Flyingmanta = "Celaray",
    Cloverfairy = "Clovee",
    Woolfox = "Cremis",
    Kendofrog = "Croajiro",
    Dreamdemon = "Daedream",
    Negativekoala = "Depresso",
    Garm = "Direhowl",
    Deer = "Eikthyrdeer",
    Lavagirl = "Flambelle",
    Kitsunebi = "Foxparks",
    Blueplatypus = "Fuack",
    Plantslime = "Gumoss",
    Windchimes = "Hangyu",
    Leafmomonga = "Herbil",
    Wizardowl = "Hoocrates",
    Hedgehog = "Jolthog",
    Kelpie = "Kelpsea",
    Carbunclo = "Lifmunk",
    Alpaca = "Melpaca",
    CowPal = "Mozzarina",
    Nightfox = "Nox",
    Samuraidog = "Pupperai",
    Pinkrabbit = "Ribbuny",
    FlameBambi = "Rooby",
    Boar = "Rushoar",
    Eleccat = "Sparkit",
    Mopbaby = "Swee",
    Monkey = "Tanzee",
    Monkey_fire = "Tanzee Ignis",
    Ganesha = "Teafant",
    Cutefox = "Vixy",
}


local displayNamesByLowerCaseId = {}
for characterId, displayName in pairs(palDisplayNamesByCharacterId) do
    displayNamesByLowerCaseId[string.lower(characterId)] = displayName
end

local palNames = {}

function palNames.getDisplayName(characterId)
    return displayNamesByLowerCaseId[string.lower(characterId)] or characterId
end

function palNames.isKnown(characterId)
    return displayNamesByLowerCaseId[string.lower(characterId)] ~= nil
end

return palNames