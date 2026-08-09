# modules/ssh.nix
{ delib, ... }:
delib.module {
  name = "ssh";

  nixos.always = {
    services.openssh = {
      enable = true;

      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = 22;
        }
      ];

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
        ];
        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
        ];
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
        ];
      };
    };
  };

  home.always = {
    imports = [
      (
        { pkgs, ... }:
        {
          home.packages = [ pkgs.cloudflared ];

          programs.ssh = {
            enable = true;
            enableDefaultConfig = false;

            settings = {
              "*" = {
                ForwardAgent = false;
                AddKeysToAgent = "no";
                Compression = false;
                ServerAliveInterval = 0;
                ServerAliveCountMax = 3;
                HashKnownHosts = false;
                ControlMaster = "no";
              };

              "git-ssh.melocy.cc" = {
                User = "git";
                ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
              };
            };
          };
        }
      )
    ];
  };
}
