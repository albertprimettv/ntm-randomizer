# ntm-randomizer
This repo is designed to be an all-in-one solution for the MiSTer for randomizing Neo Turf Masters hole order and pin locations.

Note: I do not take credit for the game randomization or .neo creation; this is only distribution of de10-nano compatible compiled binaries and a script to call the binaries.

## Installation
### downloader.ini:

```ini
[albertprimettv/ntm-randomizer]
db_url = https://raw.githubusercontent.com/albertprimettv/ntm-randomizer/db/db.json.zip
```

This will install all required binaries to `/media/fat/ntm-randomizer`, [ntm-randomizer.sh](Scripts/ntm-randomizer.sh), and [ntm-randomizer.ini.template](Scripts/ntm-randomizer.ini.template) into `Scripts` directory of your SD card.

### turfmast.zip
Place a merged copy of the MAME `turfmast.zip` ROM in `/media/fat/games/NEOGEO`.

NOTE: If you are using external storage or networking mounting to a different location, create `Scripts/ntm-randomizer.ini` and set `TURFMAST_DIR` appropriately.

## How it works
Upon running [ntm-randomizer.sh](Scripts/ntm-randomizer.sh):
1. Call [turfmastrand](https://github.com/StiNKzz/turfmastrand) to randomize hole order (and optionally pin locations)
1. Call [lithogen](https://github.com/carmiker/lithogen) to build a NeoSD-compatible .neo file
1. Launch the game via an `.mgl` file; (enabled by default)

The default behavior is to only write data to `/tmp` to minimize SD card write cycles.  Saving generated .neo files is disabled by default and must be manually enabled via `SAVE_NEO=1` in the .ini file.

## Customizing via the .ini file
A `Scripts/ntm-randomizer.ini` can be created using the installed [`Scripts/ntm-randomizer.ini.template`]([ntm-randomizer.ini.template]) to override the tool and output install path if you use external storage, enable saving all randomized courses, or generate random pin locations.  Default values are used if `Scripts/ntm-randomizer.ini` does not exist.

```ini
# ntm-randomizer.ini

# REQUIRED
# Full path to lithogen, turfmastrand
# Default: TOOLS_DIR="/media/fat/ntm-randomizer"
TOOLS_DIR="/media/fat/ntm-randomizer"

# REQUIRED
# Directory to turfmast.zip; may need to be changed if using external storage or networking mounting script
# Default: TURFMAST_ZIP="/media/fat/games/NEOGEO"
TURFMAST_DIR="/media/fat/games/NEOGEO"

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
The script checks for `/media/fat/games` on a single SD card and will fail if `games` is read from an external device, or mounted to a different directory.  Create a `Scripts/ntm-randomizer.ini` via the template file and updated `TURFMAST_ZIP` to match your storage configuration.

### Modified [turfmast.zip] found
The (turfmastrand)[https://github.com/StiNKzz/turfmastrand] tool requires an unmodified `200-p1.p1` ROM.  Verify your `turfmast.zip` is an unmodified, merged ROM set.

## Refs
- https://github.com/StiNKzz/turfmastrand
- https://github.com/carmiker/lithogen