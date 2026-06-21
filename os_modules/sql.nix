# sql.nix
{ pkgs, ... }:

{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  services.httpd = {
    enable = true;
    enablePHP = true;
    phpOptions = "";
  };
}
