# nnn.nix
{ pkgs, ... }:

{
  programs.nnn = {
    enable = true;
    bookmarks = {
      p = "~/Pictures";
    };
    package = pkgs.nnn.override { withNerdIcons = true; };

    plugins = {
      src = (pkgs.fetchFromGitHub {
        owner = "jarun";
        repo = "nnn";
        rev = "master";
        hash = "sha256-+2lFFBtaqRPBkEspCFtKl9fllbSR5MBB+4ks3Xh7vp4=";
      }) + "/plugins";

      mappings = {
        p = "preview-tui";
      };
    };
  };
}
