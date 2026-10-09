# modules/emacs.nix
{ delib, inputs, ... }:
delib.module {
  name = "emacs";

  home.always =
    { myconfig, ... }:
    {
      imports = [ inputs.ml-twist.homeModules.twist ];

      programs.emacs-twist = {
        enable = true;
        emacsclient.enable = true;
        createInitFile = true;
        createManifestFile = true;
        # GUIの要らないホスト (NAS機等) はGTK/native-comp抜きのnox版にする。
        config =
          if myconfig.host.isPC then
            inputs.ml-twist.packages.x86_64-linux.default
          else
            inputs.ml-twist.packages.x86_64-linux.nox;
      };
    };
}
