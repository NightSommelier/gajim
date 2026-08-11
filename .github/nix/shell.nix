{ pkgs ? import <nixpkgs> {} }:

let
  gnomeLibraries = with pkgs; [
    glib gtk4 libadwaita gtksourceview5 libspelling cairo pango harfbuzz
    freetype gobject-introspection libnice libsoup_3 libsecret hunspell
    sqlite openssl
  ];

  gstreamerPlugins = with pkgs.gst_all_1; [
    gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-rs
    gst-libav
  ];

  # linuxdeploy prepares AppDir but nixpkgs does not package its optional
  # AppImage output plugin. The upstream tool only creates the final container.
  appimagetool = pkgs.stdenvNoCC.mkDerivation {
    pname = "appimagetool";
    version = "continuous-2025-12-04";
    src = pkgs.fetchurl {
      url = "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage";
      hash = "sha256-ptceK2zWb46NFsN60WRliYXgz1/KqVDJCkgokMudE+A=";
    };
    dontUnpack = true;
    installPhase = ''install -Dm755 "$src" "$out/bin/appimagetool"'';
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    python312 uv git curl file which pkg-config gcc gnumake ninja meson
    gettext gobject-introspection p7zip unzip patchelf zstd librsvg
    linuxdeploy appimagetool appimage-run xorg-server
    libx11 libxcb libxext libxrender libxi libxfixes libxrandr libxcursor
    libxdamage libxcomposite libxinerama libxau libxdmcp
    flatpak flatpak-builder ostree appstream desktop-file-utils
  ] ++ gnomeLibraries ++ gstreamerPlugins;

  shellHook = let
    pkgConfigPath = pkgs.lib.makeSearchPath "lib/pkgconfig" gnomeLibraries;
    giTypelibPath = pkgs.lib.makeSearchPath "lib/girepository-1.0" gnomeLibraries;
    gstPluginPath = pkgs.lib.makeSearchPath "lib/gstreamer-1.0" gstreamerPlugins;
  in ''
    export PYTHONNOUSERSITE=1
    export PIP_DISABLE_PIP_VERSION_CHECK=1
    export UV_PYTHON_PREFERENCE=only-system
    export PKG_CONFIG_PATH="${pkgConfigPath}:''${PKG_CONFIG_PATH:-}"
    export GI_TYPELIB_PATH="${giTypelibPath}:''${GI_TYPELIB_PATH:-}"
    export GST_PLUGIN_SYSTEM_PATH_1_0="${gstPluginPath}:''${GST_PLUGIN_SYSTEM_PATH_1_0:-}"
  '';
}
