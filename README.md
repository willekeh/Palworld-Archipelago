# Palworld Archipelago

This is an [Archipelago](https://archipelago.gg) multiworld integration for currently the early game of Palworld.
(currently, this would include the research tree and up to character level 10)
Technologies, area keys and levels become items that can be anywhere in a multiworld. Catching your first pal of each
kind, completing quests and reaching levels are checks.

It has two parts:

| Part        | Folder                             | What it is                                                                                                                                                 |
| ----------- | ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Mod**     | [`mod/`](mod)                      | A UE4SS Lua mod for Palworld. It talks to the Archipelago server, sends your locations and applies the items you receive. Published on the Steam Workshop. |
| **APWorld** | [`AP/palworld/`](apworld/palworld) | The world for the Archipelago generator: items, locations, regions and logic. Published as an `.apworld` file on the releases page.                        |

## Playing

Follow the [setup guide](docs/setup_en.md).

What the game changes, its items, locations and goal are described in the [docs](docs/palworld_en.md).

## Mod Compatibility

Other Palworld mods can be used alongside the Archipelago integration, but they may cause unforeseen conflicts or breaking changes. 
It is recommended to test any additional mods in a solo world before using them in a sync or async multiworld.

## Development

for contributing see [Contributing](docs/contributing.md)

## License

MIT, see [LICENSE](LICENSE). The bundled `lua-apclientpp.dll` has its own MIT license, see
[third_party_notice.md](THIRD_PARTY_NOTICES.md).

## AI disclosure

This APWorld was made with a small amount of AI tool assistance. AI has not been used for documentation, folder structure, image generation and finding in-game functions.
Setup of the mod has been done with the tutorial provided by [pwmodding](https://pwmodding.wiki/docs/category/palworld-modding-kit). All in game function have been found by me or mod recommendations by other users in the palworld discord forum. Such as [Level Lock](https://steamcommunity.com/sharedfiles/filedetails/?id=3765490028) and [Quick Connect Manager](https://steamcommunity.com/sharedfiles/filedetails/?id=3777185338). I do not know if these have used AI.

Used AI:
Claude Sonnet 5.5 Free Plan

Some functions to connect to archipelago have been writen by AI, These function have a comment like `This has been writen by AI`. I welcome anyone to change these functions to none AI code, test and PR it.

I don't have an autocomplete function enabled and no AI connected directly to this code. Any local AI that I have had installed in the past no longer exists on my PC, therefore it has not been used for this project.

All AI code that is currently in use has been looked trough, sometimes rewriten, tested and looked trough again by me before publishing. At this moment i have 8 years of programming behind me with a degree in software engineering (VET). I know what the code does and i can debug it if needed.
