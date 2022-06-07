{ config, pkgs, lib, ... }:
let
  kitty-theme = pkgs.kitty-themes;
in
{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "VictorMono Nerd Font";
      font_size = 14;
      adjust_column_width = "90%";
      disable_ligatures = "cursor";
      macos_thicken_font = "0.50";
      copy_on_select = true;
      scrollback_lines = 50000;
      enable_audio_bell = false;
      shell = "${pkgs.fish}/bin/fish --login";
      macos_quit_when_last_window_closed = true;
      hide_window_decorations = true;
      macos_option_as_alt = "left";
      macos_traditional_fullscreen = true;
      include = "${kitty-theme}/themes/glacier.conf";
    };
    keybindings = {
      "cmd+plus" = "change_font_size all +2.0";
      "cmd+minus" = "change_font_size all -2.0";
    };
  };
}
