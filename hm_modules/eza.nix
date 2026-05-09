# eza.nix
_:

{
  programs.eza = {
    enable = true;

    extraOptions = [
      "--group-directories-first"
      "--color=always"
      "--icons"
      "--git"
    ];
  };
}
