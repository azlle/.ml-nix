# modules/wezterm.nix
{ delib, ... }:
delib.module {
  name = "wezterm";

  home.always = {
    imports = [
      (
        {
          inputs,
          lib,
          pkgs,
          ...
        }:
        let
          luaAction = expr: lib.generators.mkLuaInline expr;

          copyMode = arg: luaAction "wezterm.action.CopyMode(${arg})";
          quitCopyMode = luaAction ''wezterm.action.Multiple({ "ScrollToBottom", { CopyMode = "Close" } })'';
          copyAndQuitCopyMode = luaAction ''
            wezterm.action.Multiple({
              { CopyTo = "ClipboardAndPrimarySelection" },
              "ScrollToBottom",
              { CopyMode = "Close" },
            })
          '';
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
                  key = "b";
                  mods = "LEADER";
                  action = luaAction ''wezterm.action.ActivatePaneDirection("Left")'';
                }
                {
                  key = "f";
                  mods = "LEADER";
                  action = luaAction ''wezterm.action.ActivatePaneDirection("Right")'';
                }
                {
                  key = "p";
                  mods = "LEADER";
                  action = luaAction ''wezterm.action.ActivatePaneDirection("Up")'';
                }
                {
                  key = "n";
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
                  action = luaAction "wezterm.action.CloseCurrentPane({ confirm = true })";
                }

                {
                  key = "z";
                  mods = "LEADER";
                  action = "TogglePaneZoomState";
                }

                {
                  key = "[";
                  mods = "LEADER";
                  action = "ActivateCopyMode";
                }

                {
                  key = "]";
                  mods = "LEADER";
                  action = luaAction ''wezterm.action.PasteFrom("Clipboard")'';
                }

                {
                  key = "c";
                  mods = "LEADER";
                  action = luaAction ''wezterm.action.SpawnTab("CurrentPaneDomain")'';
                }
                {
                  key = "n";
                  mods = "LEADER|CTRL";
                  action = luaAction "wezterm.action.ActivateTabRelative(1)";
                }
                {
                  key = "p";
                  mods = "LEADER|CTRL";
                  action = luaAction "wezterm.action.ActivateTabRelative(-1)";
                }
                {
                  key = ",";
                  mods = "LEADER";
                  action = luaAction ''
                    wezterm.action.PromptInputLine({
                      description = "Rename tab",
                      action = wezterm.action_callback(function(window, pane, line)
                        if line then
                          window:active_tab():set_title(line)
                        end
                      end),
                    })
                  '';
                }
                {
                  key = "&";
                  mods = "LEADER|SHIFT";
                  action = luaAction "wezterm.action.CloseCurrentTab({ confirm = true })";
                }

                {
                  key = "{";
                  mods = "LEADER|SHIFT";
                  action = luaAction ''wezterm.action.RotatePanes("CounterClockwise")'';
                }
                {
                  key = "}";
                  mods = "LEADER|SHIFT";
                  action = luaAction ''wezterm.action.RotatePanes("Clockwise")'';
                }

                {
                  key = "q";
                  mods = "LEADER";
                  action = luaAction "wezterm.action.PaneSelect({})";
                }

                {
                  key = ":";
                  mods = "LEADER|SHIFT";
                  action = "ActivateCommandPalette";
                }
              ]
              ++ (map (n: {
                key = toString n;
                mods = "LEADER";
                action = luaAction "wezterm.action.ActivateTab(${toString n})";
              }) (lib.range 0 9));

              key_tables = {
                copy_mode = [
                  # movement (C-f/b/n/p)
                  {
                    key = "f";
                    mods = "CTRL";
                    action = copyMode ''"MoveRight"'';
                  }
                  {
                    key = "b";
                    mods = "CTRL";
                    action = copyMode ''"MoveLeft"'';
                  }
                  {
                    key = "n";
                    mods = "CTRL";
                    action = copyMode ''"MoveDown"'';
                  }
                  {
                    key = "p";
                    mods = "CTRL";
                    action = copyMode ''"MoveUp"'';
                  }
                  {
                    key = "LeftArrow";
                    mods = "NONE";
                    action = copyMode ''"MoveLeft"'';
                  }
                  {
                    key = "RightArrow";
                    mods = "NONE";
                    action = copyMode ''"MoveRight"'';
                  }
                  {
                    key = "UpArrow";
                    mods = "NONE";
                    action = copyMode ''"MoveUp"'';
                  }
                  {
                    key = "DownArrow";
                    mods = "NONE";
                    action = copyMode ''"MoveDown"'';
                  }

                  # line (C-a/e, M-m)
                  {
                    key = "a";
                    mods = "CTRL";
                    action = copyMode ''"MoveToStartOfLine"'';
                  }
                  {
                    key = "e";
                    mods = "CTRL";
                    action = copyMode ''"MoveToEndOfLineContent"'';
                  }
                  {
                    key = "m";
                    mods = "ALT";
                    action = copyMode ''"MoveToStartOfLineContent"'';
                  }
                  {
                    key = "Home";
                    mods = "NONE";
                    action = copyMode ''"MoveToStartOfLine"'';
                  }
                  {
                    key = "End";
                    mods = "NONE";
                    action = copyMode ''"MoveToEndOfLineContent"'';
                  }
                  {
                    key = "Enter";
                    mods = "NONE";
                    action = copyMode ''"MoveToStartOfNextLine"'';
                  }

                  # word (M-f/b)
                  {
                    key = "f";
                    mods = "ALT";
                    action = copyMode ''"MoveForwardWordEnd"'';
                  }
                  {
                    key = "b";
                    mods = "ALT";
                    action = copyMode ''"MoveBackwardWord"'';
                  }
                  {
                    key = "LeftArrow";
                    mods = "ALT";
                    action = copyMode ''"MoveBackwardWord"'';
                  }
                  {
                    key = "RightArrow";
                    mods = "ALT";
                    action = copyMode ''"MoveForwardWordEnd"'';
                  }

                  # paging / buffer bounds (C-v/M-v, M-</M->)
                  {
                    key = "v";
                    mods = "CTRL";
                    action = copyMode ''"PageDown"'';
                  }
                  {
                    key = "v";
                    mods = "ALT";
                    action = copyMode ''"PageUp"'';
                  }
                  {
                    key = "PageUp";
                    mods = "NONE";
                    action = copyMode ''"PageUp"'';
                  }
                  {
                    key = "PageDown";
                    mods = "NONE";
                    action = copyMode ''"PageDown"'';
                  }
                  {
                    key = "<";
                    mods = "ALT|SHIFT";
                    action = copyMode ''"MoveToScrollbackTop"'';
                  }
                  {
                    key = ">";
                    mods = "ALT|SHIFT";
                    action = copyMode ''"MoveToScrollbackBottom"'';
                  }

                  # selection (C-space to mark, C-x chord for exchange-point/rectangle)
                  {
                    key = "Space";
                    mods = "CTRL";
                    action = copyMode ''{ SetSelectionMode = "Cell" }'';
                  }
                  {
                    key = "x";
                    mods = "CTRL";
                    action = luaAction ''
                      wezterm.action.ActivateKeyTable({
                        name = "copy_mode_ctrl_x",
                        timeout_milliseconds = 1000,
                      })
                    '';
                  }

                  # copy (M-w/C-w)
                  {
                    key = "w";
                    mods = "ALT";
                    action = copyAndQuitCopyMode;
                  }
                  {
                    key = "w";
                    mods = "CTRL";
                    action = copyAndQuitCopyMode;
                  }

                  # search (C-s)
                  {
                    key = "s";
                    mods = "CTRL";
                    action = luaAction ''wezterm.action.Search({ CaseInSensitiveString = "" })'';
                  }

                  # quit (Escape, C-g, q)
                  {
                    key = "Escape";
                    mods = "NONE";
                    action = quitCopyMode;
                  }
                  {
                    key = "g";
                    mods = "CTRL";
                    action = quitCopyMode;
                  }
                  {
                    key = "q";
                    mods = "NONE";
                    action = quitCopyMode;
                  }
                ];

                copy_mode_ctrl_x = [
                  {
                    key = "x";
                    mods = "CTRL";
                    action = copyMode ''"MoveToSelectionOtherEnd"'';
                  }
                  {
                    key = "Space";
                    mods = "NONE";
                    action = copyMode ''{ SetSelectionMode = "Block" }'';
                  }
                ];

                # entered via C-s/C-r from copy_mode (isearch-forward / isearch-backward)
                search_mode = [
                  {
                    key = "Enter";
                    mods = "NONE";
                    action = copyMode ''"PriorMatch"'';
                  }
                  {
                    key = "Escape";
                    mods = "NONE";
                    action = copyMode ''"Close"'';
                  }
                  {
                    key = "g";
                    mods = "CTRL";
                    action = copyMode ''"Close"'';
                  }

                  {
                    key = "s";
                    mods = "CTRL";
                    action = copyMode ''"NextMatch"'';
                  }
                  {
                    key = "r";
                    mods = "CTRL";
                    action = copyMode ''"PriorMatch"'';
                  }
                  {
                    key = "r";
                    mods = "ALT";
                    action = copyMode ''"CycleMatchType"'';
                  }
                  {
                    key = "u";
                    mods = "CTRL";
                    action = copyMode ''"ClearPattern"'';
                  }

                  {
                    key = "PageUp";
                    mods = "NONE";
                    action = copyMode ''"PriorMatchPage"'';
                  }
                  {
                    key = "PageDown";
                    mods = "NONE";
                    action = copyMode ''"NextMatchPage"'';
                  }
                  {
                    key = "UpArrow";
                    mods = "NONE";
                    action = copyMode ''"PriorMatch"'';
                  }
                  {
                    key = "DownArrow";
                    mods = "NONE";
                    action = copyMode ''"NextMatch"'';
                  }
                ];
              };
            };
          };
        }
      )
    ];
  };
}
