{ config, pkgs, lib, ... }:
let
  jpeg = pkgs.fetchurl {
    url = "https://img.wallpapersafari.com/desktop/1920/1080/89/41/WIoneJ.jpg";
    sha256 = "00fa91vydmdhms4njn44425bj1fw64442zsh855a7zbpnjz4i4mv";
    name = "wallpaper.jpg";
  };
  kitty-theme = pkgs.fetchurl {
    url =
      "https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/Atom.conf";
    sha256 = "1cbxp60jrx1i8gqcfmb6mszlns3kzqyz9wyizhd7pjg66pv218l3";
    name = "theme.conf";

  };
  png = pkgs.runCommand "wallpaper.png" { buildInputs = [ pkgs.imagemagick ]; }
    "convert ${jpeg} $out";
in {
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
      include = "${kitty-theme}";
    };
    keybindings = {
      "cmd+plus" = "change_font_size all +2.0";
      "cmd+minus" = "change_font_size all -2.0";
    };
  };
}
