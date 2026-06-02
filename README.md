<table>
  <tr>
    <td width="280" valign="middle">
      <img
        width="256"
        height="256"
        alt="PSC Store"
        src="files/media/project_eris/etc/project_eris/SUP/launchers/pscstore/pscstore.png"
      />
    </td>
    <td valign="middle">
      <h1>PSC Store</h1>
      <p><i>A modern PS Classic library hub for Project Eris.</i></p>
    </td>
  </tr>
</table>

PSC Store brings the PS Classic back into the modern age as a clean hub for managing your PS1 library on Project Eris. It focuses on keeping your library under your control: USB and Internal game management, physical-disc import/play workflows, saves, playtime, updates, and optional external-source downloads all live inside one console-friendly interface.

External Sources is disabled by default. PSC Store can still be used for local library management, USB games, PS1 Game Disc installs, saves, and physical-disc import/play workflows without enabling external sources.

---

## Content Notice

PSC Store is a library management tool for Project Eris. Optional physical-disc and user-provided source workflows help manage content you supply yourself.

Game database details and cover art are read from the metadata already provided by the preexisting Project Eris setup. PSC Store's bundled database is a lightly adjusted version of that same database, changed only to add the PS1 Game Disc entry and tighten genre metadata.

PSC Store does not host, bundle, mirror, store, or include copyrighted games, BIOS files, ROMs, or disc images.

PSC Store does not include external source links by default.

PSC Store does not provide, recommend, host, scrape, or maintain game download sources.

When External Sources is enabled, PSC Store creates a blank source TSV file in the root of your Project Eris USB:

`/ps1_external_sources.tsv`

Add your own lawful source entries to that file. PSC Store will only request external downloads from entries you provide.

LibCrypt compatibility, when needed, is handled locally with the on-device patcher where possible for preservation purposes. PSC Store does not retrieve SBI files.

External sources are not owned, operated, controlled, verified, or endorsed by PSC Store or its creator.

Physical-disc import and PS1 Game Disc features are intended only for your own original discs and locally supplied content.

PSC Store is not affiliated with, endorsed by, or sponsored by Sony Interactive Entertainment, Project Eris, or ModMyClassic. All names, trademarks, and content remain the property of their respective owners.

You are responsible for making sure any content you download, import from disc, replace, or play is legally permitted for you to use in your region.

External Sources is disabled by default. By enabling it or continuing, you accept responsibility for your content choices.

---

## Core Features

- **Library hub:** Browse, search, sort, favourite, install, uninstall, and manage PS1 games from the PS Classic itself.
- **Disc-first workflow:** Import original PS1 discs on-console with a compatible external USB disc drive.
- **PS1 Game Disc launcher:** Install a local disc launcher entry for playing original discs through Project Eris/RetroArch.
- **USB and internal management:** Install games to USB or internal storage where supported, with clear install-location status. PSC Store is built around installing each game once, so the same game cannot be installed to both USB and internal storage at the same time.
- **Save management:** View, restore, backup, and manage saves from inside the PSC Store interface.
- **Playtime tracking:** Track play sessions when Project Eris networking/time sync is available.
- **Suggested Games:** Surface local suggestions and disc-aware entries, including inserted-disc matches.
- **Optional external sources:** External downloads are opt-in; when External Sources is enabled, PSC Store generates a blank source TSV file for your own lawful source entries.
- **App updates:** PSC Store can update itself through a signed HTTPS update channel.
- **Console-native UI:** Designed for controller navigation, modals, button guides, and the PS Classic display.

---

## Screenshots

Screenshots are grouped in the rough order you would use PSC Store on-console.

### Home And Launcher

PSC Store launches from the Project Eris/Sony UI like any other launcher, then opens into a dashboard for library status, suggestions, downloads, sessions, and quick actions. On Home, you can also hide the main UI to leave a clean background with the clock and status icons for Wi-Fi and external disc-drive detection.

<p>
  <img src="docs/screenshots/pscstore_app_home.jpg" width="49%" alt="PSC Store home hub">
  <img src="docs/screenshots/pscstore_app_launcher_sony_ui.jpg" width="49%" alt="PSC Store launcher in Sony UI">
</p>

<p>
  <img src="docs/screenshots/pscstore_app_hide_ui_time_and_icons.jpg" width="49%" alt="Hidden Home UI with clock and status icons">
</p>

### Browse Your Library

