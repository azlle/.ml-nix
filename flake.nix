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
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ml-twist = {
      url = "git+https://github.com/Azlle/.ml-twist";
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
      url = "git+ssh://git@github.com/Azlle/.ml-secrets.git?shallow=1";
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

    denix = {
      url = "github:yunfachi/denix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      niri,
      nix-cachyos-kernel,
      millennium,
      treefmt-nix,
      denix,
      ...
    }@inputs:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          niri.overlays.niri
          nix-cachyos-kernel.overlays.pinned
          millennium.overlays.default
        ];
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        settings.global.excludes = [ "hosts/necrofantasia/hardware-configuration.nix" ];
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
          }
          // extraSettings;
        };

      mkConfigurations =
        moduleSystem:
        denix.lib.configurations {
          inherit moduleSystem;
          extensions = [
            (denix.lib.extensions.base.withConfig {
              hosts.extraSubmodules = [
                {
                  options.wsl = denix.lib.options.boolOption false;
                  options.stateVersion = denix.lib.options.allowNull (denix.lib.options.strOption null);
                }
              ];
            })
            denix.lib.extensions.args
          ];
          paths = [
            ./modules
            ./hosts
          ];
          exclude = [
            ./hosts/necrofantasia/hardware-configuration.nix
          ];
          specialArgs = {
            inherit inputs nixSettings moduleSystem;
          };
        };
    in

    {
      formatter.${system} = treefmtEval.config.build.wrapper;
      checks.${system}.formatting = treefmtEval.config.build.check self;

      nixosConfigurations = nixpkgs.lib.filterAttrs (name: _: name != "sumizomenosakura") (
        mkConfigurations "nixos"
      );
      homeConfigurations = mkConfigurations "home";
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org" # niri et al.
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
