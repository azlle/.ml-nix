# modules/steam.nix
{ delib, ... }:
delib.module {
  name = "steam";

  nixos.always = {
    programs.steam = {
      enable = true;
      # package = pkgs.millennium-steam;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