All Games is the main catalogue view. Suggested Games surfaces local recommendations and disc-aware entries, keeping the PS1 Game Disc launcher and inserted-disc match easy to reach.

<p>
  <img src="docs/screenshots/pscstore_app_all_games.jpg" width="49%" alt="All Games catalogue">
  <img src="docs/screenshots/pscstore_app_suggested_games.jpg" width="49%" alt="Suggested Games list">
</p>

USB Games and Internal Games show what is already installed, where it lives, and what can be managed directly from the console. You can also sort installed games alphabetically.

PSC Store is built around installing each game once. The same game cannot be installed to both USB and internal storage at the same time, but if an older setup or manual change leaves a game installed in both places, PSC Store can still let you uninstall either location. Both installs share a single save-backup identity, so one save backup applies to that game across USB and internal storage.

<p>
  <img src="docs/screenshots/pscstore_app_USB_games.jpg" width="49%" alt="USB Games list">
  <img src="docs/screenshots/pscstore_app_internal_games.jpg" width="49%" alt="Internal Games list">
</p>

Favourites and Download History give you fast access to games you care about and a clear record of what PSC Store has installed.

<p>
  <img src="docs/screenshots/pscstore_app_favourites.jpg" width="49%" alt="Favourites list">
  <img src="docs/screenshots/pscstore_app_download_history.jpg" width="49%" alt="Download history">
</p>

### Search And Filtering

Search is built for a controller, not a keyboard you have to plug in. You can search by **Title**, **Serial**, **Region**, **Genre**, **Developer**, **Publisher**, **Year Released**, and **Players**.

Text searches use the on-screen keyboard. Region, genre, year, and player-count searches use selectable lists, with multi-select support where it makes sense. Search history lets you quickly reuse recent terms, and filter toggles let you choose exactly which fields are active.

<p>
  <img src="docs/screenshots/pscstore_app_search_keyboard.jpg" width="49%" alt="Search keyboard">
  <img src="docs/screenshots/pscstore_app_search_filter_toggles.jpg" width="49%" alt="Search filter toggles">
</p>

<p>
  <img src="docs/screenshots/pscstore_app_search_history.jpg" width="49%" alt="Search history">
  <img src="docs/screenshots/pscstore_app_multi_select_filtered_search_lists_genre.jpg" width="49%" alt="Filtered search multi-select">
</p>

### Actions And Installs

The action screen keeps common jobs in one place: install, uninstall, show in USB Games, add or remove favourites, and open save tools. The Install Location prompt lets you choose where that selected game should be installed.

<p>
  <img src="docs/screenshots/pscstore_app_actions_modals.jpg" width="49%" alt="Actions modal">
  <img src="docs/screenshots/pscstore_app_install_location_prompt.jpg" width="49%" alt="Install location prompt">
</p>

When a job finishes, PSC Store shows a clear completion screen instead of leaving you guessing.

<p>
  <img src="docs/screenshots/pscstore_app_download_complete.jpg" width="49%" alt="Download complete">
</p>

### Saves And Backups

PSC Store includes save management from the console. You can check whether a save backup exists, back up saves before removing games, and restore saves after installing a game again.

Save backups are stored in the user-accessible `/saves` folder at the root of your Project Eris USB.

<p>
  <img src="docs/screenshots/pscstore_app_saves_backup_management_actions_modal.jpg" width="49%" alt="Saves backup management">
  <img src="docs/screenshots/pscstore_app_backup_status_indicators.jpg" width="49%" alt="Backup status indicators">
</p>

When PSC Store detects a matching save backup after an install, it can offer to restore it for you.

<p>
  <img src="docs/screenshots/pscstore_app_restore_saves_prompt.jpg" width="49%" alt="Restore saves prompt">
</p>

### Physical Disc Import

Physical-disc import is designed around original discs and a compatible external USB disc drive. PSC Store can detect inserted discs, ask where to install, then show progress while it works.

<p>
  <img src="docs/screenshots/pscstore_app_disc_import_prompt.jpg" width="49%" alt="Disc import prompt">
  <img src="docs/screenshots/pscstore_app_disc_import_progress.jpg" width="49%" alt="Disc import progress">
</p>

### PS1 Game Disc Launcher

The PS1 Game Disc launcher is a local entry PSC Store can install for direct disc playback. It lets you play compatible original discs through Project Eris/RetroArch without first importing them.

