{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay.url = "github:nix-community/emacs-overlay";

    ml-twist = {
      url = "git+https://git.melocy.cc/azlle/.ml-twist";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    blender-bin.url = "github:edolstra/nix-warez?dir=blender";

    niri.url = "github:sodiboo/niri-flake";

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bunny-yazi = {
      url = "github:stelcodes/bunny.yazi";
      flake = false;
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    millennium.url = "github:SteamClientHomebrew/Millennium/next?dir=packages/nix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ml-secrets = {
      url = "git+ssh://git@ssh.upd.dev/Azlle/.nix_ml-secrets.git?shallow=1";
      flake = false;
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nixcord.url = "github:FlameFlag/nixcord";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim";

    wezterm.url = "github:wezterm/wezterm?dir=nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      lanzaboote,
      emacs-overlay,
      ml-twist,
      catppuccin,
      niri,
      aagl,
      nix-cachyos-kernel,
      millennium,
      sops-nix,
      zen-browser,
      nixcord,
      treefmt-nix,
      nixvim,
      ...
    }@inputs:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          emacs-overlay.overlays.default
          niri.overlays.niri
          nix-cachyos-kernel.overlays.pinned
          millennium.overlays.default
        ];
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        settings.global.excludes = [ "machines/*" ];
        programs = {
          nixfmt.enable = true;
          statix.enable = true;
          deadnix.enable = true;
        };
      };

      nixSettings =
        {
          extraSettings ? { },
        }:
        {
          package = pkgs.nixVersions.stable;
          settings = {
            extra-substituters = [
              "https://nix-community.cachix.org"
              "https://attic.xuyh0120.win/lantian"
              "https://wezterm.cachix.org"
            ];
            extra-trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
              "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
            ];
            warn-dirty = false;
            http-connections = 50;
          } // extraSettings;
        };

      createNixosConfiguration =
        {
          username,
          hostname,
          homeDirectory ? "/home/${username}",
          stateVersion ? "24.11",
          extraHomeModules ? [ ],
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = {
            inherit
              inputs
              username
              hostname
              homeDirectory
              stateVersion
              nixSettings
              ;
          };
          modules = [
            ./os_modules
            ./hosts/${hostname}/hardware-configuration.nix
            lanzaboote.nixosModules.lanzaboote
            catppuccin.nixosModules.catppuccin
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = {
                  inherit
                    inputs
                    username
                    hostname
                    homeDirectory
                    stateVersion
                    ;
                };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username}.imports = [
                  ./hosts/${hostname}/${username}.nix
                  catppuccin.homeModules.catppuccin
                  nixvim.homeModules.nixvim
                  ml-twist.homeModules.twist
                ]
                ++ extraHomeModules;
              };
            }
          ]
          ++ extraModules;
        };

      createHome =
        {
          username,
          hostname,
          homeDirectory ? "/home/${username}",
          stateVersion ? "24.11",
          extraHomeModules ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              inputs
              username
              homeDirectory
              hostname
              stateVersion
              nixSettings
              ;
          };
          modules = [
            ./hosts/${hostname}/${username}.nix
            catppuccin.homeModules.catppuccin
            nixvim.homeModules.nixvim
            {
              home = { inherit username homeDirectory stateVersion; };
              programs.home-manager.enable = true;
            }
          ]
          ++ extraHomeModules;
        };
    in
    {

      formatter.${system} = treefmtEval.config.build.wrapper;
      checks.${system}.formatting = treefmtEval.config.build.check self;

      nixosConfigurations = {
        necrofantasia = createNixosConfiguration {
          username = "eeshta";
          hostname = "necrofantasia";
          extraHomeModules = [
            zen-browser.homeModules.twilight
            nixcord.homeModules.nixcord
          ];
          extraModules = [
            nixos-hardware.nixosModules.asus-zephyrus-ga503
            niri.nixosModules.niri
            aagl.nixosModules.default
          ];
        };
      };

      homeConfigurations."sumizomenosakura" = createHome {
        username = "miyu";
        hostname = "sumizomenosakura";
        extraHomeModules = [ ];
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"   # emacs-overlay et al.
      "https://attic.xuyh0120.win/lantian" # nix-cachyos-kernel (Hydra CI)
      "https://wezterm.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
    ];
  };
}
