{ ... }:

let
  aagl = import (builtins.fetchTarball {
    url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
    sha256 = "1f1m0i0zpwvgpcd99xxlmmr9qgwp114vfk3dzpf8z2bfqvvg7paw";
  });
in
{
  imports = [
    aagl.module
  ];

  programs.sleepy-launcher.enable = true;
}
