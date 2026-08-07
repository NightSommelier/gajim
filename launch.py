#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path


def _configure_bundled_gstreamer() -> None:
    if sys.platform != "darwin" or not getattr(sys, "frozen", False):
        return

    meipass = getattr(sys, "_MEIPASS", None)
    if meipass is None:
        return

    plugin_path = Path(meipass) / "gst_plugins"
    os.environ["GST_PLUGIN_PATH"] = str(plugin_path)
    os.environ["GST_PLUGIN_PATH_1_0"] = str(plugin_path)
    os.environ["GST_PLUGIN_SYSTEM_PATH"] = ""
    os.environ["GST_PLUGIN_SYSTEM_PATH_1_0"] = ""


_configure_bundled_gstreamer()

if __name__ == "__main__":
    # Protect the entry point of the application because we use
    # the multiprocessing module with "spawn"

    import gajim
    import gajim.main

    try:
        res = subprocess.check_output(
            [
                "git",
                "-C",
                f"{Path(__file__).parent}",
                "rev-parse",
                "--short=12",
                "HEAD",
            ],
            stderr=subprocess.DEVNULL,
        )
        gajim.__version__ += f"+{res.decode().strip()}"
    except Exception:
        pass

    gajim.main.run()
