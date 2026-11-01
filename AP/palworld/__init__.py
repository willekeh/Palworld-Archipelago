import logging

from BaseClasses import Item, ItemClassification, Location, Region, Tutorial
from worlds.AutoWorld import WebWorld, World

from . import data
from .logic import buildEntrances, buildRule
from .options import PalworldOptions

gameName = "Palworld"
menuRegionName = "Menu"
victoryItemName = "Victory"

classificationByType = {
    "progression": ItemClassification.progression,
    "useful": ItemClassification.useful,
    "filler": ItemClassification.filler,
}


class PalworldItem(Item):
    game = gameName


class PalworldLocation(Location):
    game = gameName


class PalworldWebWorld(WebWorld):
    theme = "grassFlowers"
    bug_report_page = "https://github.com/willekeh/Palworld-Archipelago/issues"
    tutorials = [
        Tutorial(
            "Multiworld Setup Guide",
            "A guide to playing Palworld with Archipelago.",
            "English",
            "setup_en.md",
            "setup/en",
            ["APPalworld"],
        )
    ]


class PalworldWorld(World):
    """Palworld, early game: catch pals across five areas, level up, finish the first quests and defeat
    the first tower boss. Techs, area keys and levels are the items."""

    game = gameName
    web = PalworldWebWorld()
    options_dataclass = PalworldOptions
    options: PalworldOptions

    item_name_to_id = data.itemNameToId
    location_name_to_id = data.locationNameToId
    item_name_groups = data.itemNameGroups
    location_name_groups = data.locationNameGroups

    def __init__(self, *arguments, **keywordArguments):
        super().__init__(*arguments, **keywordArguments)
        self.droppedItemNames = []

    def create_item(self, name: str) -> PalworldItem:
        itemDefinition = data.itemDefinitions[name]
        itemClassification = classificationByType[itemDefinition["type"]]
        return PalworldItem(name, itemClassification, itemDefinition["id"], self.player)

    def get_filler_item_name(self) -> str:
        return data.fillerItemName

    def create_regions(self) -> None:
        menuRegion = Region(menuRegionName, self.player, self.multiworld)
        regionsByName = {menuRegionName: menuRegion}
        for regionDefinition in data.regionDefinitions:
            regionName = regionDefinition["name"]
            regionsByName[regionName] = Region(regionName, self.player, self.multiworld)
        self.multiworld.regions += list(regionsByName.values())


        for regionDefinition in data.regionDefinitions:
            targetRegion = regionsByName[regionDefinition["name"]]
            entrances = buildEntrances(regionDefinition["logic"], self.player)
            for entranceNumber, (sourceRegionName, entranceRule) in enumerate(entrances):
                entranceName = f"{sourceRegionName} -> {targetRegion.name} ({entranceNumber})"
                regionsByName[sourceRegionName].connect(targetRegion, entranceName, entranceRule)

        for locationDefinition in data.locationDefinitions:
            location = PalworldLocation(self.player, locationDefinition["name"], locationDefinition["id"], menuRegion)
            locationRule = buildRule(locationDefinition["logic"], self.player)
            if locationRule is not None:
                location.access_rule = locationRule
            menuRegion.locations.append(location)

        for eventDefinition in data.eventDefinitions:
            eventLocation = PalworldLocation(self.player, "Event: " + eventDefinition["name"], None, menuRegion)
            eventRule = buildRule(eventDefinition["logic"], self.player)
            if eventRule is not None:
                eventLocation.access_rule = eventRule
            eventLocation.place_locked_item(PalworldItem(eventDefinition["name"], ItemClassification.progression, None, self.player))
            menuRegion.locations.append(eventLocation)

        goalLocation = PalworldLocation(self.player, data.goalDefinition["name"], None, menuRegion)
        goalRule = buildRule(data.goalDefinition["logic"], self.player)
        if goalRule is not None:
            goalLocation.access_rule = goalRule
        goalLocation.place_locked_item(PalworldItem(victoryItemName, ItemClassification.progression, None, self.player))
        menuRegion.locations.append(goalLocation)

    def create_items(self) -> None:
        precollectedCopies = {}
        for startingItemName in data.startingItemNames:
            self.multiworld.push_precollected(self.create_item(startingItemName))
            precollectedCopies[startingItemName] = precollectedCopies.get(startingItemName, 0) + 1

        itemPool = []
        for itemName, itemDefinition in data.itemDefinitions.items():
            copiesInPool = itemDefinition["amount"] - precollectedCopies.get(itemName, 0)
            for _ in range(max(copiesInPool, 0)):
                itemPool.append(self.create_item(itemName))

        surplusCount = len(itemPool) - len(data.locationDefinitions)
        if surplusCount > 0:
            fillerIndexes = [itemIndex for itemIndex, poolItem in enumerate(itemPool)
                             if poolItem.classification == ItemClassification.filler]
            chosenIndexes = self.random.sample(fillerIndexes, min(surplusCount, len(fillerIndexes)))
            for itemIndex in sorted(chosenIndexes, reverse=True):
                self.droppedItemNames.append(itemPool.pop(itemIndex).name)
            surplusCount -= len(chosenIndexes)
            logging.warning("%s: removed %d filler items that had no location (player %s): %s",
                            gameName, len(chosenIndexes), self.player_name, ", ".join(self.droppedItemNames))
            if surplusCount > 0:
                logging.warning("%s: still %d more items than locations, generation will fail unless locations are added",
                                gameName, surplusCount)
        elif surplusCount < 0:
            for _ in range(-surplusCount):
                itemPool.append(self.create_filler())

        self.multiworld.itempool += itemPool

    def set_rules(self) -> None:
        self.multiworld.completion_condition[self.player] = lambda state: state.has(victoryItemName, self.player)

    def fill_slot_data(self) -> dict:
        return {"dropped_items": list(self.droppedItemNames)}
