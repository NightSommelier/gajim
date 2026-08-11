# -*- mode: python -*-

import glob
import os
import sys

from PyInstaller.utils.hooks import collect_submodules


cwd = os.getcwd()
sys.path.insert(0, cwd)

modules = glob.glob("gajim/common/modules/*.py")
hiddenimports = [
    "gajim.common.modules." + os.path.basename(path)[:-3]
    for path in modules
    if not path.endswith("__init__.py")
]
hiddenimports += collect_submodules("gajim.common.winapi")
sys.path.pop(0)

gst_include_plugins = [
    "app",
    "audioconvert",
    "audiofx",
    "audioparsers",
    "audioresample",
    "audiotestsrc",
    "autodetect",
    "base",
    "coreelements",
    "flac",
    "gtk4",
    "id3demux",
    "isomp4",
    "level",
    "matroska",
    "mpg123",
    "ogg",
    "opengl",
    "opus",
    "playback",
    "png",
    "videoconvertscale",
    "videofilter",
    "videoparsersbad",
    "videotestsrc",
    "volume",
    "vpx",
    "wavenc",
    "wavparse",
    "webp",
]

a = Analysis(
    [os.path.join(cwd, "launch.py")],
    pathex=[cwd],
    datas=[(os.path.join(cwd, "gajim"), "gajim")],
    hiddenimports=hiddenimports,
    hookspath=[os.path.join(cwd, "mac", "hooks")],
    hooksconfig={
        "gi": {
            "module-versions": {
                "Gdk": "4.0",
                "Gtk": "4.0",
                "GtkSource": "5",
            },
        },
        "gstreamer": {"include_plugins": gst_include_plugins},
    },
    runtime_hooks=[os.path.join(cwd, "linux", "runtime_hooks", "gstreamer.py")],
    excludes=["PIL._imagingft"],
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data)
exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name="Gajim",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    console=False,
)
COLLECT(exe, a.binaries, a.zipfiles, a.datas, strip=False, upx=False, name="Gajim")
