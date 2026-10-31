# Publishing

Three things get published: the code on **GitHub**, the mod on the **Steam Workshop** and the world as an
**`.apworld`** on the GitHub releases page.

### Releasing the apworld

1. Test the apworld in [Waimea](https://aptests.ionium.fyi) or [Githublink to Waimea](https://github.com/mooinglemur/waimea) first. It runs an apworld's unit tests and generation fuzzing in your browser, the way the Archipelago-index CI does. Nothing is uploaded, and the results are gone when you close the tab unless you save the report.
2. Raise `world_version` in `apworld/palworld/archipelago.json`.
3. Commit, then tag and push:

   ```
   git tag v0.1.0
   git push origin v0.1.0
   ```

4. Upload the mod and apworld to the release page

## Steam Workshop

Palworld only installs a Workshop mod from a folder that [Palworld Mod Uploader](https://github.com/pocketpairjp/PalworldModUploader) created, so the Workshop item is
made with that tool and the files of `mod/` are copied into it. The mod is a plain `Lua` mod: Palworld copies
`Scripts`, `cached` and `logs` into `Mods\NativeMods\UE4SS\Mods\APPalworld\` when the game starts.

### First upload

1. Subscribe to **UE4SS Experimental (Palworld)** and enable it under **Options → Mod Management**. Start Palworld
   once so `Mods\PalModSettings.ini` exists.
2. Start **Palworld Mod Uploader** from your Steam library.
3. Click **Create New Mod** and tick **Lua**. This registers an empty Workshop item right away and creates a folder
   named after the item's id under the Workshop content directory.
4. Copy everything from this repository's `mod/` folder into that folder and overwrite what is there
   (`Info.json`, `thumbnail.png`, `LICENSE`, `Scripts`, `cached`, `logs`). Keep `.workshop.json`. The uploader sends
   the **whole folder** to Steam, so nothing else may be in it.
5. Select the mod in the uploader and check the fields:
   - **Package Name** must be letters and digits only.
   - **Dependencies → Edit** lists the mods found in your Workshop content directory. Pick **UE4SS Experimental
     (Palworld)**, which is only listed while you are subscribed. Its package name should be `UE4SSExperimentalPW`.
   - **Debug Mode** off.
6. Press **Save Info.json**. The uploader writes the file in its own format, so copy it back over `mod/Info.json` in
   the repository to keep both the same.
7. Press **Upload To Steam** and enter change notes. The Workshop page opens when it is done.
8. On the Workshop page: paste `docs/workshop-description.txt` as the description, set the visibility, and under
   **Add Required Item** add **UE4SS Experimental (Palworld)** so Steam shows subscribers the requirement.

### Updating

1. Delete `Scripts`, `cached` and `logs` in the Workshop item folder, then copy `mod/` into it again, so that files
   you removed from the repository do not stay in the upload.
2. Change `Version` in `mod/Info.json` and in the item folder's `Info.json`. Palworld compares it as plain text and
   only reinstalls when it differs (or when `DebugMode` is `true`, which you should never publish). The uploader warns
   you if it equals the version of your last upload.
3. Press **Upload To Steam** again.

### Things to know

- The mod finds its own folder from the location of its script (`mod/Scripts/ap/paths.lua`), so it works in the
  Workshop location and in a manual install.
- The mod ships `lua-apclientpp.dll`. It is the unmodified MIT-licensed library, its license is next to it. Read the
  current Steam Workshop and Palworld modding rules about native DLLs before you publish.
- Players must not have UE4SS installed by hand at the same time as the Workshop UE4SS. To make Workshop UE4SS version work Delete/Move `dwmapi.dll` or `xinput1_3.dll` in `Pal\Binaries\Win64` in case you installed it by hand.