<p>
  <img src="docs/screenshots/pscstore_app_disc_launcher_entry_USB_games.jpg" width="49%" alt="PS1 Game Disc entry in USB Games">
  <img src="docs/screenshots/disc_launcher_sony_ui.jpg" width="49%" alt="Disc Launcher in Sony UI">
</p>

<p>
  <img src="docs/screenshots/disc_launcher_sony_ui_shared_memory_card.jpg" width="49%" alt="Disc Launcher shared memory card">
</p>

The disc launcher uses one shared memory card across the games you play with it. Save states are game-aware: if a resume point belongs to a different disc, the launcher rejects it instead of trying to resume the wrong game.

<p>
  <img src="docs/screenshots/disc_launcher_sony_ui_savestate.jpg" width="49%" alt="Disc Launcher save state">
  <img src="files/media/project_eris/etc/project_eris/SUP/launchers/pscstore/assets/pscdisclauncher-error-screens/ra_disc_launcher_wrong_disc.png" width="49%" alt="Disc save state error">
</p>

If the drive is missing, the disc is invalid, or the saved resume point does not match the inserted disc, the launcher shows a clear message explaining what needs fixing.

<p>
  <img src="files/media/project_eris/etc/project_eris/SUP/launchers/pscstore/assets/pscdisclauncher-error-screens/ra_disc_launcher_invalid_disc.png" width="49%" alt="No or invalid disc error">
  <img src="files/media/project_eris/etc/project_eris/SUP/launchers/pscstore/assets/pscdisclauncher-error-screens/ra_disc_launcher_error.png" width="49%" alt="No external disc drive error">
</p>

### Playtime And Sessions

PSC Store can show play sessions and playtime history when Project Eris networking and time sync are available.

<p>
  <img src="docs/screenshots/pscstore_app_sessions.jpg" width="49%" alt="Sessions">
  <img src="docs/screenshots/pscstore_app_playtime.jpg" width="49%" alt="Playtime">
</p>

<p>
  <img src="docs/screenshots/pscstore_app_sessions_info.jpg" width="49%" alt="Sessions info">
</p>

### Settings And Notices

External Sources is opt-in. The Content Notice explains what PSC Store does, what it does not host, and what responsibility remains with the user. It is shown on first launch, and when External Sources is enabled it is shown before attempted downloads. Credits and References provides attribution for the projects, tools, libraries, fonts, and references PSC Store uses or builds alongside. Both are available in Settings under the About section.

<p>
  <img src="docs/screenshots/pscstore_app_content_notice.jpg" width="49%" alt="Content Notice">
  <img src="docs/screenshots/pscstore_app_credits.jpg" width="49%" alt="Credits and References">
</p>

<p>
  <img src="docs/screenshots/pscstore_app_settings.jpg" width="49%" alt="Settings">
</p>

Settings include a Delete Data option for clearing PSC Store's on-device app data, including playtime, download history, settings, and sessions. Installed games remain installed, and save backups are kept safe.

<p>
  <img src="docs/screenshots/pscstore_app_delete_data_prompt.jpg" width="49%" alt="Delete data prompt">
</p>

---

## Install

Download the latest files from the GitHub Releases page:

- `pscstore-install-vX.X.X.mod` - install
- `pscstore-uninstall-vX.X.X.mod` - uninstall

1. Copy `pscstore-install-vX.X.X.mod` to your Project Eris USB inside `/project_eris/mods/`.
2. Boot the PS Classic and let Project Eris install the mod.
3. Restart the console at least once after installation so PSC Store and Project Eris network settings can initialize cleanly.
4. For most PSC Store features, including external source downloads and playtime logging, enable networking in Project Eris settings and connect to a network. Project Eris commonly works with the TP-Link TL-WN725N Nano 150Mbps Wireless N USB adapter (SKU: TL-WN725N); other compatible adapters may also work.
5. Optional: enable **"Launch RetroArch games from stock UI"** in Project Eris settings if you want stock UI playtime logging. PSC Store's built-in PS1 Game Disc launcher does not require this.

External Sources remains disabled by default after installation.

External downloads are opt-in. When External Sources is enabled, PSC Store generates a blank source TSV file for your own lawful source entries. PSC Store does not include, fetch, scrape, or maintain any third-party game-download source list.

PSC Store creates the source file at the root of the Project Eris USB:

- `/ps1_external_sources.tsv`

Follow the notes inside the generated TSV template.

---

## Physical Disc / External Drive Notes

You can import your own original discs directly on-console after installation with a compatible external USB disc drive.

