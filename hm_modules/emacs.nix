{ config, lib, pkgs, ... }:

{
  home.file.".emacs.d" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix_ml/hm_modules/.config/emacs";
  };

  home.packages = [
    (pkgs.emacsWithPackagesFromUsePackage {
      config = ./.config/emacs/init.el;
      defaultInitFile = false;
      package = pkgs.emacs-git-pgtk;
      alwaysEnsure = true;
      # extraEmacsPackages = epkgs: [];
    })

    pkgs.wl-clipboard pkgs.skkDictionaries.l
    pkgs.ffmpeg pkgs.vips
    pkgs.adwaita-icon-theme pkgs.adwaita-icon-theme-legacy
  ];
}
