# wezterm.nix
{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  luaAction = expr: lib.generators.mkLuaInline expr;
in

{
  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      automatically_reload_config = true;
      enable_wayland = true;
      use_ime = true;

      color_scheme = "Catppuccin Mocha";

      inactive_pane_hsb = {
        saturation = 0.6;
        brightness = 0.4;
      };

      font = luaAction ''wezterm.font("Moralerspace Neon HW")'';
      font_size = 13.0;

      window_padding = {
        left = 20;
        right = 20;
        top = 20;
        bottom = 20;
      };

      window_background_opacity = 0.8;

      disable_default_key_bindings = true;
      disable_default_mouse_bindings = true;

      leader = {
        key = "q";
        mods = "CTRL";
        timeout_milliseconds = 2000;
      };

      keys = [
        {
          key = "%";
          mods = "LEADER|SHIFT";
          action = luaAction ''wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" })'';
        }

        {
          key = "\"";
          mods = "LEADER|SHIFT";
          action = luaAction ''wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" })'';
        }

        {
          key = "h";
          mods = "LEADER";
          action = luaAction ''wezterm.action.ActivatePaneDirection("Left")'';
        }
        {
          key = "l";
          mods = "LEADER";
          action = luaAction ''wezterm.action.ActivatePaneDirection("Right")'';
        }
        {
          key = "k";
          mods = "LEADER";
          action = luaAction ''wezterm.action.ActivatePaneDirection("Up")'';
        }
        {
          key = "j";
          mods = "LEADER";
          action = luaAction ''wezterm.action.ActivatePaneDirection("Down")'';
        }

        {
          key = "h";
          mods = "LEADER|CTRL";
          action = luaAction ''wezterm.action.AdjustPaneSize({ "Left", 5 })'';
        }
        {
          key = "l";
          mods = "LEADER|CTRL";
          action = luaAction ''wezterm.action.AdjustPaneSize({ "Right", 5 })'';
        }
        {
          key = "k";
          mods = "LEADER|CTRL";
          action = luaAction ''wezterm.action.AdjustPaneSize({ "Up", 5 })'';
        }
        {
          key = "j";
          mods = "LEADER|CTRL";
          action = luaAction ''wezterm.action.AdjustPaneSize({ "Down", 5 })'';
        }

        {
          key = "x";
          mods = "LEADER";
          action = luaAction ''wezterm.action.CloseCurrentPane({ confirm = true })'';
        }

        {
          key = "z";
          mods = "LEADER";
          action = "TogglePaneZoomState";
        }
      ];
    };
  };
}
