{ stdenv
, lib
, gettext
, libxml2
, libhandy
, fetchurl
, pkg-config
, libcanberra-gtk3
, gtk3
, glib
, meson
, ninja
, python3
, wrapGAppsHook
, appstream-glib
, desktop-file-utils
, gnome
, gsettings-desktop-schemas
}:

stdenv.mkDerivation rec {
  pname = "gnome-screenshot";
  version = "41.0";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.major version}/${pname}-${version}.tar.xz";
    sha256 = "Stt97JJkKPdCY9V5ZnPPFC5HILbnaPVGio0JM/mMlZc=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    appstream-glib
    libxml2
    desktop-file-utils
    python3
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    glib
    libcanberra-gtk3
    libhandy
    gnome.adwaita-icon-theme
    gsettings-desktop-schemas
  ];

  doCheck = true;

  postPatch = ''
    chmod +x build-aux/postinstall.py # patchShebangs requires executable file
    patchShebangs build-aux/postinstall.py
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      attrPath = "gnome.${pname}";
    };
  };

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/GNOME/gnome-screenshot";
    description = "Utility used in the GNOME desktop environment for taking screenshots";
    maintainers = teams.gnome.members;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
