# modules/users.nix
{ delib, ... }:
delib.module {
  name = "users";

  nixos.always = {
    # デフォルト (true) だとユーザー新規作成時にしか hashedPasswordFile が
    # 適用されず、以後の rebuild では変更を無視する。plainasia で secrets の
    # 復号自体は直っているのに /etc/shadow が古い (ロックされた) ままという
    # 事象が起きたのはこれが原因。毎 rebuild で宣言値に強制同期させる。
    # 代わりに `passwd` 等での対話的な変更はできなくなる (次の rebuild で
    # 巻き戻る)。
    users.mutableUsers = false;

    imports = [
      (
        { config, pkgs, ... }:
        {
          users.users.eeshta = {
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets."users/password/eeshta".path;
            description = "eeshta";
            shell = pkgs.zsh;
            ignoreShellProgramCheck = true;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSkZhHC1jkM6y4CO7tES6lLIADXbtoMUsyNJX66WreR deb2nix"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB//5g0hW9QRnuPsg3PiFxxY47/HIak79nOF0CaGRiNS xia2nix"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1cTfNrr9TVn8ptmbB4pOuN2uJQ3Tu9XkMn69NYsoFq gal2nix"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJu6dRiFbEBV0R47xyDc6KEIXWqET3dQnQeBrisSrJCy pmos2nix"
            ];
            extraGroups = [ "wheel" ];
          };
        }
      )
    ];
  };
}
