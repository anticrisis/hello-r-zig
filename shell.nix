let
  pkgs = import <nixpkgs> { config = {}; overlays = []; };
in
pkgs.mkShell {
  packages = with pkgs; [
    R
  ];

  LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
}