External disc drives may need extra power. A Y-splitter, rear OTG power plus front-port data, a powered USB hub with its data line plugged into one of the front controller ports, a front-port power mod, or an internal USB hub can help. OTG-only can work, but may be flaky, especially for direct disc playback via the disc launcher (PS1 Game Disc).

---

## Internal Games / Homebrew

If you intend to add, remove, or replace internal games, back up the original 20 included games first. PSC Store currently does not include a stock internal-game backup/restore tool.

For internal-game backups, consider the Project Eris backup mod `projecteris-internal-apps_1.0.0_SONYPSC-2713d08.mod` from the [Project Eris backup mod archive](https://github.com/Jetup13/%50%6C%61%79%53%74%61%74%69%6F%6E-Classic-Wiki/releases/tag/Backup).

That mod provides a **Backup internal games** launcher which can copy the original internal games to your Project Eris USB. A built-in PSC Store backup/restore flow may be added in a future release.

Community-made homebrew game provisioning may also be added in the future. For now, homebrew can still be added through the Project Eris desktop app, or played through the PS1 Game Disc launcher when burned to compatible physical media.

Game translation support and PSC Store app translations are planned and will be coming soon.

---

## Updates

PSC Store uses a signed HTTPS update channel. The app downloads a release manifest, verifies its signature, then verifies each updated file against the manifest before applying it.

You can check for updates manually by pressing **[Select]** on Home, or from Settings under **Update options** -> **Check for updates**.

By default, **App update reminders** is set to **Remind when available**. If an update is available, PSC Store prompts immediately at startup, then every 30 minutes if you choose **Remind me later**. Choosing **Do not remind me** in the update-available prompt sets **App update reminders** to **Do not remind me**, which disables automatic update reminders.

If the automatic update channel is unavailable, PSC Store can still be updated manually by installing a newer `pscstore-install-vX.X.X.mod` from USB.

---

## Uninstall

1. If you installed the Disc Launcher / PS1 Game Disc entry, remove it first from PSC Store under USB Games.
2. Copy `pscstore-uninstall-vX.X.X.mod` to your Project Eris USB inside `/project_eris/mods/`.
3. Boot the PS Classic and let Project Eris uninstall the mod.

The uninstall package removes PSC Store itself. It does not delete your installed games or your save backups in the `/saves` folder at the root of the Project Eris USB.

---

## Notes

- Project Eris is required.
- Networking is optional for local features, but required for external sources, app update checks, and reliable playtime/time sync.
- External Sources is opt-in, disabled by default, and does nothing unless you enable it and add your own lawful source entries to the blank TSV file PSC Store generates.
- Keep Project Eris SSH access on trusted local networks only. Do not expose the console's SSH service to public or untrusted networks.
- PSC Store modifies Project Eris/PS Classic files; use at your own risk.
- Keep backups of important saves before changing storage layouts or uninstalling entries.

---

## Credits and References

PSC Store uses, integrates with, references, or is built alongside the following projects, libraries, tools, and system components. Mention here does not imply endorsement or affiliation.

The top-level [LICENSE.md](LICENSE.md) scopes this release repository's own materials. Packaged third-party license texts, notices, and source-availability notes are included under `files/media/project_eris/etc/project_eris/SUP/launchers/pscstore/licenses/`.

- Project Eris / ModMyClassic:
  - https://github.com/Project-Eris-psc
  - https://modmyclassic.com/
  - https://modmyclassic.com/wp-content/uploads/2025/08/Project_Eris-v1.0.0-fb9d576.zip
  - PSC Store is designed for Project Eris and uses Project Eris launcher paths, function-script conventions, networking behavior, theme assets, stock UI integration points, and RetroArch launch flow.
  - Project Eris function scripts included or modified in the package are based on Project Eris / ModMyClassic materials and carry ModMyClassic GPL notices.

- RetroArch: https://www.retroarch.com/
  - PSC Store includes a patched RetroArch 1.8.8 build for disc-project workflows.
  - This patched RetroArch build fixes several resume point and save-state loading issues when using the disc-project core.
  - Source for the patched PSC Store RetroArch 1.8.8 build is published at: https://github.com/hampter-mods/psc-RetroArch-1.8.8

- PCSX-ReARMed / disc-project core: https://github.com/libretro/pcsx_rearmed
  - PSC Store includes the disc-project core, based on PCSX-ReARMed, for direct physical-disc playback.
  - The disc-project core is compiled with Alex Free's libcrypt-patcher embedded, so compatible LibCrypt-protected games can be patched locally for preservation purposes while being played directly from disc.
  - Source for the PSC Store disc-project PCSX-ReARMed core is published at: https://github.com/hampter-mods/psc-PCSX-ReARMed-discproject

- Alex Free / libcrypt-patcher / lcp v1.1.0: https://github.com/alex-free/libcrypt-patcher
  - Used locally for LibCrypt compatibility handling where possible for preservation purposes.
  - PSC Store uses it to patch compatible LibCrypt-protected games during External Sources installs and physical-disc imports.
  - It is also embedded into the disc-project PCSX-ReARMed core for direct-disc playback patching.

- Shadertoy Background cube from Padej_: https://www.shadertoy.com/view/33SBWz
  - PSC Store's background cube is based on a slightly modified version of the Shadertoy shader "fill glow & outline glow" by Padej_, created 2025-11-05.
  - The referenced shader is described as a simple glowing shader with a `fillCube` setting.

- SDL2, SDL2_image, and SDL2_ttf: https://www.libsdl.org/
  - Used for input, display/window handling, image loading, and text rendering.

- OpenGL ES / EGL
  - Used for PSC Store's accelerated UI rendering.

- SQLite: https://www.sqlite.org/
  - PSC Store links against SQLite/libsqlite3 for local history/playtime storage and Project Eris game database lookups.
  - Project Eris function scripts use the SQLite command-line tool already provided by Project Eris for Project Eris database operations.

- libpng: http://www.libpng.org/pub/png/libpng.html
  - Used through image/font/UI dependencies and packaging build dependencies.

- curl / libcurl 8.5.0: https://curl.se/
  - Used for update checks, External Sources requests, downloads, and HTTPS transfer handling.

- OpenSSL 1.1.1u: https://www.openssl.org/
  - Used by bundled/static curl tooling and release-signing workflows.

- zlib: https://zlib.net/
  - Used by bundled/static HTTPS tooling and compatible upstream components for compression support.

- curl CA extract / Mozilla CA bundle: https://curl.se/docs/caextract.html
  - Used for PSC Store's HTTPS trust bundle.

- Let's Encrypt certificates: https://letsencrypt.org/certificates/
  - Helper certificates are included for PSC TLS bundle support.

- 7-Zip / 7zr 23.01: https://www.7-zip.org/
  - Used for archive extraction in install/download workflows.

- UPX: https://upx.github.io/
  - The bundled RetroArch binary is UPX-packed and includes the UPX decompressor stub under the UPX compressed-executable exception.

- Linux kernel optical-drive modules: https://www.kernel.org/
  - PSC Store includes `cdrom.ko`, `sg.ko`, and `sr_mod.ko` for external optical-drive support on Project Eris systems.
  - The module binaries are credited to honeylab's CD-ROM driver article: https://honeylab.hatenablog.jp/entry/2019/01/16/002111
  - These module binaries report GPL kernel-module metadata. PSC Store includes provenance and GPLv2 notice text for them.

- Project Eris backup mod archive: https://github.com/Jetup13/%50%6C%61%79%53%74%61%74%69%6F%6E-Classic-Wiki/releases/tag/Backup
  - Referenced for users who need to back up original internal games.

- Fonts and theme assets
  - PSC Store uses existing Project Eris/stock theme fonts and assets where available, including OFL fonts Cabin Regular, Ezarion, and Rounded M+ 1c.
  - These fonts are under the SIL Open Font License.

- Project Eris metadata and PSC Store assets
  - PSC Store's bundled `pcsx_data.db` and game cover art are based on materials already provided by Project Eris.
  - The bundled `pcsx_data.db` is a lightly adjusted version of the Project Eris metadata database, changed only as described in the Content Notice.
  - PSC Store app artwork, icons, and error screens are generated by the project maintainer.

- SIL Open Font License 1.1: https://openfontlicense.org/
- GNU General Public License: https://www.gnu.org/licenses/gpl-3.0.html
- GNU General Public License v2: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
- GNU Lesser General Public License: https://www.gnu.org/licenses/lgpl-2.1.html

This product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit. It also includes cryptographic software written by Eric Young and software written by Tim Hudson. 7-Zip is Copyright (C) Igor Pavlov and is distributed under the GNU LGPL, with additional BSD 3-clause and unRAR restriction notes in the 7-Zip source license. UPX is used with its compressed-executable exception. All third-party names, trademarks, and content remain the property of their respective owners.
