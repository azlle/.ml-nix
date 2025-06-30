{ ... }:

let
  aagl = import (builtins.fetchTarball {
    url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
    sha256 = "1yyk034x32km8v472m1y6plh2822089b5aw4hil6g4h1ilh2canw";
  });
in
{
  imports = [
    aagl.module
  ];

  programs.sleepy-launcher.enable = true;
}
