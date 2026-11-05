# Palworld

## Where is the options page?

The [player options page for this game](../player-options) contains all the options you need to configure and export a
config file. This game currently has no options of its own, so the default YAML is all you need.

## What does randomization do to this game?

The early game of Palworld becomes the multiworld. Everything you would normally learn or unlock on your own comes
from the multiworld instead, and the things you do early in the game send items to other players:

- **Technologies are locked.** A technology (a recipe or a building) cannot be unlocked in the technology menu until
  you have received its item. Several are *progressive*: each copy you receive unlocks the next tier, for example
  Progressive Bow, Progressive Armor or Progressive Weapon.
- **Area keys and progressive levels** are part of the multiworld logic. They decide which locations the generator may
  expect you to reach. In this version the mod does nothing with them in the game, so it does not stop you from
  walking into an area or from levelling up early.

## What is the goal?

Defeat the tower boss of **The Rayne Syndicate**, or complete the quest *The Rayne Syndicate*. Either one sends your
goal to the server. Defeating the boss sends the goal even if you did not do the quests.

Archipelago expects the following to be possible before you can reach the goal: the Plateau of Beginnings, Progressive
Level 8 and a Progressive Armor.

## Which items can be in another player's world?

Your items are scattered over all the worlds of the multiworld. The items of this game are:

- **Area keys**: Plateau of Beginnings, Windswept Hills, Golden Hills, Flying Fish Coast and Sea Breeze Archipelago.
  You start with the Plateau of Beginnings Key.
- **Progressive Level**: 8 copies.
- **Technologies**: for example Pal Box, Progressive Pal Sphere, Progressive Bow, Progressive Arrow, Progressive Armor,
  Progressive Weapon, Progressive Shield, Progressive Glider, Pal Gear Workbench and the Foxparks, Melpaca, Rushoar
  and Direhowl skill unlocks.
- **Building and furniture unlocks**: for example Feedbox, Ranch, Berry Plantation, Hot Spring, Furniture Sets and
  Wooden Structures.

## Which locations send items?

- **Pals**: the first time you catch each of 36 pals (`Pal: Chikipi`, `Pal: Lamball`, ...).
- **Quests**: completing each of 14 main quests, such as *Set Up a Workbench* or *Catching a Pal*.
- **Levels**: reaching level 2 up to level 10 (`Reach Level 2`, ...).

### Quest order in the logic

The quests have to be done in order. A quest is only in logic after the quest before it, with these exceptions:

- *Small Settlement* does not need any other quest.
- *Crafting Pal Gear* needs *Small Settlement*.
- *The Rayne Syndicate* needs *Gearing Up* and *Crafting Pal Gear*.

The mod does not stop you from doing a quest earlier than the logic expects. Its location is still sent when you
complete it.

## What happens when I receive an item?

You get a message in the Palworld chat, for example `Received Pal Box from Bob`. A technology item makes the matching
technology available in the technology menu.

## What happens when I am not connected?

Locations you check while not connected are remembered and sent as soon as you connect. When you connect again,
the server sends all your items again, so you do not miss anything that was sent while you were away.

## Unique local commands

These are typed in the Palworld chat:

- `!!connect <host:port> <slot name> [password]` connects to the multiworld.
- `!!disconnect` disconnects.

The mod disconnects by itself when you go back to the title screen.
