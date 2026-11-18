# ntm-randomizer
This repo is designed to be an all-in-one solution for the MiSTer for randomizing Neo Turf Masters hole order and pin locations.

> [!NOTE]
> All credit goes to [StiNKzz for turfmastrand](https://github.com/StiNKzz/turfmastrand) and [carmiker for lithogen](https://github.com/carmiker/lithogen).  This repo only serves to compile and distribute platform compatible binaries and related scripts to call them.

## Installation
> [!IMPORTANT]
> All installations require an unmodified, merged MAME `turfmast.zip` ROM in `/media/fat/ntm-randomizer`.
The binaries and scripts can be installed via `downloader.ini` or manual build.

### downloader.ini (Recommended)

```ini
[albertprimettv/ntm-randomizer]
db_url = https://raw.githubusercontent.com/albertprimettv/ntm-randomizer/db/db.json.zip
```

This will install all required binaries to `/media/fat/ntm-randomizer`, [ntm-randomizer.sh](Scripts/ntm-randomizer.sh), and [ntm-randomizer.ini.template](Scripts/ntm-randomizer.ini.template) into `Scripts` directory of your SD card.

### Manual Build
Build steps have been tested on a linux/amd64 docker build host.  This was additionally verified with `--platform linux/arm64` to emulate Apple Silicon build hosts.

Requirements
- git
- Docker v23.0+

1. Clone the repository with submodules
   
    ```git clone --recurse-submodules https://github.com/albertprimettv/ntm-randomizer.git```
   
1. Build the binaries via docker.  This will create a new `ntm-randomizer` directory containing the compiled `lithogen` and `turfmastrand` binaries.

    ```DOCKER_BUILDKIT=1 docker build --target mister-export --output type=local,dest=./ntm-randomizer .```

1. Copy the created `ntm-randomizer` directory, and contents of the `Scripts` directory to the root of your SD card (i.e., `/media/fat/`).  It should resemble something like below:

    ```text
    /media/fat
    |
    ...
    ├── ntm-randomizer/
    │   ├── lithogen
    │   └── turfmastrand
    ...
    ├── Scripts/
    |   ...
    │   ├── ntm-randomizer.sh
    │   ├── ntm-randomizer.ini.template
    |   ...
    ...

## How it works
Upon running [ntm-randomizer.sh](Scripts/ntm-randomizer.sh):
1. [turfmastrand](https://github.com/StiNKzz/turfmastrand) is called to randomize hole order (and optionally pin locations).
1. The unmodified `turfmast.zip` is copied to `/tmp/turfmast.zip` with the updated `200-p1.p1` containing randomizations.
1. [lithogen](https://github.com/carmiker/lithogen) repacks `/tmp/turfmast.zip` into `/tmp/turfmastrand.neo`.
1. An `/tmp/ntm-randomizer.mgl` is created in pointing to `/tmp/turfmastrand.neo` and launched.

The default behavior is to only write data to `/tmp` to minimize SD card write cycles.  Saving generated `.neo` files is disabled by default and must be manually enabled via `SAVE_NEO=1` in the .ini file.

## Customizing via the .ini file
A `Scripts/ntm-randomizer.ini` can be created using the installed [`Scripts/ntm-randomizer.ini.template`]([ntm-randomizer.ini.template]) to override various settings.  Default values are used if `Scripts/ntm-randomizer.ini` does not exist.

```ini
# ntm-randomizer.ini

# REQUIRED
# Full path to lithogen, turfmastrand
# Default: TOOLS_DIR="/media/fat/ntm-randomizer"
TOOLS_DIR="/media/fat/ntm-randomizer"

# REQUIRED
# Directory to turfmast.zip; can be changed if ROM already exists elsewhere on your SD card
# Default: TURFMAST_DIR="/media/fat/ntm-randomizer"
TURFMAST_DIR="/media/fat/ntm-randomizer"

# OPTIONAL
# SAVE_NEO=0 to keep the file in /tmp/, will lose the file on reboot
# SAVE_NEO=1 to save the file to OUTPUT_DIR
SAVE_NEO=0

# REQUIRED if SAVE_NEO=1
# Output directory for the generated .neo file if SAVE_NEO=1
# Default: OUTPUT_DIR="/media/fat/games/NEOGEO"
OUTPUT_DIR="/media/fat/games/NEOGEO"

# OPTIONAL
# Keep one or all randomized files.
# Ignored if SAVE_NEO=0
# OVERWRITE_NEO=0 to keep all randomized .neo files; timestamp will be appended to .neo file
# OVERWRITE_NEO=1 to keep only 1 .neo file
# Default: OVERWRITE_NEO=0
OVERWRITE_NEO=0

# OPTIONAL
# Launch the game automatically after running the script
# AUTOLAUNCH=0 to skip launching the game
# AUTOLAUNCH=1 to automatically launch the game
# Default: AUTOLAUNCH=1
AUTOLAUNCH=1

# OPTIONAL
# Generate random pin locations
# RAND_PINS=0 to use default pin locations
# RAND_PINS=1 to generate random pin locations
# Default: RAND_PINS=0
RAND_PINS=0
```

## Uninstalling
- Remove the entry from `downloader.ini`
- Remove `/media/fat/ntm-randomizer`

## Troubleshooting
### [/media/fat/ntm-randomizer] does not exist
Run `update_all.sh` to reinstall the required files onto your SD card.

### [lithogen/turfmastrand] does not exist
Run `update_all.sh` to reinstall the required files onto your SD card.

### [turfmast.zip] not found
Place a merged copy of the MAME `turfmast.zip` ROM in `/media/fat/ntm-randomizer`.

### Modified [turfmast.zip] found
The [turfmastrand](https://github.com/StiNKzz/turfmastrand) tool requires an unmodified `200-p1.p1` ROM.  Verify your `turfmast.zip` is from an unmodified merged MAME ROM set.

## Version History
### 2026-11-15
- Move default `turfmast.zip` location to `ntm-randomizer`

### 2026-11-14
- Initial release

## Acknowledgments
* [turfmastrand](https://github.com/StiNKzz/turfmastrand): StiNKzz on Neo Turf Masters NTM Tour discord.
* [lithogen](https://github.com/carmiker/lithogen): carmiker
* [DB-Template_MiSTer](https://github.com/theypsilon/DB-Template_MiSTer): theypsilon
