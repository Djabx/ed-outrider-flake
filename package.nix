{
  lib,
  stdenv,
  python3,
  makeWrapper,
  wl-clipboard,
  xclip,
  pipewire,
  wmctrl,
  xorg,
  src,
}:

let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      aiohttp
      certifi
      pillow
      evdev
      pyqt6
    ]
  );
in
stdenv.mkDerivation {
  pname = "ed-outrider";
  version = src.shortRev or "unstable";
  inherit src;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace outrider/__init__.py \
      --replace-fail 'DATA_DIR = os.path.join(ROOT, "data")' 'DATA_DIR = os.environ.get("OUTRIDER_DATA_DIR", os.path.join(ROOT, "data"))'

    substituteInPlace ed_outrider.py \
      --replace-fail 'CONFIG_PATH = os.path.join(SCRIPT_DIR, "ed_outrider.toml")' 'CONFIG_PATH = os.environ.get("OUTRIDER_CONFIG_PATH", os.path.join(SCRIPT_DIR, "ed_outrider.toml"))'
  '';

  installPhase = ''
    mkdir -p $out/share/ed-outrider
    cp -r * $out/share/ed-outrider/

    mkdir -p $out/bin

    # Wrapper pour le serveur principal
    makeWrapper ${pythonEnv}/bin/python $out/bin/ed-outrider \
      --add-flags "$out/share/ed-outrider/ed_outrider.py" \
      --set PYTHONPATH "$out/share/ed-outrider" \
      --prefix PATH : ${lib.makeBinPath [ wl-clipboard xclip pipewire wmctrl xorg.xprop xorg.xwininfo ]} \
      --run 'export OUTRIDER_DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/ed-outrider"' \
      --run 'export OUTRIDER_CONFIG_PATH="''${XDG_CONFIG_HOME:-$HOME/.config}/ed-outrider/ed_outrider.toml"' \
      --run 'mkdir -p "$OUTRIDER_DATA_DIR" "''${OUTRIDER_CONFIG_PATH%/*}"'

    # Wrapper pour l'overlay en jeu
    makeWrapper ${pythonEnv}/bin/python $out/bin/ed-outrider-overlay \
      --add-flags "-m outrider.overlay_window" \
      --set PYTHONPATH "$out/share/ed-outrider" \
      --prefix PATH : ${lib.makeBinPath [ wl-clipboard xclip pipewire wmctrl xorg.xprop xorg.xwininfo ]} \
      --run "cd $out/share/ed-outrider" \
      --run 'export OUTRIDER_DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/ed-outrider"' \
      --run 'export OUTRIDER_CONFIG_PATH="''${XDG_CONFIG_HOME:-$HOME/.config}/ed-outrider/ed_outrider.toml"' \
      --run 'mkdir -p "$OUTRIDER_DATA_DIR" "''${OUTRIDER_CONFIG_PATH%/*}"'
  '';

  meta = with lib; {
    description = "Exploration companion and cockpit assistant for Elite Dangerous";
    homepage = "https://github.com/weslocke/ED-Outrider";
    license = licenses.gpl3Only;
    mainProgram = "ed-outrider";
    platforms = platforms.linux;
  };
}
