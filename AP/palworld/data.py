"""Loads the split data files: items.json, regions.json, locations.json and events.json."""
import json
import pkgutil


def loadJson(fileName):
    return json.loads(pkgutil.get_data(__package__, fileName).decode("utf-8"))


itemsData = loadJson("items.json")
regionsData = loadJson("regions.json")
locationsData = loadJson("locations.json")
eventsData = loadJson("events.json")

itemDefinitions = {entry["name"]: entry for entry in itemsData["items"]}
itemNameToId = {name: entry["id"] for name, entry in itemDefinitions.items()}
startingItemNames = itemsData.get("starting_items", [])

regionDefinitions = regionsData["regions"]

locationDefinitions = locationsData["locations"]
locationNameToId = {entry["name"]: entry["id"] for entry in locationDefinitions}


eventDefinitions = eventsData["events"]
goalDefinition = eventsData["goals"][0]

fillerItemName = "Nothing"

itemNameGroups = {
    "Area Keys": {name for name in itemDefinitions if name.endswith(" Key")},
    "Progressive Items": {name for name in itemDefinitions if name.startswith("Progressive ")},
    "Skill Unlocks": {name for name in itemDefinitions if name.endswith(" Skill Unlock")},
    "Furniture Sets": {name for name in itemDefinitions if name.startswith("Furniture Set ")},
}
locationNameGroups = {
    "Quests": {name for name in locationNameToId if name.startswith("Quest: ")},
    "Pals": {name for name in locationNameToId if name.startswith("Pal: ")},
    "Levels": {name for name in locationNameToId if name.startswith("Reach Level ")},
}
