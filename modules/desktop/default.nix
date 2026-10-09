# modules/desktop/default.nix
{ delib, ... }:
delib.module {
  name = "desktop";

  options = delib.moduleOptions (
    { myconfig, ... }:
    with delib;
    {
      # isLaptop: denix base extension の host type ("laptop") から自動生成される。
      enable = boolOption myconfig.host.isLaptop;
    }
  );
}
