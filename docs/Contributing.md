# Contributing

This page explains how the repository is organised, how to run the tests and how to setup the dev enviorment

## Ways to help

- **Report a bug.** Open an issue at [Issues](https://github.com/willekeh/Palworld-Archipelago/issues). Say what you did,
  what you expected and what happened. Attach the newest file from the mod's `logs` folder and say which version of the
  mod and the apworld you use.
- **Suggest a change** to the items, locations or logic. Open an issue first or post it in the discord forum
- **Send a pull request.** Fork the repository and send a PR.

## The two halves

The mod and the apworld have to agree on every id and name, so most changes touch both.

\*\*add folder structure

## Running the tests

\*\*add how to run tests

## Adding or changing items and locations

An item or location exists in two places, and the ids and names have to be identical.

- **Items:** `apworld/palworld/items.json` and `mod/Scripts/data/items.lua`. Item ids are in the range 9370000 to 9379999. A tech item also needs its tech ids in `mod/Scripts/data/tech_pool.lua`.
- **Locations:** `apworld/palworld/locations.json` and `mod/Scripts/data/locations.lua`. Location ids are in the range
  10000 to 20000. A new pal also goes into `mod/Scripts/data/pal_names.lua`, and a new quest into
  `mod/Scripts/data/quests.lua`.
- **Logic:** write it in the `logic` field with the atoms `(Item: Name)`, `(Item: Name : count)`,
  `(Can Access: Region)`, `(Event: Name)` and `(Location: Name)`, combined with `AND`, `OR` and parentheses. A quest
  that has to wait for an earlier quest uses the earlier quest's event. Do not reuse or renumber ids that were already
  released, because that breaks existing multiworlds.

## Style

Follow the style of the code around your change.

- Mod is writen in camelCase. Apworld in Pascal as outlined in the Archipelago code of conduct.
- Every module, function and data field has to be used. Please do not leave dead code behind. Code that is kept for
  later development is commented out and says so, like `-- Dev checks, can be used for later dev`.
- Debug output that players do not need goes to the log file only (`logger.writeToFile`). Use `logger.write` for
  what should also appear in the console like debugging.
- Everything the mod writes at run time goes in the `cached` and `logs` folders.

## What not to commit

- Log files or `.data` cache files from your own games. `.gitignore` covers them, but check `git status`.
- Built files such as the `dist/` folder or an `.apworld`.
- Anything that is not yours to share, such as game files or assets from Palworld.

## Releases

Maintainers publish releases. How that works is described in [docs/PUBLISHING.md](docs/publishing.md).

## License

By sending a contribution you agree that it is released under the project's [MIT license](LICENSE).
