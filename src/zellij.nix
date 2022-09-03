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
          tolocked = { action = [{ SwithToMode = "Locked"; }]; key = [{ Ctrl = "b"; }]; };
        in
        {
          locked = [{ action = [{ SwithToMode = "Normal"; }]; key = [{ Ctrl = "b"; }]; }];
          normal = [ tolocked ];
          resize = [ tolocked ];
          pane = [ tolocked ];
          move = [ tolocked ];
          tab = [ tolocked ];
          scroll = [ tolocked ];
          search = [ tolocked ];
          session = [ tolocked ];
          tmux = [ tolocked ];
        };
    };
  };
}
