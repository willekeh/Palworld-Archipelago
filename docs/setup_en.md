# Palworld Setup Guide

This is the setup guide for palworld archipelago. 
What the game changes, its items, locations and goal are explained in the [docs](docs/palworld_en.md).

## What you need

- **Palworld** on Steam
- **Archipelago** from the [Archipelago releases](https://github.com/ArchipelagoMW/Archipelago/releases)
- The **`palworld.apworld`** file from the
  [releases page](https://github.com/willekeh/Palworld-Archipelago/releases)
- **UE4SS Experimental (Palworld)** from the Steam Workshop
- The **APPalworld** mod from the Steam Workshop or download it manually for Nexus

## 1. Install UE4SS and the APPalworld mod

### Steam
Both come from the Steam Workshop, so there is nothing to copy by hand.

1. Subscribe to **UE4SS Experimental (Palworld)** on the Steam Workshop.
2. Subscribe to the **APPalworld** mod on the Steam Workshop.
3. Start Palworld, open **Options → Mod Management**, enable **APPalworld** and **UE4SS Experimental (Palworld)** The game should prompt you to restart.

### Nexus

1. Have [UE4SS](https://www.nexusmods.com/palworld/mods/2237?tab=description) installed
2. Download the mod from the [release page](https://github.com/willekeh/Palworld-Archipelago/releases)
3. The mod should be added at **`steamapps\common\Palworld\Pal\Binaries\Win64\ue4ss`**


## 2. Install the apworld

Download `palworld.apworld` from the releases page and either double-click it or copy it into the `custom_worlds`
folder of your Archipelago installation and restart the Archipelago launcher if it was open.

## 3. Create your YAML and generate

Make a Yaml, it currently doesnt have any options

- **Use a slot name without spaces.** The `!!connect` command in the chat reads the slot name as one word, so a name
  with a space cannot be used.

## 4. Connect

1. Start Palworld and start a new world. The mod does not check which Palworld world you load, so keep one Palworld world
   for each multiworld yourself.
2. Open the chat and type:

   ```
   !!connect host:port slotname [password]
   ```

   For example `!!connect archipelago.gg:38281 Player1 password`.

3. The chat shows `Connecting to ...`, then `Connected to Archipelago`. Your items arrive as `Received <item>`.

To leave, type `!!disconnect` or by going back to the title screen.

## 5. Playing

- **Technologies stay locked** until you have received them. A progressive item unlocks one tier per copy.
- **Locations** are the first catch of each of 36 pals, 14 main quests and the levels 2 to 10. A location is sent the
  moment you do it. The chat tells you about a quest when you complete it, and about a pal the first time you catch that
  kind.
- **The goal** is defeating the first tower boss or completing the quest _The Rayne Syndicate_.
- **The mod does not reconnect by itself.** If the connection drops, type `!!connect` again with the same details.

## 6. Mod Compatibility
Other Palworld mods can be used alongside the Archipelago integration, but they may cause unforeseen conflicts or breaking changes. 
It is recommended to test any additional mods in a solo world before using them in a sync or async multiworld.
