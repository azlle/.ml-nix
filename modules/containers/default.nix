# modules/containers/default.nix
{ delib, ... }:
delib.module {
  name = "containers";

  options = delib.singleEnableOption true;
}
