# modules/emacs.nix
{ delib, inputs, ... }:
delib.module {
  name = "emacs";

  options = delib.moduleOptions (
    { myconfig, ... }:
    with delib;
    enumOption [ "pgtk" "nox" ] (if myconfig.host.isLaptop then "pgtk" else "nox")
  );

  home.always =
    { myconfig, ... }:
    {
      imports = [ inputs.ml-twist.homeModules.twist ];

      programs.emacs-twist = {
        enable = true;
        emacsclient.enable = true;
        createInitFile = true;
        createManifestFile = true;

        config =
          if myconfig.emacs == "pgtk" then
            inputs.ml-twist.packages.x86_64-linux.default
          else
            inputs.ml-twist.packages.x86_64-linux.nox;
      };
    };
}
