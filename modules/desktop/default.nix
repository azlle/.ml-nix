# modules/desktop/default.nix
{ delib, ... }:
delib.module {
  name = "desktop";

  options = delib.moduleOptions (
    { myconfig, ... }:
    with delib;
    {
      # isPC = isDesktop || isLaptop (denix base extension's built-in host type).
      enable = boolOption myconfig.host.isPC;
    }
  );
}
