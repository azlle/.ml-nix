# hm_modules/catppuccin.nix
{
  # keep the current behaviour of manually toggling each port
  # (e.g. `catppuccin.foot.enable`) instead of auto-enrolling all of them.
  catppuccin.enable = true;
  catppuccin.autoEnable = false;
}
