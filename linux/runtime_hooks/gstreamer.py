import os
import sys
from pathlib import Path


if getattr(sys, "frozen", False):
    root = Path(getattr(sys, "_MEIPASS", Path(sys.executable).parent))
    plugin_path = root / "gst_plugins"
    os.environ["GST_PLUGIN_PATH"] = str(plugin_path)
    os.environ["GST_PLUGIN_PATH_1_0"] = str(plugin_path)
    os.environ["GST_PLUGIN_SYSTEM_PATH"] = ""
    os.environ["GST_PLUGIN_SYSTEM_PATH_1_0"] = ""
