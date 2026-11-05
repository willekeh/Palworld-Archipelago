# Palworld Setup Guide

## Required software

- [Palworld](https://store.steampowered.com/app/1623730/Palworld/) on Steam
- [Archipelago](https://github.com/ArchipelagoMW/Archipelago/releases) 0.5.0 or newer
- The Palworld `.apworld` file from the
  [releases page](https://github.com/YOUR-GITHUB-NAME/palworld-archipelago/releases)
- **UE4SS Experimental (Palworld)** from the Steam Workshop
- The **Archipelago - Palworld** mod from the Steam Workshop

## Installing the apworld

Double-click the `.apworld` file, or copy it into the `custom_worlds` folder of your Archipelago installation.
Restart the Archipelago launcher if it was open.

## Installing the mod

1. Subscribe to **UE4SS Experimental (Palworld)** on the Steam Workshop.
2. Start Palworld and open **Options → Mod Management**. Enable **UE4SS Experimental**, then restart the game when
   asked.
3. Subscribe to the **Archipelago - Palworld** mod on the Steam Workshop.
4. Start Palworld, open **Options → Mod Management**, enable the mod, and restart the game when asked.

You do not need PalSchema. If you installed UE4SS by hand earlier (`dwmapi.dll` or `xinput1_3.dll` in
`Palworld\Pal\Binaries\Win64`), remove those files first, because the Workshop version and a manual install
cannot be used together.

The mod stores its logs in its `logs` folder and the items and pals it already told you about in its `cached`
folder. Both folders have to stay where they are.

## Creating a config file

This game has no options yet, so a minimal YAML is enough:

```yaml
name: YourName
game: Palworld
Palworld: {}
```

Put it in the `Players` folder of your Archipelago installation and generate as usual, or give it to the person
hosting your multiworld.

## Connecting to the multiworld

1. Start Palworld and load a world. The mod does not check which Palworld world you load, so keep one Palworld
   world for each multiworld yourself.
2. Open the chat and type:

   ```
   !!connect archipelago.gg:38281 YourName
   ```

   Replace the address and the name with the ones of your multiworld. Add the password at the end if there is one.
3. The chat tells you when you are connected. Your items arrive in the chat as `Received <item>`.

To disconnect, type `!!disconnect` or return to the title screen. To continue later, load the same world and use
`!!connect` again. Everything you did while disconnected is sent when you reconnect.

## Troubleshooting

- **Nothing happens when I type `!!connect`.** Check that UE4SS Experimental and the mod are both enabled in
  **Options → Mod Management**, and look at the newest file in the mod's `logs` folder.
- **"slot refused: InvalidSlot".** The slot name has to match your name in the YAML exactly.
- **A `TLS handshake failed` line in the log.** This is normal. The mod tries a secure connection first and falls
  back to a plain one.

If something is wrong, open an issue at https://github.com/YOUR-GITHUB-NAME/palworld-archipelago/issues and attach the
newest log file from the mod's `logs` folder.
