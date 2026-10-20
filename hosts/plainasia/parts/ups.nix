# hosts/plainasia/parts/ups.nix
# CyberPower CP1200PFCLCD JP (USB HID, 0764:0601) monitored by NUT. Event alerts are in alerts.nix.
{ config, ... }:
{
  sops.secrets."ups/upsmon-password".restartUnits = [
    "upsd.service"
    "upsmon.service"
  ];

  power.ups = {
    enable = true;
    mode = "standalone";

    ups.ups = {
      driver = "usbhid-ups";
      port = "auto";
      description = "CyberPower CP1200PFCLCD JP";
      directives = [
        # Recommended by the driver for CPS devices (device-side timeouts, nut#1689).
        "pollonly"
        # Killpower: cut the load after 60 s (CPS rounds smaller values down to 0, i.e. immediately) and
        # power it on when mains is present. ondelay must be 0 because CPS can restart the load `ondelay` s
        # after the cut even without mains; the driver's startup warning about it is expected.
        # See: https://github.com/networkupstools/nut/issues/432
        "offdelay = 60"
        "ondelay = 0"
      ];
    };

    upsd.listen = [ { address = "127.0.0.1"; } ];

    users.upsmon = {
      passwordFile = config.sops.secrets."ups/upsmon-password".path;
      upsmon = "primary";
    };

    upsmon.monitor.ups = {
      system = "ups@localhost";
      user = "upsmon";
      type = "primary";
    };
  };
}
