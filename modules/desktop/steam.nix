# modules/desktop/steam.nix
{ delib, ... }:
delib.module {
  name = "desktop.steam";

  options = delib.singleCascadeEnableOption;

  nixos.ifEnabled = {
    programs.steam = {
      enable = true;
      # package = pkgs.millennium-steam;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
