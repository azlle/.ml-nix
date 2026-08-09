# modules/emacs.nix
{ delib, inputs, ... }:
delib.module {
  name = "emacs";

  home.always = {
    imports = [ inputs.ml-twist.homeModules.twist ];

    programs.emacs-twist = {
      enable = true;
      emacsclient.enable = true;
      createInitFile = true;
      createManifestFile = true;
    };
  };
}
