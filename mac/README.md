# Build Gajim on macOS

To build omemo-dr, nbxmpp and Gajim on macOS, you can follow [the wiki page](https://dev.gajim.org/gajim/gajim/-/wikis/help/Gajim-on-macOS).

But in this directory we also provide a Bash script (`gajim-macos-helper.sh`) to help creating virtual environments for omemo-dr, nbxmpp and Gajim in Mac OS, build it, start it from the virtual environment, and also create a `.dmg` bundle.

## Requirements for this script

You just need [Brew](https://brew.sh) (follow instructions on the website) and Bash (installed by default on macOS), the script will install and do the rest.

## Build the current checkout

To build the checkout itself instead of cloning the versions configured in
`gajim-macos-helper.sh`, use Homebrew Python 3.14. If you use pyenv, select an
installed Python 3.14.x version first.

From the repository root:

```
pyenv local 3.14.6  # optional; use an installed 3.14.x version
brew install gtk4 libadwaita pygobject3 adwaita-icon-theme libsoup@3 \
    gstreamer gtksourceview5 libspelling gettext librsvg
python3.14 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e .
python -m pip install pyobjc-framework-Cocoa pyinstaller
export GI_TYPELIB_PATH="/opt/homebrew/lib/girepository-1.0:/opt/homebrew/opt/gtksourceview5/lib/girepository-1.0:/opt/homebrew/opt/libspelling/lib/girepository-1.0:/opt/homebrew/share/gir-1.0"
export XDG_DATA_DIRS="/opt/homebrew/share:${XDG_DATA_DIRS:-}"
export DYLD_LIBRARY_PATH="/opt/homebrew/lib:${DYLD_LIBRARY_PATH:-}"
./mac/makebundle.py
```

This creates `dist/Gajim.app`. To create a disk image from it, run:

```
hdiutil create -volname Gajim -srcfolder dist -ov -format UDZO gajim-source.dmg
```

The current macOS bundle configuration explicitly selects GTK4 typelibs and
restricts GStreamer plugin discovery to the bundled `gst_plugins` directory.
Do not remove unrelated libraries from `Contents/Frameworks` to work around
these issues.

## Usage

The `gajim-macos-helper.sh` script need to be copied alone in an empty directory of your choice, without anything else.

Always run the `gajim-macos-helper.sh` script from within the directory where you placed it (`./gajim-macos-helper.sh <argument>` style).

### Build specific version of omemo-dr, nbxmpp and Gajim

Always check the versions variables inside the `gajim-macos-helper.sh` script: check tags dates on Gitlab to make [omemo-dr](https://dev.gajim.org/gajim/omemo-dr/-/tags), [nbxmpp](https://dev.gajim.org/gajim/python-nbxmpp/-/tags) and [Gajim](https://dev.gajim.org/gajim/gajim/-/tags) versions match (example: Gajim version `2.4.1` match omemo-dr version `1.1.0` and nbxmpp version `7.0.0`)

To build (or rebuild) a new version of omemo-dr, nbxmpp and Gajim, run:

```
./gajim-macos-helper.sh build
```

> Note: If a previous build was done this way, it will be destroyed first. This command install dependencies via Brew, create a Python virtual environment and build omemo-dr, nbxmpp and Gajim.

#### Build in CI mode

The "CI mode" install all dependencies system side (without any virtual environment) and is used with the goal of building a `.dmg` file after this. It is used mostly in CI or containers, don't use it for dev purpose.

```
./gajim-macos-helper.sh build ci
```

You can also build a specific version of Gajim, `omemo-dr` and `nbxmpp` will installed via `pip` instead of git source:

```
./gajim-macos-helper.sh build ci 2.4.1
```

### Start the Gajim version you just built

To start built version, run:

```
./gajim-macos-helper.sh start
```

> Note: This command enter inside the Python virtual environment and launch Gajim.

### Create a DMG file (CI mode)

The "CI mode" install all dependencies system side (without any virtual environment) and need to be run after the `build ci` command. It is used mostly in CI or containers, don't use it for dev purpose.

To create a `.dmg` file, run:

```
./gajim-macos-helper.sh create-dmg ci
```

> Note: This command use PyInstaller to create a `gajim-<version>.dmg` file.

You can also build a specific version of Gajim (mostly used for Gajim's CI):

```
./gajim-macos-helper.sh create-dmg ci 2.4.1
```
