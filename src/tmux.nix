{ config, pkgs, lib, ... }:
let
  attach = "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace";
in {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    aggressiveResize = false;
    historyLimit = 100000;
    resizeAmount = 5;
    escapeTime = 0;
    terminal = "xterm-kitty";
    secureSocket = false;
    plugins = [ pkgs.tmuxPlugins.cpu pkgs.tmuxPlugins.nord ];
    extraConfig = ''
      is_vim='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|n?vim?x?)(diff)?$"'
      bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
      bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
      bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
      bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
      bind -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"

      set-option -g default-command "${attach} -l fish"
      set-option -g default-shell ${pkgs.fish}/bin/fish

      bind-key "F" run-shell -b ${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/main.sh
    '';
  };
}
