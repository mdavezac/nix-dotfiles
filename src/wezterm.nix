{ config, pkgs, lib, ... }: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      -- Your lua code / config here
      return {
        font = wezterm.font("VictorMono Nerd Font"),
        font_size = 14.0,
        color_scheme = "Dark Tooth",
        hide_tab_bar_if_only_one_tab = true,
        default_prog = { "{pkgs.fish}/bin/fish", "--login" },
      }
    '';
  };
}
