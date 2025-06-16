{ ... }:

let
  aagl = import (builtins.fetchTarball {
    url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
    sha256 = "0laf8jj0p096l434sq4mkgmgb2xklywp7c4cn8iy6rqqpvhp3dbg";
  });
in
{
  imports = [
    aagl.module
  ];

  programs.sleepy-launcher.enable = true;
}
