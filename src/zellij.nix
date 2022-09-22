{ config, pkgs, lib, ... }: {
  programs.zellij = {
    enable = true;
    settings = {
      default_mode = "locked";
      scrollback_editor = "vi";
      default_shell = "${pkgs.fish}/bin/fish";
      theme = "one-half-dark";
      themes.one-half-dark = {
        bg = [ 40 44 52 ];
        red = [ 227 63 76 ];
        green = [ 152 195 121 ];
        yellow = [ 229 192 123 ];
        blue = [ 97 175 239 ];
        magenta = [ 198 120 221 ];
        orange = [ 216 133 76 ];
        fg = [ 220 223 228 ];
        cyan = [ 86 182 194 ];
        black = [ 27 29 35 ];
        white = [ 233 225 254 ];
      };
      keybinds =
        let
          action = actions: key: { action = actions; key = key; };
          action-char = actions: key: action actions [{ Char = key; }];
          action-ctrl = actions: key: action actions [{ Ctrl = key; }];
          to-mode = mode: key: action [{ SwitchToMode = mode; }] [{ Char = key; }];
          lock = { SwitchToMode = "Locked"; };
          tolocked = action [ lock ] [{ Ctrl = "b"; }];
        in
        {
          locked = [ (action [{ SwitchToMode = "Normal"; }] [{ Ctrl = "b"; }]) ];
          normal = [
            tolocked
            (action-char [ "Quit" ] "q")
            (to-mode "Session" "s")
            (to-mode "Pane" "p")
            (to-mode "Resize" "r")
            (to-mode "Scroll" "S")
            (to-mode "Tmux" "T")
            (to-mode "Search" "?")
            (to-mode "Tab" "t")
            (action-char [{ NewPane = null; } lock] "n")
            (action-char [{ NewTab = null; } lock] "N")
            (action-char [{ MoveFocus = "Left"; } lock] "h")
            (action-char [{ MoveFocus = "Right"; } lock] "l")
            (action-char [{ MoveFocus = "Down"; } lock] "j")
            (action-char [{ MoveFocus = "Up"; } lock] "k")
            (action [{ MoveFocus = "Left"; }] [{ Char = "H"; } { Ctrl = "h"; }])
            (action [{ MoveFocus = "Right"; }] [{ Char = "L"; } { Ctrl = "l"; }])
            (action [{ MoveFocus = "Down"; }] [{ Char = "J"; } { Ctrl = "j"; }])
            (action [{ MoveFocus = "Up"; }] [{ Char = "K"; } { Ctrl = "k"; }])
            (action-char [{ NewPane = "Down"; } lock] "/")
            (action-char [{ NewPane = "Left"; } lock] "<")
            (action-char [{ NewPane = "Right"; } lock] ">")
            (action-char [{ Resize = "Increase"; }] "+")
            (action-char [{ Resize = "Decrease"; }] "-")
            /* (action-char [{ ToggleFullScreen = null; } lock] "z") */
          ];
        };
    };
  };
}
