# Palworld Archipelago
An [Archipelago](https://archipelago.gg) multiworld integration for currently the early game of Palworld. Technologies,
buildings, area keys and levels become items that can be anywhere in a multiworld. Catching your first pal of each
kind, completing quests and reaching levels send items to other players.

It has two parts:

| Part | Folder | What it is |
| --- | --- | --- |
| **Mod** | [`mod/`](mod) | A UE4SS Lua mod for Palworld. It talks to the Archipelago server, sends your locations and applies the items you receive. Published on the Steam Workshop. |
| **APWorld** | [`apworld/palworld_earlygame/`](apworld/palworld) | The world for the Archipelago generator: items, locations, regions and logic. Published as an `.apworld` file on the releases page. |

## Playing
Follow the [setup guide](docs/setup_en.md).

What the game changes, its items, locations and goal are described in the
[game page](docs/palworld.md).

## Development

## Tests

## License
MIT, see [LICENSE](LICENSE). The bundled `lua-apclientpp.dll` has its own MIT license, see
[third_party_notice.md](third_party_notic.md).
